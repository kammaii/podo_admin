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
const fs = require("fs");
const path = require("path");
const { SendMailClient } = require("zeptomail");
const messages = require('./fcm_messages');



admin.initializeApp();
const db = admin.firestore();

async function test() {
    let en = 0;
    let es = 0;
    let fr = 0;
    let de = 0;
    let pt = 0;
    let id = 0;
    let ru = 0;

    let users = await db.collection('Users').get();
    for(let i=0; i<users.docs.length; i++) {
        let lang = users.docs[i].get('language');
        if(lang == 'en') {
            en++;
        } else if(lang == 'es') {
            es++;
        } else if (lang == 'fr') {
            fr++;
        } else if (lang == 'de') {
            de++;
        } else if (lang == 'pt') {
            pt++;
        } else if (lang == 'id') {
            id++;
        } else if (lang == 'ru') {
            ru++;
        }

    }
    console.log('en: ', en);
    console.log('es: ', es);
    console.log('fr: ', fr);
    console.log('de: ', de);
    console.log('pt: ', pt);
    console.log('id: ', id);
    console.log('ru: ', ru);


}

async function sendFcm(user, title, body) {

    console.log(user.get('email'));

    const payload = {
        notification: {
            title: title,
            body: body,
        },
        token: user.get('fcmToken'),
    };

    try {
        await admin.messaging().send(payload);
        console.log('✅ fcm 전송 성공.');
    } catch (e) {
        console.log('❌ fcm 전송 실패: ', e);
    }
}

// todo: remindTrial 잘 되는지 먼저 확인하고 아래 코드는 오전에 실행시킬 것.
async function test1() {
    console.log('---Trial 리마인드 시작---');

    const targetDate = new Date('2025-07-01T03:00:00Z');
    const startTime = new Date();

    const now = new Date();
    now.setMinutes(0, 0, 0);
    const ago24h = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    const ago25h = new Date(now.getTime() - 25 * 60 * 60 * 1000);

    console.log('-------------------');
    console.log('1차 대상자 검색중...');

    const users1 = await db.collection('Users')
        .where('status', '==', 0)
        .where('dateSignUp', '<', targetDate)
        .where('fcmPermission', '==', true)
        .where('fcmToken', '!=', null)
        .get();

    console.log(`🎯 총 대상자: ${users1.docs.length}명`);

    const chunkSize = 300;

    for (let i = 0; i < users1.docs.length; i += chunkSize) {
        const chunk = users1.docs.slice(i, i + chunkSize);

        const promises = chunk.map(async (user) => {
            try {
                await user.ref.update({
                    'remind1_sentAt': startTime
                });
                const userLang = user.get('language') ?? 'en';
                await sendFcm(user, messages[userLang].title1, messages[userLang].body1);
                console.log(`✅ FCM 전송 성공: ${user.get('email')}`);
            } catch (e) {
                console.error(`❌ FCM 전송 실패: ${user.get('email')}`, e);
            }
        });

        await Promise.all(promises);
        console.log(`✅ ${i + 1} ~ ${i + chunk.length}명 전송 완료`);

        // FCM rate limit 방지를 위한 대기 시간
        await new Promise(resolve => setTimeout(resolve, 1000));
    }

    console.log('🎉 모든 대상자 전송 완료');

}

test1();
