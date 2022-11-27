const functions = require("firebase-functions");

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

exports.helloWorld = functions.https.onRequest((request, response) => {
  response.set('Access-Control-Allow-Origin', '*');
  if (request.method === 'OPTIONS') {
    // Send response to OPTIONS requests
    response.set('Access-Control-Allow-Methods', 'GET');
    response.set('Access-Control-Allow-Headers', 'Content-Type');
    response.set('Access-Control-Max-Age', '3600');
    response.status(204).send('');
  } else {
    functions.logger.info("Hello logs!", {structuredData: true});
    let responseObject = {
      "status" : "success",
      "message" : "hello from firebase"
    }
    response.send(responseObject);
  }
});

const cityRef = db.collection('test').doc('BJ');

const res = await cityRef.set({
  capital: true
}, { merge: true });
