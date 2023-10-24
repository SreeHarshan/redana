const express = require('express')
const app = express()
const cors = require('cors')

// Postgress db
var pg  = require('pg');
const { Pool } = require("pg");
var dbconfig = {
    user:"qzayearu",
    database:"qzayearu",
    password:"19jsuZTTkdZFFDMxksfH2svOspa-dyW9",
    host:"rain.db.elephantsql.com",
};
const pool = new Pool(dbconfig);

// Cors
app.use(cors())

const bodyParser = require('body-parser')
app.use(bodyParser.json())
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
)

// Dir
const path = require("path");
app.use(express.static('public'));

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
app.get('/hotels',async(req,res) => {
   
    data = [];

    const client = await pool.connect();
    data = await client.query("select name,address,ph_no from hotels");
    data = data['rows'];

    client.release();

    res.send(data);
})

// Get dishes
app.get("/dishes",async(req,res)=>{

    data = {}

    var name = req.query.name;
    // temp create data
    /*
    name = req.query.name
    if(name == "hotel a"){
        data = [{name:"dish a",price:200,vegan:true},{name:"dish b",price:250,vegan:false}];
    }
    else{
        data = [{name:"Chicken biriyani",price:100,vegan:false},{name:"Chicken Rice",price:80,vegan:false},{name:"Mushroom Rice",price:65,vegan:true}];

    }*/
    
    const client = await pool.connect();
    q="select dishes.name,dishes.price,dishes.stock,dishes.vegan from dishes left join hotels on dishes.hotel_id = hotels.id where hotels.name ='"+name+"'";
    out = await client.query(q);
    data = out['rows'];
    
    client.release();
    
    res.send(data);
})

// User login
app.get('/userlogin',async(req,res)=>{
    var email = req.query.email;
    var name = req.query.name;

    data = {}

    //check if user is not in db then add them
    const client = await pool.connect();
    var out = await client.query("select * from users where name='"+name+"' and email='"+email+"'");
    if(out.rowCount == 0){
        await client.query("insert into users(name,email,ph_no) values('"+name+"','"+email+"',123467890)");
    }

    data["Success"] = true;

    client.release();

    res.send(data);

});

// Hotel login
app.get('/hotellogin', async(req, res) => {
    email = req.query.email
    pass = req.query.pass
    data = {}
    console.log("Hotel login");


    const client = await pool.connect();
    out = await client.query("select * from hotels where email='"+email+"' and pass='"+pass+"'");
    client.release();
    if(out['rowCount']==1){
        data['Success'] = true;
        data['name'] = out['rows'][0]['name'];
        data['email'] = email;
    }
    else{
        data['Success'] = false;
    }

    //temp 
    data['name'] = 'Hotel A';
    data['email'] = 'hotela@gmail.com';
    data['Success'] = true;
    
    res.send(data);
})

// User order
app.post("/order",async(req,res)=>{
    console.log("post order");
    user_name = req.body.user_name;
    user_email=req.body.user_email;
    hotel_name=req.body.hotel_name;
    order_items=JSON.parse(req.body.order_items);
    total=req.body.total;

    data = {}

    const client = pool.connect();


    //get hotel_id
    q = "select id from hotels where name = '"+hotel_name+"'";
    hotel_id = await client.query(q);
    hotel_id = hotel_id['rows'][0]['id'];

    // get user_id
    q = "select id from users where name = '"+user_name+"'";
    user_id = await client.query(q);
    user_id = user_id['rows'][0]['id'];


    // create new payment entry
    payment_id = await client.query("insert into payments(status,amount) values(false,"+total+") returning id;");
    payment_id = payment_id['rows'][0]['id']; 

    // insert to orders table
    order_id = await client.query("insert into orders(payment_id,hotel_id,user_id) values("+payment_id+","+ hotel_id+","+ user_id+ ") returning id;");
    order_id = order_id['rows'][0]['id'];


    // insert into order_items table
    
    // Iterate individual order_item and add to table
    for(var item in order_items){
        dish_id = await client.query("select id from dishes where name = '"+item+"' and hotel_id = "+hotel_id);
        dish_id = dish_id['rows'][0]['id'];
        out = await client.query("insert into order_items(order_id,dish_id,quantity) values("+order_id+","+dish_id+","+order_items[item]+");"); 
    }

    client.release();

    //send firebase notification
    const message = {
  data: {
    'user_name': user_name,
    'hotel_name':hotel_name,
  },
  topic: 'order'
};

// Send a message to devices subscribed to the provided topic.
    firebase.messaging().send(message)
    .then((response) => {
    // Response is a message ID string.
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
app.get("/hotelorders",async(req,res)=>{
    hotel_name = req.query.hotel_name;
    
    data = {}

    // temp create data
//    data["123"] = {"user_name":"Sree Harshan","order_items":{"Chicken Biriyani":2,"Chicken Rice":1},"total":280,"completed":true}  
//    data["124"] = {"user_name":"Dinesh","order_items":{"Chicken Biriyani":4},"total":400,"completed":false}  


     const client = await pool.connect();
    q = "select orders.id as order_id,users.name as user_name,payments.amount as total,orders.status as completed,dishes.name as dish_name,order_items.quantity from order_items left join orders on order_items.order_id = orders.id left join payments on orders.payment_id = payments.id left join dishes on order_items.dish_id = dishes.id left join users on orders.user_id = users.id left join hotels on orders.hotel_id = hotels.id where hotels.name = '"+hotel_name+"'";
    var out = await client.query(q);
    var orders = out['rows'];
    for(var i=0;i<orders.length;i++){
        var order_id = orders[i]["order_id"].toString();
        if(!data.hasOwnProperty(order_id)){
            data[order_id] = {"user_name":orders[i]["user_name"],"completed":orders[i]["completed"],"total":orders[i]["total"],"order_items":{},"order_id":order_id};
        }
        item = orders[i]["dish_name"];
        data[order_id]["order_items"][item] = orders[i]["quantity"];

    }
    client.release();

    res.send(data);
});


// Set order as complete 
app.get("/completeorder",async(req,res)=>{
    const order_id = req.query.order_id;

    const client = await pool.connect();
    await client.query("update orders set status = not status where id = "+order_id);
    client.release();

    data = {}
    data["Success"] = true;

    res.send(data);
});

// Set stock for items
app.get("/setstock",async(req,res)=>{
    const dish_name = req.query.dish_name;
    const hotel_name = req.query.hotel_name;

    const client = await pool.connect();
    q = "update dishes set stock = not stock from hotels where dishes.hotel_id = hotels.id and hotels.name='"+hotel_name+"' and dishes.name='"+dish_name+"'";
    await client.query(q);
    client.release();

    data = {}
    data["Success"] = true;

    res.send(data);
});


// Get hotel image 
app.get("/hotelimg",async(req,res)=>{
    const fileName = req.query.hotel_name;
    const options = {
        root: path.join(__dirname)
    };


    res.sendFile("./hotelimg/"+fileName+".png",options,function(err){
        if (err) {
            console.log(err);
            res.end();
        }
    });
});

// Get all offers
app.get("/offers",async(req,res)=>{
    
    
    const client = await pool.connect();
    q = "select offers.id,hotels.name from offers left join hotels on offers.hotel_id = hotels.id";
    data = await client.query(q);
    data = data['rows'];
    
    client.release();
    
    
    for(var i=0;i<data.length;i++){
        data[i] = data[i]["name"];
    }

    res.send(data); 
});

// Offer image
app.get("/offerimg",async(req,res)=>{
    const fileName = req.query.offer;
    const options = {
        root: path.join(__dirname)
    };


    res.sendFile("./hotelimg/offer "+fileName+".png",options,function(err){
        if (err) {
            console.log(err);
            res.end();
        }
    });
});

    
// temp send firebase notif
app.get("/notif",async(req,res)=>{

    const total=req.query.total;

    const client = await pool.connect();
    payment_id = await client.query("insert into payments(status,amount) values(false,"+total+") returning id;");
    payment_id = payment_id['rows'][0]['id']; 

    client.release();

     //send firebase notification
    const message = {
  "data": {
    'user_name': 'Name',
    'hotel_name':"Hotel A",
    'order_items':'',
  },
  "topic": 'order'
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
app.get('/',async (req, res) => {
  res.send('Hello World!')
})

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`)
})

app.on("listening",()=>{
    console.log("Listening");
});


