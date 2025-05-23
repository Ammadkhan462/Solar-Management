require('dotenv').config();
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK using environment variables
admin.initializeApp({
  credential: admin.credential.cert({
    type: process.env.FIREBASE_TYPE,
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    client_id: process.env.FIREBASE_CLIENT_ID,
    auth_uri: process.env.FIREBASE_AUTH_URI,
    token_uri: process.env.FIREBASE_TOKEN_URI,
    auth_provider_x509_cert_url: process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
    client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
    universe_domain: process.env.FIREBASE_UNIVERSE_DOMAIN
  })
});

const sendNotification = async (deviceToken, title, body, data = {}) => {
  try {
    // Convert all data values to strings
    const stringifiedData = Object.keys(data).reduce((acc, key) => {
      acc[key] =
        typeof data[key] === "object"
          ? JSON.stringify(data[key])
          : String(data[key]);
      return acc;
    }, {});

    const message = {
      token: deviceToken,
      notification: {
        title,
        body,
      },
      data: stringifiedData,
    };

    const response = await admin.messaging().send(message);
    console.log("Notification sent successfully:", response);
    return { success: true, response }; // Return success object with response
  } catch (error) {
    console.error("Error sending notification:", error);
    return { success: false, error: error.message }; // Return failure object with error
  }
};

module.exports = {
  sendNotification,
};
