"use strict";
/**
 * Module dependencies.
 */

var env = process.env.NODE_ENV || 'development';
var appEnv = process.env.ENVIRONMENT || 'development';
var fs = require('fs');

var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path')
  , model = require("./model");

var methodOverride = require('method-override')
var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser');
var morgan = require('morgan');
var serveStatic = require('serve-static');
var errorhandler = require('errorhandler');
var Promise = require("bluebird");
var app = express();
var bcrypt = require('bcrypt');
//app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.use(morgan('combined'))
  app.use(bodyParser.urlencoded({ extended: false }))
  app.use(bodyParser.json())
  app.use(cookieParser())
  //app.use(methodOverride('X-HTTP-Method-Override'))
  app.use(errorhandler())
  
  app.use(function(req, res, next){
    if (( req.path == '/login.html' ) || ( req.path == '/login' ) || ( req.path.indexOf('.js') != -1 ) || ( req.path.indexOf('.css') != -1 )){
      next();
      return;
    }
    if ( req.cookies.rcjaCookie != null ){
      return Promise.try(() => {
        let cookie = req.cookies.rcjaCookie;
        return model.User.get(cookie)
      }).then((user) => {
        req.currentUser = user;
        return next();
      }).catch((err) => {
        res.redirect('login.html');
        return res.end();
      })
    }else{
      console.log('no cookie');
      res.redirect('login.html');
      return;
    }
  });
  if (appEnv === 'production') {
    app.use(serveStatic(path.join(__dirname, './dist'), {'index': ['index.html']}));
  } else {
    app.use(serveStatic(path.join(__dirname, './app'), {'index': ['index.html']}));
  }
  
//});

var router = express.Router();
routes.mount(router);
app.use(router);
/*
app.get('/ladders', routes.Ladder.ladders);

app.get('/score_sheet', routes.ScoreSheet.list);
app.post('/score_sheet', routes.ScoreSheet.create);
app.get('/score_sheet/:scoreSheetId', routes.ScoreSheet.detail);
app.put('/score_sheet/:scoreSheetId', routes.ScoreSheet.modify);

app.get('/score', routes.SubmittedScore.list);
app.post('/score', routes.SubmittedScore.create);
app.get('/score/:submittedScoreId', routes.SubmittedScore.detail);
app.put('/score/:submittedScoreId', routes.SubmittedScore.modify);

app.get('/team', routes.Team.list);
app.post('/team', routes.Team.create);
app.get('/team/:teamId', routes.Team.detail);
app.put('/team/:teamId', routes.Team.modify);

app.get('/division', routes.Division.list);
app.post('/division', routes.Division.create);
app.get('/division/:divisionId', routes.Division.detail);
app.get('/division/:divisionId/export', routes.DanceExport.exportAll);
app.put('/division/:divisionId', routes.Division.modify);

app.get('/dance_interview', routes.DanceInterview.list);
app.post('/dance_interview', routes.DanceInterview.create);
app.get('/dance_interview/criteria', routes.Dance.interviewParameters);
app.get('/dance_interview/:danceInterviewId', routes.DanceInterview.detail);
app.put('/dance_interview/:danceInterviewId', routes.DanceInterview.modify);

app.get('/dance_performance', routes.DancePerformance.list);
app.post('/dance_performance', routes.DancePerformance.create);
app.get('/dance_performance/:dancePerformanceId', routes.DancePerformance.detail);
app.put('/dance_performance/:dancePerformanceId', routes.DancePerformance.modify);

app.post('/dance_theatre_performance', routes.DanceTheatrePerformance.create);
app.get('/dance_theatre_performance/:danceTheatrePerformanceId', routes.DanceTheatrePerformance.detail);
app.put('/dance_theatre_performance/:danceTheatrePerformanceId', routes.DanceTheatrePerformance.modify);

app.get('/dance', routes.Dance.list);
app.get('/dance/criteria', routes.Dance.parameters);
app.get('/dance_theatre', routes.DanceTheatre.list);

app.get('/dance_theatre/criteria', routes.DanceTheatre.parameters);

app.get('/user', routes.User.currentUser);

app.get('/users', routes.User.list);
app.post('/users', routes.User.create);
app.put('/users/:userId', routes.User.modify);

app.post('/login', routes.User.login);
app.get('/logout', routes.User.logout);
*/
http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

process.on('SIGINT', function() {
  process.exit();
});

process.on('SIGTERM', function() {
  process.exit();
});

