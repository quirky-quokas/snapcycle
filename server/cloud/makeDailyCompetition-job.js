// Point to Parse server
let Parse = require('./snapcycleParseServer.js').pointToSnapServer();
makeDailyCompetition();

// Create competition object
function makeDailyCompetition(){
  let Competition = Parse.Object.extend("Competition");
  let newComp = new Competition();

  // Get start and end of current day
  let start = new Date();
  start.setHours(0,0,0,0);
  let end = new Date();
  end.setHours(23,59,59,999);

  newComp.set("startDate", start);
  newComp.set("endDate", end);
  newComp.set("rankingsFinal", false);

  // TODO: remove
  newComp.set("server", true);

  newComp.save({
      success: function(place){
          console.log("Competition successfully created!!");
      },
      error: function(place, error){
          console.log("Fail: " + error.message);
      }
  });
}
