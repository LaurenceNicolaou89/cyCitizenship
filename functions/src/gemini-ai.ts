import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  GoogleGenerativeAI,
  Content,
  Part,
} from "@google/generative-ai";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const GEMINI_MODEL = "gemini-2.0-flash";

// Rate limits (per user per day)
const RATE_LIMITS = {
  free: {
    tutor: 3,
    practice: 5,
    greek: 3,
  },
  premium: {
    tutor: 50,
    practice: 100,
    greek: 50,
  },
};

// ---------------------------------------------------------------------------
// System prompts (server-side only — never exposed to clients)
// ---------------------------------------------------------------------------

const TUTOR_SYSTEM_PROMPT = `You are an expert tutor helping students prepare for the Cyprus citizenship exam.
You have deep knowledge of Cyprus history, politics, geography, culture, and daily life.
Answer questions concisely and accurately, focusing on exam-relevant information.
If asked something outside the exam scope, politely redirect to exam topics.
Always respond in the language the user writes in.`;

const SMART_PRACTICE_SYSTEM_PROMPT = `You are a Cyprus citizenship exam question generator.
Generate one multiple-choice question with exactly 4 options (A, B, C, D).
Format your response as JSON:
{"question": "...", "options": ["A. ...", "B. ...", "C. ...", "D. ..."], "correctIndex": 0, "explanation": "..."}
Focus on the requested category and difficulty level.
Respond in the requested language.`;

const GREEK_PRACTICE_SYSTEM_PROMPT = `You are a Greek language conversation partner for Cyprus citizenship exam candidates.
Speak in Greek and help the user practice conversational Greek.
Provide transliterations in parentheses after Greek text.
Gently correct mistakes and explain grammar.
Adapt your level: A2 (elementary) or B1 (intermediate) as requested.
Use daily life scenarios relevant to living in Cyprus.`;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function getGeminiClient(): GoogleGenerativeAI {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new HttpsError(
      "internal",
      "Gemini API key is not configured on the server."
    );
  }
  return new GoogleGenerativeAI(apiKey);
}

/**
 * Check and increment rate limit for a given user and feature.
 * Returns true if the request is within limits, throws if exceeded.
 */
async function checkRateLimit(
  uid: string,
  feature: "tutor" | "practice" | "greek"
): Promise<void> {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(uid).get();
  const isPremium = userDoc.exists && userDoc.data()?.isPremium === true;

  const limits = isPremium ? RATE_LIMITS.premium : RATE_LIMITS.free;
  const dailyLimit = limits[feature];

  const today = new Date();
  const dateKey = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, "0")}-${String(today.getDate()).padStart(2, "0")}`;

  const rateLimitRef = db
    .collection("rate_limits")
    .doc(uid)
    .collection("daily")
    .doc(dateKey);

  const result = await db.runTransaction(async (tx) => {
    const doc = await tx.get(rateLimitRef);
    const data = doc.exists ? doc.data() : {};
    const currentCount = (data?.[feature] as number) ?? 0;

    if (currentCount >= dailyLimit) {
      return { allowed: false, currentCount, dailyLimit };
    }

    tx.set(rateLimitRef, { [feature]: currentCount + 1 }, { merge: true });
    return { allowed: true, currentCount: currentCount + 1, dailyLimit };
  });

  if (!result.allowed) {
    throw new HttpsError(
      "resource-exhausted",
      `Daily limit of ${dailyLimit} ${feature} requests reached. ${isPremium ? "Try again tomorrow." : "Upgrade to Premium for higher limits."}`
    );
  }
}

interface ChatMessageData {
  role: string;
  content: string;
}

function buildGeminiHistory(
  messages: ChatMessageData[]
): Content[] {
  return messages.map((m) => ({
    role: m.role === "user" ? "user" : "model",
    parts: [{ text: m.content } as Part],
  }));
}

// ---------------------------------------------------------------------------
// Cloud Functions
// ---------------------------------------------------------------------------

/**
 * chatWithTutor
 *
 * Receives: { messages: [{role, content}], message: string }
 * Returns:  { response: string }
 */
export const chatWithTutor = onCall(
  {
    enforceAppCheck: false,
    maxInstances: 20,
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    const uid = request.auth.uid;
    const { messages, message } = request.data as {
      messages?: ChatMessageData[];
      message?: string;
    };

    if (!message || typeof message !== "string" || message.trim().length === 0) {
      throw new HttpsError("invalid-argument", "Message is required.");
    }

    await checkRateLimit(uid, "tutor");

    const genAI = getGeminiClient();
    const model = genAI.getGenerativeModel({ model: GEMINI_MODEL });

    const systemContent: Content = {
      role: "user",
      parts: [{ text: TUTOR_SYSTEM_PROMPT } as Part],
    };

    const history: Content[] = [
      systemContent,
      ...(messages ? buildGeminiHistory(messages) : []),
    ];

    const chat = model.startChat({ history });

    try {
      const result = await chat.sendMessage(message);
      const responseText =
        result.response.text() || "Sorry, I could not generate a response.";

      return { response: responseText };
    } catch (error) {
      console.error("Gemini API error (tutor):", error);
      throw new HttpsError(
        "internal",
        "Failed to generate AI response. Please try again."
      );
    }
  }
);

/**
 * generatePracticeQuestion
 *
 * Receives: { category: string, difficulty: string, language: string }
 * Returns:  { response: string } (JSON string of the question)
 */
export const generatePracticeQuestion = onCall(
  {
    enforceAppCheck: false,
    maxInstances: 20,
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    const uid = request.auth.uid;
    const { category, difficulty, language } = request.data as {
      category?: string;
      difficulty?: string;
      language?: string;
    };

    if (!category || !difficulty || !language) {
      throw new HttpsError(
        "invalid-argument",
        "category, difficulty, and language are required."
      );
    }

    await checkRateLimit(uid, "practice");

    const genAI = getGeminiClient();
    const model = genAI.getGenerativeModel({ model: GEMINI_MODEL });

    const prompt = `Generate a ${difficulty} ${category} question for the Cyprus citizenship exam. Respond in ${language}.`;

    const chat = model.startChat({
      history: [
        {
          role: "user",
          parts: [{ text: SMART_PRACTICE_SYSTEM_PROMPT } as Part],
        },
      ],
    });

    try {
      const result = await chat.sendMessage(prompt);
      const responseText = result.response.text() || "{}";

      return { response: responseText };
    } catch (error) {
      console.error("Gemini API error (practice):", error);
      throw new HttpsError(
        "internal",
        "Failed to generate practice question. Please try again."
      );
    }
  }
);

/**
 * greekPractice
 *
 * Receives: { messages: [{role, content}], message: string, level: string }
 * Returns:  { response: string }
 */
export const greekPractice = onCall(
  {
    enforceAppCheck: false,
    maxInstances: 20,
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    const uid = request.auth.uid;
    const { messages, message, level } = request.data as {
      messages?: ChatMessageData[];
      message?: string;
      level?: string;
    };

    if (!message || typeof message !== "string" || message.trim().length === 0) {
      throw new HttpsError("invalid-argument", "Message is required.");
    }

    const greekLevel = level === "A2" ? "A2" : "B1";

    await checkRateLimit(uid, "greek");

    const genAI = getGeminiClient();
    const model = genAI.getGenerativeModel({ model: GEMINI_MODEL });

    const systemPrompt = `${GREEK_PRACTICE_SYSTEM_PROMPT}\nCurrent level: ${greekLevel}`;

    const history: Content[] = [
      {
        role: "user",
        parts: [{ text: systemPrompt } as Part],
      },
      ...(messages ? buildGeminiHistory(messages) : []),
    ];

    const chat = model.startChat({ history });

    try {
      const result = await chat.sendMessage(message);
      const responseText =
        result.response.text() || "Sorry, I could not generate a response.";

      return { response: responseText };
    } catch (error) {
      console.error("Gemini API error (greek):", error);
      throw new HttpsError(
        "internal",
        "Failed to generate AI response. Please try again."
      );
    }
  }
);
