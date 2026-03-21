import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { google } from "googleapis";
import { verifyAppStoreReceipt } from "./app-store-verification";

const PRODUCT_ID = "cy_citizenship_premium";

interface VerifyPurchaseRequest {
  purchaseToken: string;
  productId: string;
  platform: "android" | "ios";
}

/**
 * Callable Cloud Function to verify in-app purchase receipts.
 *
 * For Android: Uses Google Play Developer API with a service account.
 * For iOS: Uses App Store Server API v2 with signed JWTs.
 *
 * Idempotent: if the user is already premium with the same purchase token,
 * returns success without re-processing.
 *
 * Required configuration (set via Firebase environment config or Secret Manager):
 *
 * Android (Google Play):
 *   - Store a service account JSON key file in the functions directory as
 *     `service-account-google-play.json`, or set the GOOGLE_PLAY_SERVICE_ACCOUNT
 *     secret with the JSON content.
 *   - The service account must have "View financial data" permission in
 *     Google Play Console > Settings > API access.
 *
 * iOS (App Store):
 *   - APPSTORE_ISSUER_ID: Your App Store Connect API issuer ID
 *   - APPSTORE_KEY_ID: Your App Store Connect API key ID
 *   - APPSTORE_PRIVATE_KEY: The .p8 private key contents (base64 encoded)
 *   - APPSTORE_BUNDLE_ID: Your app's bundle ID
 *   Set these via `firebase functions:secrets:set <KEY>`.
 */
export const verifyPurchase = onCall(
  {
    enforceAppCheck: false, // Enable when App Check is configured
    maxInstances: 10,
  },
  async (request) => {
    // Require authentication
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated to verify purchases."
      );
    }

    const uid = request.auth.uid;
    const data = request.data as VerifyPurchaseRequest;

    // Validate input
    if (!data.purchaseToken || !data.productId || !data.platform) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required fields: purchaseToken, productId, platform."
      );
    }

    if (data.productId !== PRODUCT_ID) {
      throw new HttpsError(
        "invalid-argument",
        `Unknown product ID: ${data.productId}. Expected: ${PRODUCT_ID}`
      );
    }

    if (data.platform !== "android" && data.platform !== "ios") {
      throw new HttpsError(
        "invalid-argument",
        "Platform must be 'android' or 'ios'."
      );
    }

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    // Idempotency check: if user already has this purchase token recorded, skip
    const userDoc = await userRef.get();
    if (userDoc.exists) {
      const userData = userDoc.data();
      if (
        userData?.isPremium === true &&
        userData?.purchaseToken === data.purchaseToken
      ) {
        return {
          success: true,
          message: "Purchase already verified.",
          alreadyVerified: true,
        };
      }
    }

    // Check if this token has been used by another account (prevents token sharing)
    const existingPurchase = await db
      .collection("verified_purchases")
      .doc(data.purchaseToken)
      .get();

    if (existingPurchase.exists) {
      const existingUid = existingPurchase.data()?.uid;
      if (existingUid && existingUid !== uid) {
        throw new HttpsError(
          "already-exists",
          "This purchase receipt has already been used by another account."
        );
      }
      // Same user, same token — already verified
      if (existingUid === uid) {
        return {
          success: true,
          message: "Purchase already verified.",
          alreadyVerified: true,
        };
      }
    }

    // Verify with the appropriate store
    try {
      if (data.platform === "android") {
        await verifyAndroidPurchase(data.purchaseToken, data.productId);
      } else {
        await verifyAppStoreReceipt(data.purchaseToken);
      }
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      console.error("Purchase verification failed:", error);
      throw new HttpsError(
        "internal",
        "Failed to verify purchase. Please try again later."
      );
    }

    // Verification succeeded — update Firestore atomically
    const now = admin.firestore.FieldValue.serverTimestamp();
    const batch = db.batch();

    // Update user document
    batch.set(
      userRef,
      {
        isPremium: true,
        purchaseDate: now,
        purchaseToken: data.purchaseToken,
        purchasePlatform: data.platform,
      },
      { merge: true }
    );

    // Record the verified purchase for idempotency and anti-fraud
    batch.set(db.collection("verified_purchases").doc(data.purchaseToken), {
      uid: uid,
      productId: data.productId,
      platform: data.platform,
      verifiedAt: now,
    });

    await batch.commit();

    return {
      success: true,
      message: "Purchase verified successfully.",
      alreadyVerified: false,
    };
  }
);

/**
 * Verify an Android purchase token with Google Play Developer API.
 *
 * Requires a service account with Google Play Developer API access.
 * The service account JSON can be provided via:
 *   1. A file at functions/service-account-google-play.json
 *   2. The GOOGLE_PLAY_SERVICE_ACCOUNT environment variable (JSON string)
 */
async function verifyAndroidPurchase(
  purchaseToken: string,
  productId: string
): Promise<void> {
  const packageName = "com.keeplearning.cycitizenship";

  let auth;
  try {
    // Try loading service account from file or environment
    const serviceAccountJson = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT;
    if (serviceAccountJson) {
      const credentials = JSON.parse(serviceAccountJson);
      auth = new google.auth.GoogleAuth({
        credentials,
        scopes: ["https://www.googleapis.com/auth/androidpublisher"],
      });
    } else {
      // Fall back to Application Default Credentials or local file
      auth = new google.auth.GoogleAuth({
        keyFilename: "service-account-google-play.json",
        scopes: ["https://www.googleapis.com/auth/androidpublisher"],
      });
    }
  } catch (error) {
    console.error("Failed to initialize Google Play auth:", error);
    throw new HttpsError(
      "internal",
      "Server configuration error for purchase verification."
    );
  }

  const androidPublisher = google.androidpublisher({
    version: "v3",
    auth,
  });

  try {
    const response = await androidPublisher.purchases.products.get({
      packageName,
      productId,
      token: purchaseToken,
    });

    const purchase = response.data;

    // purchaseState: 0 = purchased, 1 = canceled, 2 = pending
    if (purchase.purchaseState !== 0) {
      const stateMap: Record<number, string> = {
        1: "canceled",
        2: "pending",
      };
      const state = stateMap[purchase.purchaseState ?? -1] ?? "unknown";
      throw new HttpsError(
        "failed-precondition",
        `Purchase is not valid. Current state: ${state}.`
      );
    }

    // Acknowledge the purchase if not already acknowledged
    if (purchase.acknowledgementState === 0) {
      await androidPublisher.purchases.products.acknowledge({
        packageName,
        productId,
        token: purchaseToken,
      });
    }
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    const err = error as { code?: number; message?: string };
    if (err.code === 404) {
      throw new HttpsError(
        "not-found",
        "Purchase token not found. The receipt may be invalid or expired."
      );
    }
    console.error("Google Play API error:", error);
    throw new HttpsError(
      "internal",
      "Failed to verify purchase with Google Play."
    );
  }
}
