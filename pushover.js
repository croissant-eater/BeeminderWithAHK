// process.env.NODE_TLS_REJECT_UNAUTHORIZED='0' Uncomment if you're on a corporate network
const config = require('./config.json');
const fs = require('fs');
const Pushover = require('node-pushover');
const push = new Pushover({
	token: config.pushAuthToken,
	user: config.pushUserId
});


fs.readFile('status.txt', 'utf8', function(err, data) {
    if (err) {
        console.error(err);
        return;
    }

    if(data == "work") {
        push.send("", "Back to work", function (err, res){
            if(err) return console.log(err);
            console.log(res);
        });
        return;
    } else if(data == "break") {
        push.send("", "Time for a break", function (err, res){
            if(err) return console.log(err);
            console.log(res);
        });
        return;
    }
    console.log(data);
});

return
