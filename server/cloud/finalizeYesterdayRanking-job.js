// Point to Parse server
let Parse = require('./snapcycleParseServer.js').pointToSnapServer();
finalizeYesterdayRanking();

async function finalizeYesterdayRanking(){
  // Get yesterday by subtracting one day from today
  let yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);

  // Query for yesterday's competition
  const competitionQuery = new Parse.Query("Competition");
  competitionQuery.lessThanOrEqualTo("startDate", yesterday);
  competitionQuery.greaterThanOrEqualTo("endDate", yesterday);

  // TODO: remove? leftover from original client side code
  // Set boolean to indicate finalized
  finalizeCompetitionBoolean(competitionQuery);

  // Query for yesterday's competitors, sorted
  const competitorQuery = new Parse.Query("Competitor");
  competitorQuery.matchesQuery("competition", competitionQuery);
  competitorQuery.ascending("score");
  competitorQuery.include("user");
  competitorQuery.include("user.badges");

  // Make query and wait for response
  const sorted = await competitorQuery.find();

  // Calculate rank
  let rank = 0;
  let prevUserItems = -1;

  for (let i = 0; i < sorted.length; i++) {
    let competitor = sorted[i];
    let userItems = competitor.get("score");

    // Check for ties. Rank should only increase if the
    //current user has a different score than the
    // previous user since the users are sorted
    if (Number(prevUserItems) != Number(userItems)) {
      rank++;
    }

    // Update competitor's final rank
    competitor.set("rank", rank);
    competitor.save();

    // If user is a winner, update number of badges
    let userBadges = competitor.get("user").get("badges");
    updateBadgesBasedOnRanking(userBadges, rank);

    // Update prevUserItems for next iteration of loop
    prevUserItems = userItems;
  }
  console.log("Yesterday's results finalized");
}

function finalizeCompetitionBoolean(competitionQuery) {
  // TODO: remove? leftover from original client side code
  // Set boolean to indicate finalized
  competitionQuery.first()
    .then(function(yesterdayComp) {
      yesterdayComp.set("rankingsFinal", true);
      yesterdayComp.save();
    })
    .catch(function(error) {
      console.log(error);
    });
}

function updateBadgesBasedOnRanking(userBadges, rank) {
  if (Number(rank) == 1) {
    userBadges.increment("numFirstPlace");
  } else if (Number(rank) == 2) {
    userBadges.increment("numSecondPlace");
  } else if (Number(rank) == 3) {
    userBadges.increment("numThirdPlace");
  }
  userBadges.save();
}
