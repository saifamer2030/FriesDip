'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationBranchOrder = functions.database.ref('/orderListforBranch/{branchid}/{orderid}')
    .onWrite(async (change, context) => {
        
    //   const sendUid = context.params.senderUid;
      const recieveid = context.params.branchid;
      const pushid = context.params.orderid;

      // If un-follow we exit the function.
      if (!change.after.val()) {
        return console.log('PushId ', pushid , ' recieve : ' ,recieveid);
      }
      console.log('PushId:', pushid);
      console.log('reciever UID:', recieveid);

          const bid = admin.database().ref(`/OrderIdAndBranchId/BranchId`).once('value');
          const oid = admin.database().ref(`/OrderIdAndBranchId/OrderId`).once('value');
          // const msge = admin.database().ref(`/Alarm/${recUid}/${pushId}/cType`).once('value');
          // const wid = admin.database().ref(`/Alarm/${recUid}/${pushId}/wid`).once('value');
          // const cheadid = admin.database().ref(`/Alarm/${recUid}/${pushId}/chead`).once('value');

          // Get the follower profile.
        //   const getFollowerProfilePromise = admin.database()
        //   ref(`/Alarm/{recieverUid}/{pushid}/cType`).once('value');

        // const getFollowerProfilePromise = admin.database()
        // .ref(`/Alarm/${recUid}/${pushId}/cType`).once('value');

        const results = await Promise.all([bid]);
          const id = results[0];



          const payload = {
            notification:{
                title : `طلب جديدة من `,
                body : `لديك  طلب جديد  `,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                id:`${id.val()}`,
                badge: '1',
                sound: 'default'
            },
            data:{
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                id:`${id.val()}`,


            }

        };
    
        return admin.database().ref(`/Fcm-Token/${recieveid}`).once('value').then(allToken => {
            if(allToken.val()){

                console.log('inside', allToken.val().Token);

               // const token = Object.keys(allToken.val());

                var str =  allToken.val().Token;
              console.log('token available str ',str);
                return admin.messaging().sendToDevice(str,payload);
            }else{
             return   console.log('No token available');
            }
        });
      


      
    });