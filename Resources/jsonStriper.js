var fs = require('fs');
var args = process.argv.slice(2);

Array.prototype.diff = function(a) {
    return this.filter(function(i) {return a.indexOf(i) < 0;});
};

var filename = args[0];
fs.readFile(__dirname +'/'+ filename, function(err, data) {
  if (err) {throw err;}
  var json = JSON.parse(data);
  var rows = json.data;

  // var cs = {};
  // rows.forEach(function(row) {
  //   cs[row.category] = true;
  // });
  // console.log(Object.keys(cs));

  var titles = {
    "Fighting, Weapons and Violence": "Fighting/Weapons",
    "Character and Meme": "Characters & Memes",
    "Bird" : 'Birds',
    "Cat" : 'Cats',
    "Dog" : 'Dogs',
    "Pig" : 'Pigs',
    "Rabbit" : 'Rabbits',
    "Bear" : 'Bears',
    "Monkey" : 'Monkeys',
    "Other Animal" : 'Other Animals',
    "Hurt" : 'Hurt or Sick',
    "Cloud" : 'Clouds',
    "Food and Drink" : 'Food & Drink',
    "Friend" : 'Friends',
    "Holiday" : 'Holidays',
    "Mustache" : 'Mustaches',
    "Nose Bleed" : 'Nose Bleeds',
    "Emoticon Objects" : 'Objects & Props',
    "Emoticons with Words" : 'Words',
  };

  var meta = {
    Actions: ["Dancing", "Hugging", "Kissing", "Laughing", "Music", "Sleeping", "Flexing", "Running", "Saluting", "Thinking", "Waving", "Winking", "Writing", "Apologizing", "Crying", "Fighting/Weapons", "Giving Up", "Hiding", "Table Flipping", "Other Actions"],
    Animals: ["Birds", "Cats", "Dogs", "Pigs", "Rabbits", "Bears", "Fish", "Monkeys", "Other Animals"],
    Feelings: ["Excited", "Happy", "Love", "Confused", "Crazy", "Hungry", "Shy", "Smug", "Surprised", "Angry", "Hurt or Sick", "Sad", "Scared", "Worried"],
    MISC: ["Characters & Memes", "Clouds", "Dead", "Evil", "Food & Drink", "Friends", "Holidays", "Magic", "Meh", "Mustaches", "Nose Bleeds", "Objects & Props", "Random", "Sunglasses", "Words", "WTF", "Other"]
  };

  var whiteList = ["Emoticon Objects", "Emoticons with Words"];
  var content = {};
  for (var i=0; i< rows.length; i++) {
    var row = rows[i];
    var category = row.category && row.category[0];
    var value = row.value && row.value[0];
    if (typeof category === "string" && typeof value === "string" && (category.match(/.*Emoticons$/)) || whiteList.indexOf(category) > -1) {
      category = category.replace(/\s*Emoticons$/, "");
      if (titles[category]) {
        category = titles[category];
      }
      if (content[category] && Array.isArray(content[category])) {
        content[category].push(value);
      } else {
        content[category] = [value];
      }
    }
  }

  var metaValues = Object.keys(meta).map(function(key) {
    return meta[key];
  }).reduce(function(acc, value) {
    return acc.concat(value);
  }, []);
  console.log(metaValues.diff(Object.keys(content)));
  console.log(Object.keys(content).diff(metaValues));

  var out = {};
  Object.keys(meta).forEach(function(key) {
    out[key] = {};
    meta[key].forEach(function(category) {
      out[key][category] = content[category];
    });
  });

  fs.writeFile('compressed.json', JSON.stringify(out), function (err) {
    if (err) throw err;
    console.log('It\'s saved!');
  });
});
