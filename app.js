//Load express module with `require` directive
var express = require('express')
var app = express()

//Define request response in root URL (/)
app.get('/', function (req, res) {
  res.send('Hello World to the entire world at one go')
})

//Launch listening server on port 8000
app.listen(8000, function () {
  console.log('App listening on port 8000!')
})
