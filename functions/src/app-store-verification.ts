import { HttpsError } from "firebase-functions/v2/https";
import * as jwt from "jsonwebtoken";

/**
 * App Store Server API v2 verification.
 *
 * Required environment variables / secrets:
 *   - APPSTORE_ISSUER_ID: App Store Connect API issuer ID
 *   - APPSTORE_KEY_ID: App Store Connect API key ID
 *   - APPSTORE_PRIVATE_KEY: Base64-encoded .p8 private key
 *   - APPSTORE_BUNDLE_ID: App bundle ID (e.g., com.keeplearning.cycitizenship)
 *
 * Set these via: firebase functions:secrets:set <SECRET_NAME>
 */

const APP_STORE_API_BASE = "https://api.storekit.itunes.apple.com";
const APP_STORE_SANDBOX_API_BASE =
  "https://api.storekit-sandbox.itunes.apple.com";

/**
 * Generate a signed JWT for App Store Server API authentication.
 */
function generateAppStoreJWT(): string {
  const issuerId = process.env.APPSTORE_ISSUER_ID;
  const keyId = process.env.APPSTORE_KEY_ID;
  const privateKeyBase64 = process.env.APPSTORE_PRIVATE_KEY;
  const bundleId = process.env.APPSTORE_BUNDLE_ID;

  if (!issuerId || !keyId || !privateKeyBase64 || !bundleId) {
    throw new HttpsError(
      "internal",
      "App Store Server API is not configured. " +
        "Set APPSTORE_ISSUER_ID, APPSTORE_KEY_ID, APPSTORE_PRIVATE_KEY, " +
        "and APPSTORE_BUNDLE_ID secrets."
    );
  }

  const privateKey = Buffer.from(privateKeyBase64, "base64").toString("utf-8");

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: issuerId,
    iat: now,
    exp: now + 3600, // 1 hour
    aud: "appstoreconnect-v1",
    bid: bundleId,
  };

  return jwt.sign(payload, privateKey, {
    algorithm: "ES256",
    header: {
      alg: "ES256",
      kid: keyId,
      typ: "JWT",
    },
  });
}

/**
 * Look up a transaction with the App Store Server API v2.
 * Falls back to sandbox if production returns 404.
 */
export async function verifyAppStoreReceipt(
  transactionId: string
): Promise<void> {
  const token = generateAppStoreJWT();

  // Try production first, then sandbox
  let response = await callAppStoreAPI(
    APP_STORE_API_BASE,
    transactionId,
    token
  );

  if (response.status === 404) {
    // Try sandbox environment
    response = await callAppStoreAPI(
      APP_STORE_SANDBOX_API_BASE,
      transactionId,
      token
    );
  }

  if (response.status === 404) {
    throw new HttpsError(
      "not-found",
      "Transaction not found. The receipt may be invalid or expired."
    );
  }

  if (response.status === 401) {
    throw new HttpsError(
      "internal",
      "App Store authentication failed. Check API key configuration."
    );
  }

  if (!response.ok) {
    console.error(
      "App Store API error:",
      response.status,
      await response.text()
    );
    throw new HttpsError(
      "internal",
      "Failed to verify purchase with App Store."
    );
  }

  const data = await response.json();

  // The response contains a signed transaction info JWT
  // Decode it (we trust Apple's response, so we decode without full verification)
  const signedTransactionInfo = data.signedTransactionInfo;
  if (!signedTransactionInfo) {
    throw new HttpsError(
      "internal",
      "Invalid response from App Store — missing transaction info."
    );
  }

  // Decode the JWS payload (middle part)
  const parts = signedTransactionInfo.split(".");
  if (parts.length !== 3) {
    throw new HttpsError(
      "internal",
      "Invalid signed transaction info format from App Store."
    );
  }

  const transactionPayload = JSON.parse(
    Buffer.from(parts[1], "base64").toString("utf-8")
  );

  // Check revocation
  if (transactionPayload.revocationDate) {
    throw new HttpsError(
      "failed-precondition",
      "This purchase has been revoked or refunded."
    );
  }

  // For non-consumable (lifetime purchase), just confirm it exists and is not revoked
  // The product type should be "Non-Consumable"
  if (
    transactionPayload.type &&
    transactionPayload.type !== "Non-Consumable"
  ) {
    console.warn(
      `Unexpected product type: ${transactionPayload.type} for transaction ${transactionId}`
    );
  }
}

async function callAppStoreAPI(
  baseUrl: string,
  transactionId: string,
  token: string
): Promise<Response> {
  const url = `${baseUrl}/inApps/v1/transactions/${transactionId}`;
  return fetch(url, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  });
}
