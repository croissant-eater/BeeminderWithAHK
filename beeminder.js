const config = require('./config.json');
const auth_token = config.bmAuthToken;
const goalName = config.bmGoalName;

// process.env.NODE_TLS_REJECT_UNAUTHORIZED='0' Uncomment this if you're on a corportate network

let beeminder = require('beeminder');
let bm = beeminder(auth_token);

bm.createDatapoint(goalName, {
  value: 1,
  timestamp: Math.floor(new Date().valueOf() / 1000),
  comment: '+1',
  requestid: Math.floor(new Date().valueOf() / 1000)
})
  .then((result) => {
    console.log("Datapoint created successfully:", result);
  })
  .catch((err) => {
    console.error("Error creating datapoint:", err.message);
  });
  

