var http = require('http');
var express = require('express');
var app = new express();
var path = require("path");

require("./snmp.js")

app.use(express.static(path.join(__dirname, 'public/')));

app.get('/', function(request, response){
    response.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(8080);
