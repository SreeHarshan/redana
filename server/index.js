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

// Sleep function
function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

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
    data["name"] = "Hotel name";

    //temp add sleep
    await sleep(5000);
    
    data["email"]=email;
    res.send(data);
})

app.post("/order",(req,res)=>{
    user_name = req.body.user_name;
    user_email=req.body.user_email;
    hotel_name=req.body.hotel_name;
    order_items=req.body.order_items;

    data = {}

    //temp add
    data["Success"] = true;

    res.end(data);
});


// Temp root url
app.get('/', (req, res) => {
  res.send('Hello World!')
})

// Start the server
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

