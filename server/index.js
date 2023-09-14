const express = require('express')
const app = express()
const cors = require('cors')

app.use(cors())

const bodyParser = require('body-parser')
app.use(bodyParser.json())
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
)

// Port number
const port = 3000

// For getting the key from file
const fs = require('fs');
const key = fs.readFileSync("key.txt").toString();

// firebase
const firebase = require('firebase-admin');
const {initializeApp} = require('firebase-admin/app');
const {applicationDefault} = require('firebase-admin/app');

// Sleep function
function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

// Firebase app for sending notifs
firebaseapp = initializeApp({credential:applicationDefault()});

// Get all hotels
app.get('/hotels',(req,res) => {
   
    data = {}

    //temp create the data
    data = ["hotel a","hotel b"]

    res.send(data);
})

// Get dishes
app.get("/dishes",(req,res)=>{

    data = {}
    
    // temp create data
    name = req.query.name
    if(name == "hotel a"){
        data = [{name:"dish a",price:200,vegan:true},{name:"dish b",price:250,vegan:false}];
    }
    else{
        data = [{name:"Chicken biriyani",price:100,vegan:false},{name:"Chicken Rice",price:80,vegan:false},{name:"Mushroom Rice",price:65,vegan:true}];

    }

    res.send(data);
})

// Hotel login
app.get('/hotellogin', async(req, res) => {
    email = req.query.email
    pass = req.query.pass
    data = {}
    console.log("Hotel login");

    //temp return true
    data["Success"] = true;
    data["name"] = "hotel b";

    //temp add sleep
    await sleep(1000);
    
    data["email"]=email;
    res.send(data);
})

// User order
app.post("/order",(req,res)=>{
    console.log("post order");
    user_name = req.body.user_name;
    user_email=req.body.user_email;
    hotel_name=req.body.hotel_name;
    order_items=req.body.order_items;

    data = {}

    //send firebase notification
    const message = {
  data: {
    'user_name': user_name,
    'hotel_name':hotel_name,
    'order_items':order_items,
  },
  topic: 'order'
};
console.log(message);

// Send a message to devices subscribed to the provided topic.
    firebase.messaging().send(message)
    .then((response) => {
    // Response is a message ID string.
    console.log('Successfully sent message:', response);
        data["Success"] = true;
        res.writeHead(200, { 'Content-Type': 'application/json' });
    res.write(JSON.stringify(data));
    res.end();

  })
  .catch((error) => {
    console.log('Error sending message:', error);
      data["Success"] = false;
          res.writeHead(200, { 'Content-Type': 'application/json' });
    res.write(JSON.stringify(data));
    res.end();
  });
});

// Get all hotel orders 
app.get("/hotelorders",(req,res)=>{
    hotel_name = req.query.hotel_name;
    
    data = {}

    // temp create data
    data["123"] = {"user_name":"Sree Harshan","order_items":{"Chicken Biriyani":2,"Chicken Rice":1},"total":280,"completed":true}  
    data["124"] = {"user_name":"Dinesh","order_items":{"Chicken Biriyani":4},"total":400,"completed":false}  

    res.send(data);
});



// temp send firebase notif
app.get("/notif",(req,res)=>{
     //send firebase notification
    const message = {
  data: {
    'user_name': 'Name',
    'hotel_name':"Hotel name",
  },
  topic: 'order'
};

// Send a message to devices subscribed to the provided topic.
    firebase.messaging().send(message)
    .then((response) => {
    // Response is a message ID string.
    console.log('Successfully sent message:', response);
  })
  .catch((error) => {
    console.log('Error sending message:', error);
  });
    res.send({"Value":"Success"});
});

// Temp root url
app.get('/', (req, res) => {
  res.send('Hello World!')
})

// Start the server
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

app.on("listening",()=>{
    console.log("Listening");
});


