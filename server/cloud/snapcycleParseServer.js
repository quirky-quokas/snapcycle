exports.pointToSnapServer = function() {
  let Parse = require('parse/node');
  Parse.initialize('snapcycle', 'snappy', 'QuirkyQuokkas');
  Parse.serverURL = 'http://snapcycle2.herokuapp.com/parse';
  Parse.Cloud.useMasterKey();
  return Parse;
}
