var http = require('http');
var express = require('express');
var path = require("path");
var cors = require("cors");

// Init web server
var app = new express();
app.use(cors());

// Load static content
app.use(express.static(path.join(__dirname, 'public/')));

// Load dynamic content
app.get('/', function(request, response){
    response.sendFile(path.join(__dirname, 'index.html'));
});

// Start web server on port 80
app.listen(80);
