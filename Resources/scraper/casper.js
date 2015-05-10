/*
result = [
  {
    name: ...
    values: [
      {
        name: ...
        values: [...]
      }
    ]
  }
]
*/

var casper = require('casper').create({
  pageSettings: {
    // javascriptEnabled: false,
    loadImages: false
  }
});
var fs = require('fs');

function getCategoriesAndLinks() {
  var categories = [];
  var links = {};
  var addLink = function (a) {
    var link = a.getAttribute("href");
    if (link !== "#") {
      links[a.innerText] = link;
    }
  };
  var primaryCategories = Array.prototype.slice.call(document.querySelectorAll("#menu-main-menu > li"));
  primaryCategories.pop();
  categories = primaryCategories.map(function(a) {
    var secondaryCategories = Array.prototype.map.call(a.querySelectorAll("#"+a.id+" > ul > li"), function(aa) {
      var categories = Array.prototype.map.call(aa.querySelectorAll("#"+aa.id+" > ul > li > a"), function(aaa) {
        addLink(aaa);
        return aaa.innerText;
      });
      addLink(aa.querySelector("a"));
      var secondaryCategoryName = aa.querySelector("a").innerText;
      if (categories.length === 0) {
        categories = [secondaryCategoryName];
      }
      return {
        name: secondaryCategoryName,
        values: categories
      };
    });
    return {
      name: a.querySelector("a").innerText,
      values: secondaryCategories
    };
  });

  return {
    categories: categories,
    links: links
  };
}

function getEmoticons() {
  var tds = Array.prototype.filter.call(document.querySelectorAll(".entry-content td"), function(td) {
    return td.style["text-align"] === "center";
  });
  var emoticons = Array.prototype.map.call(tds, function(td) {
    return td.innerText;
  }).filter(function(value) {
    return value !== "";
  });
  return emoticons;
}

var result = {
  categories: [],
  emoticons: {}
};
var links = {};

casper.start('http://japaneseemoticons.me/', function() {
  var ret = this.evaluate(getCategoriesAndLinks);
  result.categories = ret.categories;
  links = ret.links;
  console.log("About to scrape: "+Object.keys(links));
});

casper.then(function() {
  var keys = Object.keys(links);
  this.eachThen(keys, function(response) {
    var title = response.data;
    var url = links[title];
    this.echo("Finished: "+title+" "+(keys.indexOf(title)+1)+"/"+(keys.length));
    this.thenOpen(url, function() {
      result.emoticons[title] = this.evaluate(getEmoticons);
    });
  });
});

casper.then(function() {
    this.echo("Finished All with "+Object.keys(result.emoticons).length+" categories and "+Object.keys(result.emoticons).reduce(function(acc, name) {return acc+result.emoticons[name].length;}, 0)+" emoticons.");
    fs.write('result.json', JSON.stringify(result), 'w');
});

casper.run();
