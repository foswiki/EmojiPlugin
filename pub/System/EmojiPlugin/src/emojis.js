/* Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
 
  EmojiPlugin is Copyright (C) 2021-2025 Michael Daum http://michaeldaumconsulting.com
 
  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details, published at
  http://www.gnu.org/copyleft/gpl.html
*/

"use strict";

(function() {

var defaults = {
  iconSet: "twitter",
  limit: 5,
  skip: 0,
  category: null
};

var Emojis = {
  'search': function(term, params) {
    var result = [], i = 0, entry;

    term = term.trim();
    params = { ...defaults, ...params};

    //console.log("params=",params);

    for (let key in Emojis._Database) {
      entry = Emojis._Database[key];

      if (params.category && entry.category != params.category) {
        continue;
      }

      if (term && !entry.id.match(term)) {
        continue;
      }

      i++;
      if (params.skip && params.skip >= i) {
        continue;
      }

      result.push(entry);

      if (result.length >= params.limit) {
        break;
      }
    }

    return result;
  },

  "get": function(term) {
    var entry, alias, id;

    term = term.trim();
    id = term.replace(/^:(.*?):$/, "$1");
    entry = Emojis._Database[term] || Emojis._Database[id];
    if (entry) {
      return entry;
    }

    alias = Emojis._Aliases[term] || Emojis._Aliases[id];
    if (alias) {
      return Emojis._Database[alias];
    }
  },

  "getBasePath": function() {
    if (!Emojis._basePath) {
      Emojis._basePath  = foswiki.getPubUrlPath("System", "EmojiPlugin", "img") + "/twitter";
    }
    return Emojis._basePath;
  },

  "getUrl": function(term) {
    var  entry = Emojis.get(term.trim());

    return entry ? Emojis.getBasePath() + "/" + entry.image: null;
  }
};


// export
window.Emojis = Emojis;

})();
