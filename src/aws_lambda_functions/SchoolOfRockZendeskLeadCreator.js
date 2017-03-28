// THIS IS A LAMBDA FUNCTION RUN ON AWS
// GO HERE TO EDIT IT: https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/SchoolOfRockZendeskLeadCreator?tab=code
// IT IS INCLUDED HERE FOR BACKUP & REFERENCE ONLY
'use strict';
var https = require('https');

exports.handler = function(event, context) {
    var fullName = event.firstName + ' ' + event.lastName;
    var body = 'Name: ' + fullName + '\nEmail: ' + event.email + '\nPhone: ' + event.phone + '\nInstrument: ' + event.instrument + '\n';

    console.log("Handling form submit for " + event.firstName + " and GroupId " + event.groupId);

    var pd = {
        ticket: {
            'group_id': event.groupId,
            'subject': 'You have a new lead!',
            'requester': {
                'locale_id': '1',
                'name': fullName,
                'email': event.email
            },
            'comment': {
                'body': body
            },
            'custom_fields': {
                '21744430': event.leadSource,
                '21589844': 'Uncontacted',
                '22589610': event.instrument,
                '21776834': event.phone,
                '22623384': event.referrer
            },
            'type': 'task',
            'recipient': event.recipient,
            'tags': ['school_of_rock_lead']
        }
    };

    console.log("Submission is OptIn? " + !!event.optIn);

    if (event.optIn === true) {
      var now = new Date();
      var dateString = now.getUTCFullYear().toString() + '-';
      var month = now.getUTCMonth()+1;
      var monthString;
      if (month > 9) {
          monthString = month.toString();
      } else {
          monthString = '0' + month.toString();
      }
      var date = now.getUTCDate();
      var dayString = date.toString();
      if (date < 10) {
          dayString = '0' + dayString;
      }
      dateString += monthString + '-' + dayString;

      pd.ticket.custom_fields['22785500'] = 'yes';
      pd.ticket.custom_fields['22771784'] = dateString;
    } else if (event.optIn === false ) {
      pd.ticket.custom_fields['22785500'] = 'no';
    }

    var postData = JSON.stringify(pd);

    var postOptions = {
        'host': 'schoolofrock.zendesk.com',
        'port': '443',
        'path': '/api/v2/tickets.json',
        'method': 'POST',
        'headers': {
            'Authorization': 'Basic aXRAc2Nob29sb2Zyb2NrLmNvbS90b2tlbjo4RTFXU2tHd2FJTEhtSUtscGk4emN1ak0zb1gwUDBiOHZjeHhnMm1O',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Content-Length': postData.length
        }
    };

    console.log("Posting form data to " + postOptions.host + ":" + postOptions.port + postOptions.path);

    var req = https.request(postOptions, function(res){
        var data = '';

        res.on('data', function(chunk){
            data += chunk;
        });
        res.on('end', function(){
            if(res.statusCode >= 200 && res.statusCode < 300) {
                console.log("Post: HTTP Success");
                context.succeed({success: true});
            } else {
                console.log("Post: HTTP Failure: " + JSON.stringify(data));
                context.fail(new Error(data));
            }
        });
    });

    req.on('error', function(e){
        console.log("Post: Failure making request: " + JSON.stringify(e));
        context.fail(new Error('Request failed with error: ' + e));
    });

    req.write(postData);

    req.end();
};