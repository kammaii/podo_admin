const functions = require("firebase-functions");
const admin = require('firebase-admin');
const auth = require('firebase/auth');
const {onRequest} = require('firebase-functions/v1/https');
const deepl = require('deepl-node');
const deeplKey = functions.config().deepl.key;
const translator = new deepl.Translator(deeplKey);

admin.initializeApp();
var languages = ['es', 'fr', 'de', 'pt-BR', 'id', 'ru'];

async function test() {
    let results = [];
    for(let i=0; i<languages.length; i++) {
        let result = await translator.translateText('hello', null, languages[i]);
        results.push(result.text);
        console.log(result);
    }
    response.set('Access-Control-Allow-Origin', '*');
    response.status(200).send(results);
}

test();
