var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var index = require('./routes/index');
var users = require('./routes/users');
var voting = require('./routes/voting');

var fs = require("fs");
var contractsBuildPath = path.join(__dirname, 'build', 'contracts');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'build', 'contracts')));

app.use('/', index);
app.use('/vote', voting);
app.use('/users', users);

app.post('/contract_token', function(req, res, next) {
    // var casinoTokenContents = fs.readFileSync(path.join(contractsBuildPath, 'CasinoToken.json'));
    // res.send(JSON.parse(casinoTokenContents));
    var fileName = req.body.token;
    console.log(fileName);
    if (fileName === undefined){
        var err = new Error("File Not Found");
        err.status = 404;
        next(err);
    }
    else {
        try {
            var contractPath = path.join(contractsBuildPath, fileName);
            res.sendFile(contractPath);
        } catch (e){
            e.status = 404;
            next(e);
        }
    }
});

app.post('/register_user', function(req, res, next) {
    var account = req.body.account;

});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});


module.exports = app;
