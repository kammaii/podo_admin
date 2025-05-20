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


admin.initializeApp();
const db = admin.firestore();

async function sendZeptoEmail(userEmail, msgType) {
  let url = "https://api.zeptomail.com/v1.1/email/template";
  const token = functions.config().zepto.token;
  const templateKeys = {
      0: functions.config().zepto.templates.cleanup1,
      1: functions.config().zepto.templates.cleanup2,
      2: functions.config().zepto.templates.welcome,
      3: functions.config().zepto.templates.welcome_with_workbook,
  };
  const subjects = {
      0: '[Podo Korean] Your account is scheduled for deletion ⏳',
      1: '[Podo Korean] Your account has been deleted ✅',
      2: 'Welcome to Podo Korean! Let’s start your journey 🌟',
      3: 'Welcome to Podo Korean! Let’s start your journey 🌟',
  }
  const template_key = templateKeys[msgType];
  const emailSubject = subjects[msgType];
  const client = new SendMailClient({ url, token });

  try {
      const response = await client.sendMail({
        subject: emailSubject,
        template_key,
        from: {
          address: "noreply@podokorean.com",
          name: "Podo Korean"
        },
        to: [
          {
            email_address: {
              address: userEmail
            }
          }
        ]
      });
      console.log("✅ Email sent via ZeptoMail:");
      return true;
    } catch (error) {
      console.error("❌ ZeptoMail send error:", error);
      return false;
    }
}

async function refreshAccessToken() {
    console.log('리프레시 토큰!');
    const refreshToken = '1000.e56a5e2784e929544d344ba58bd292f8.8d03ef64c8d42c16d5ade89a22a5d671';
    const clientId = '1000.Q1NC1OLW71KOOV956A8YKMBG3TDQRY';
    const clientSecret = '45a63f72100797c5883b69c1988295e8fa4777247d';

    const res = await fetch('https://accounts.zoho.com/oauth/v2/token', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({
            refresh_token: refreshToken,
            client_id: clientId,
            client_secret: clientSecret,
            grant_type: 'refresh_token',
        })
    });
    const result = await res.json();

    if(!result.access_token) {
        throw new Error('Failed to refresh access token!');
    }

    return result.access_token;
}

async function getValidAccessToken() {
    const docRef = admin.firestore().collection('Tokens').doc('zoho');
    const doc = await docRef.get();

    if(doc.exists) {
        const data = doc.data();
        const accessToken = data.access_token;
        const issuedAt = data.access_token_on || 0;
        const now = Date.now();
        console.log('IssuedAt', data.access_token_on);
        console.log('Now', now);

        if((now - issuedAt) < 50 * 60 * 1000) {     // 50분
            console.log('유효한 access 토큰!');
            return accessToken;
        }
    }

    const newToken = await refreshAccessToken();
    console.log('뉴토큰!', newToken);

    await docRef.update({
        access_token: newToken,
        access_token_on: Date.now(),
    });

    return newToken;

}

async function sendRequestToZoho(url, requestBody) {
    let accessToken = await getValidAccessToken();

    const res = await fetch(url, {
        method: 'POST',
        headers: {
            Authorization: `Zoho-oauthtoken ${accessToken}`,
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams(requestBody),
    });

    const result = await res.json();
    console.log('Result', result);

    if (result.status === 'error') {
        throw new Error(result.message || 'Zoho API error');
    }

    return result;
}

async function test(request, response) {
    try {

        const email = 'kammaii@naver.com';
        if(!email) return response.status(400).send('Missing email');

        let requestBody = {
            listkey: '3z6187e64413036ac5e15cc240c22e8660774c3bad914a0a1ed1639dbe18dead80',
            resfmt: 'JSON',
        }

        const result = await sendRequestToZoho('https://campaigns.zoho.com/api/v1.1/getlistsubscribers', requestBody);
        const contacts = result['list_of_details'] || [];
        const emailExists = contacts.some(
            (contact) => contact['contact_email'].toLowerCase() === email.toLowerCase()
        );
        console.log('EXISTS: ' + emailExists);

        if(emailExists) {
            console.log('이메일 구독중');
            // 워크북 미포함
            await sendZeptoEmail(email, 2);
            return response.status(200).send('Sent welcome email without workbook');
        } else {
            console.log('신규 유저');
            // 워크북 포함
            await sendZeptoEmail(email, 3);
            return response.status(200).send('Sent welcome email with workbook');
        }

    } catch (e) {
        console.error('❌ Error adding contact to Zoho:', e.message);
        return response.status(500).send({ success: false, message: e.message });
    }
}


test();
