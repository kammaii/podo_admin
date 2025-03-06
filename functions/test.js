const functions = require("firebase-functions");
const admin = require('firebase-admin');
const auth = require('firebase/auth');
const {onRequest} = require('firebase-functions/v1/https');
const axios = require('axios');
const nodemailer = require('nodemailer');
const KEY = "sk_wFBDSaBEJaZWeecTyfYKNqHQmnIwT";
const USER_ID = "l9yvPV5AqOgErjuggMlptBrN4dG3";
const gmailKey = 'utdu jhvp yrhm wrdp';
const revenueCatKey = 'sk_wFBDSaBEJaZWeecTyfYKNqHQmnIwT';



admin.initializeApp();

async function test(context) {
    const db = admin.firestore();
try {
        const en = await db.collection("Users").where("language", "==", "en").get();
        const fr = await db.collection("Users").where("language", "==", "fr").get();
        const de = await db.collection("Users").where("language", "==", "de").get();
        const es = await db.collection("Users").where("language", "==", "es").get();
        const id = await db.collection("Users").where("language", "==", "id").get();
        const pt = await db.collection("Users").where("language", "==", "pt").get();
        const ru = await db.collection("Users").where("language", "==", "ru").get();

        const enUserCount = en.size;
        const frUserCount = fr.size;
        const deUserCount = de.size;
        const esUserCount = es.size;
        const idUserCount = id.size;
        const ptUserCount = pt.size;
        const ruUserCount = ru.size;

        console.log(`Users with language "en": ${enUserCount}`);
        console.log(`Users with language "fr": ${frUserCount}`);
        console.log(`Users with language "de": ${deUserCount}`);
        console.log(`Users with language "es": ${esUserCount}`);
        console.log(`Users with language "id": ${idUserCount}`);
        console.log(`Users with language "pt": ${ptUserCount}`);
        console.log(`Users with language "ru": ${ruUserCount}`);

        return { enUserCount, frUserCount };
    } catch (error) {
        console.error("Error counting users:", error);
        throw error;
    }
}


async function test2() {
      let now = new Date();
      const db = admin.firestore();
    // 활성 유저 수
    let activeNew = 0;
    let activeBasic = 0;
    let activeTrial = 0;
    let activePremium = 0;
    let signUpUsers = 0;

    let aHourAgo = new Date();
    aHourAgo.setHours(aHourAgo.getHours() - 1);

    let snapshot = await admin.firestore().collection('UserCounts')
        .where('userCleanUpDate', '>=', aHourAgo)
        .orderBy('userCleanUpDate', 'desc')
        .limit(1)
        .get();
    if(snapshot.empty) {
        console.log('Doc is not exists');
        return;
    }
    await snapshot.docs[0].ref.update({'data': 'Good'});
    console.log('User Count Update Completed');
}

test2();
