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


// Temp root url
app.get('/', (req, res) => {
  res.send('Hello World!')
})

// Start the server
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

