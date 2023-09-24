const express = require('express')
const app = express()
const cors = require('cors')


var pg  = require('pg');
var dbstring = "postgres://qzayearu:19jsuZTTkdZFFDMxksfH2svOspa-dyW9@rain.db.elephantsql.com/qzayearu";

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
app.get('/hotels',async(req,res) => {
   
    data = [];

    const client = new pg.Client(dbstring);
    await client.connect()
    out = await client.query("select name from hotels");
    for(let i=0;i< out['rows'].length;i++){
        data.push(out['rows'][i]['name']);
    }
    console.log(out['rows']);
    await client.end();

    res.send(data);
})

// Get dishes
app.get("/dishes",async(req,res)=>{

    data = {}

    var name = req.query.name;
    console.log(name);
    // temp create data
    /*
    name = req.query.name
    if(name == "hotel a"){
        data = [{name:"dish a",price:200,vegan:true},{name:"dish b",price:250,vegan:false}];
    }
    else{
        data = [{name:"Chicken biriyani",price:100,vegan:false},{name:"Chicken Rice",price:80,vegan:false},{name:"Mushroom Rice",price:65,vegan:true}];

    }*/
    
    const client = new pg.Client(dbstring);
    await client.connect()
    q = "select id from hotels where name = '"+name+"'";
    hotel_id = await client.query(q);
    hotel_id = hotel_id['rows'][0]['id'];
    console.log(hotel_id);
    out = await client.query("select * from dishes where hotel_id = "+hotel_id.toString());
    data = out['rows'];
    await client.end();

    res.send(data);
})

// User login
app.get('/userlogin',async(req,res)=>{
    var email = req.query.email;
    var name = req.query.name;

    data = {}

    //TODO check if user is not in db then add them
     
    const client = new pg.Client(dbstring);
    await client.connect()
    var out = await client.query("select * from users where name='"+name+"' and email='"+email+"'");
    if(out.rowCount == 0){
        await client.query("insert into users(name,email,ph_no) values('"+name+"','"+email+"',123467890)");
    }

    data["Success"] = true;

    res.send(data);

});

// Hotel login
app.get('/hotellogin', async(req, res) => {
    email = req.query.email
    pass = req.query.pass
    data = {}
    console.log("Hotel login");


    const client = new pg.Client(dbstring);
    await client.connect()
    out = await client.query("select * from hotels where email='"+email+"' and pass='"+pass+"'");
    await client.end();

    if(out['rowCount']==1){
        data['Success'] = true;
        data['name'] = out['rows'][0]['name'];
        data['email'] = email;
    }
    else{
        data['Success'] = false;
    }
    
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

    const client = new pg.Client(dbstring);
    await client.connect()


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
    console.log(order_items);
    for(var item in order_items){
        dish_id = await client.query("select id from dishes where name = '"+item+"' and hotel_id = "+hotel_id);
        dish_id = dish_id['rows'][0]['id'];
        console.log(order_id,dish_id,order_items[item]);
        out = await client.query("insert into order_items(order_id,dish_id,quantity) values("+order_id+","+dish_id+","+order_items[item]+");"); 
    }

    await client.end();





    //send firebase notification
    const message = {
  data: {
    'user_name': user_name,
    'hotel_name':hotel_name,
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
app.get("/hotelorders",async(req,res)=>{
    hotel_name = req.query.hotel_name;
    
    data = {}

    // temp create data
//    data["123"] = {"user_name":"Sree Harshan","order_items":{"Chicken Biriyani":2,"Chicken Rice":1},"total":280,"completed":true}  
//    data["124"] = {"user_name":"Dinesh","order_items":{"Chicken Biriyani":4},"total":400,"completed":false}  


    // TODO this
     const client = new pg.Client(dbstring);
    await client.connect()
    q = "select id from hotels where name = '"+hotel_name+"'";
    hotel_id = await client.query(q);
    hotel_id = hotel_id['rows'][0]['id'];
    out = await client.query("select * from orders where hotel_id = "+hotel_id.toString());
    var orders = out['rows'];
    for(var i=0;i<orders.length;i++){
        
        // get user_name
        user_name = await client.query("select name from users where id = "+orders[i]['user_id']);
        user_name = user_name['rows'][0]['name'];

        // get order items,quantity
        order_items = await client.query("select dish_id,quantity from order_items where order_id="+orders[i]['id']); 
        out = order_items['rows']
        order_items = {}
        for(var j=0;j<out.length;j++){
            var dish_name = await client.query("select name from dishes where id = "+out[j]['dish_id']);
            dish_name = dish_name['rows'][0]['name'];
            order_items[dish_name] = out[j]['quantity'];
        }
        var id = orders[i]['id']
        out = await client.query("select status,amount from payments where id = "+orders[i]["payment_id"]);
        out = out["rows"][0];
        data[id.toString()] = {"user_name":user_name,"total":out["amount"],"completed":out["status"],"order_items":order_items};
        console.log(out);
    }
    await client.end();

    res.send(data);
});



// temp send firebase notif
app.get("/notif",async(req,res)=>{

    const total=req.query.total;

    const client = new pg.Client(dbstring);
    await client.connect()
    payment_id = await client.query("insert into payments(status,amount) values(false,"+total+") returning id;");
    payment_id = payment_id['rows'][0]['id']; 
    console.log(out);
    await client.end();



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


