const deepl = require('deepl-node');
const authKey = '0f8fd09a-93c6-4475-78be-86bf7596999f:fx';
const translator = new deepl.Translator(authKey);

var languages = ['es', 'fr', 'de', 'pt', 'id', 'ru'];

async function onDeeplFunction() {
        const result = await translator.translateText('Hello, world!', null, 'fr');
        console.log(result.text); // Bonjour, le monde !
        response.set('Access-Control-Allow-Origin', '*');
        response.status(200).send(result);
}

onDeeplFunction();

