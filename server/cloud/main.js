// Cloud function used for testing
Parse.Cloud.define('hello', function(req, res) {
  return 'Hi';
});

// Cloud function used for testing
Parse.Cloud.define('test', function(req, res) {
  return 'Hi :))';
});

// parameters:
//   day- start of week
// return:
//   array of percentages (out of 100), one for each day of the week. Each
//   percentage represents the overall accuracy of disposal for the user's trash
//   items that day
Parse.Cloud.define('accuracyPercentagesForWeekStartingAtDay', async(request) => {
  // Set up start and end of day
  let startOfDay = request.params.day;
  let endOfDay = new Date();
  endOfDay.setDate(startOfDay.getDate());
  endOfDay.setHours(23,59,59,999);

  let percentages = [];

  // loop through each day of the week
  for (let i = 0; i < 7; i++) {
    // Query for user's trash for day
    const query = new Parse.Query("Trash");
    query.equalTo('user', request.user);
    query.greaterThanOrEqualTo("createdAt", startOfDay);
    query.lessThanOrEqualTo("createdAt", endOfDay);
    query.include("category");

    const trashArrayForDay = await query.find();
    percentages.push(calculatePercentAccuracy(trashArrayForDay));

    // increment to next day
    startOfDay.setDate(startOfDay.getDate() + 1);
    endOfDay.setDate(endOfDay.getDate() + 1);
  }

  return percentages;
});

// Helper method to calculate disposal accuracy given array of Trash items
// parameters:
//   trashArray- array of Trash objects to calculate percent that were correctly disposed
// return:
//   percent accuracy out of 100
function calculatePercentAccuracy(trashArray) {
  if (trashArray == undefined || trashArray.length == 0) {
    return 0;
  } else {
    let correct = 0; // number of items coreectly disposed
    for (let j = 0; j < trashArray.length; j++) {
      let trash = trashArray[j];
      let category = trash.get("category");
      let userAction = trash.get("userAction");
      if (category.get(userAction)) { // userAction matches category type
        correct++;
      }
    }
    return correct/trashArray.length * 100;
  }
}
