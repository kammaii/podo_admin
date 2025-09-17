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

// 언어별 유저 수
async function getUserCountByLang() {
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


// 리마인드 후 trial 모드 진입 유저 수
async function calcConvertRate() {
  const snapshots = await db.collection('Users').where('remind1_sentAt', '!=', null).get();

  let convertCount = 0;

  for(const doc of snapshots.docs) {
    if(doc.get('status') !== 0) {
        convertCount++;
    }
  }

  console.log('리마인드 유저 수 : ', snapshots.size);
  console.log('전환 유저 수: ', convertCount);
  console.log('전환 비율: ', (convertCount/snapshots.size * 100).toFixed(2) + '%');
}

async function sendTestFcm() {
    const fcmToken = "cy_1UDuGQ4-fw-7dfp1wZX:APA91bFDRneC2vPrYIHziEELMUUaCYf1iu5Iw8jnAOx59Gpz4C1irnra7M0bxflR4TmvfRfc5d0iHPDwEKcwCZlEaLDlHTD4tp0dEBdHRs6KWRq34SQ6MV4";
    const payload = {
            data: {
                'tag': 'test',
            },
            notification: {
                title: '테스트 메시지 입니다.',
                body: '안녕하세요?',
            },
            token: fcmToken,
        };

        try {
            await admin.messaging().send(payload);
            console.log('✅ fcm 전송 성공.');
        } catch (e) {
            console.log('❌ fcm 전송 실패: ', e);
        }
}

async function test() {
    const collectionRef = db.collection('KoreanBites');
      console.log('KoreanBites 컬렉션의 문서를 가져오는 중...');

      try {
        // 컬렉션의 모든 문서 스냅샷 가져오기
        const snapshot = await collectionRef.get();

        if (snapshot.empty) {
          console.log('업데이트할 문서가 없습니다.');
          return;
        }

        // 모든 업데이트 작업을 Promise 배열에 저장
        const updatePromises = [];
        snapshot.forEach(doc => {
          console.log(`ID: ${doc.id} 문서 업데이트 준비 중...`);
          // 각 문서에 대해 update 작업을 Promise 배열에 추가
          // set 메서드에 { merge: true } 옵션을 사용해도 동일한 결과를 얻을 수 있습니다.
          const updatePromise = doc.ref.update({
            hasAudio: true
          });
          updatePromises.push(updatePromise);
        });

        // 모든 업데이트 Promise가 완료될 때까지 기다림 (병렬 처리)
        await Promise.all(updatePromises);

        console.log(`✅ 성공: 총 ${snapshot.size}개의 문서를 업데이트했습니다.`);
      } catch (error) {
        console.error('❌ 오류가 발생했습니다:', error);
      }
}


test();
