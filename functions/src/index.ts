import * as admin from "firebase-admin";

admin.initializeApp();

export { verifyPurchase } from "./verify-purchase";
export { chatWithTutor, generatePracticeQuestion, greekPractice } from "./gemini-ai";
