import { csvParse, autoType } from 'd3-dsv';
let array = ['South East', 'South West', 'East', 'West Midlands', 'East Midlands', 'North East', 'North West']
function regionThe(place, nt) {
  if (place=="East") { place = place + " England"}
  return ((!array.includes(place))|(nt=="NT")) ? place : 'The ' + place;
}

function uncap1(string) {
    if (string.slice(0, 3)=="The") {
        return string.charAt(0).toLowerCase() + string.slice(1);
    } else { return string }
}

let num_word = {'quarter of a million': 250000, 'half a million': 500000, 'three quarters of a million': 750000, 'one million': 1000000};

let frac_word = {'one in two': 0.5, 'one in three': 0.333, 'one in four': 0.25, 'one in five': 0.2, 'one in six': 0.167, 'one in seven': 0.143, 'one in eight': 0.125, 'one in nine': 0.111, '1 in 10': 0.1,'1 in 11' : 0.09, '1 in 12' : 0.083, '1 in 13' : 0.077, '1 in 14' : 0.071, '1 in 15' : 0.067, '1 in 16' : 0.063, '1 in 17' : 0.059, '1 in 18' : 0.056, '1 in 19' : 0.053 ,'1 in 20': 0.05, '2 in 10': 0.2, '3 in 10': 0.3, '4 in 10': 0.4, '6 in 10': 0.6, '7 in 10': 0.7, '8 in 10': 0.8, '9 in 10': 0.9, 'all': 1.0};


function get_word(num, dict) {
  if (dict == "frac") {
    dict = frac_word
  } else if (dict == "num") {
    dict = num_word
  }
  let OverUnder;
  let lowest = 2000000;
  let lowest_label;
  for (const label in dict) {
    if (Math.abs(num-dict[label])<lowest) {
      lowest = Math.abs(num-dict[label]) 
      lowest_label = label
      if (num-dict[label]==0) {
        OverUnder = "about"; 
      }
      else if (num-dict[label]>0) {
        OverUnder = "just over";
      }
      else if (num-dict[label]<0) {
        OverUnder = "just under";
      } } }
  return [OverUnder, lowest_label]
}
function figs(x) {
  let sigfig = Number.parseFloat(Number.parseFloat(x).toPrecision(2))
  let text;
  if (x-sigfig<-x/100) {
    text = "under "
  }	
  if (x-sigfig<-x/800) {
    if (Math.round(Math.random())==1) {
      text = "almost "
    } else {
      text = "just under "
    }
  }
  else if (x-sigfig>x/100) {
    text = " just over "
  }
  else if (x-sigfig>x/800) {
    text = "just over "
  }
  else {
    text = "about"
  }
  return [text, sigfig];
}


function cur(s, place, i, type) {
  if (type=="rl") {
    type = "_rank_local"
  } else if (type=="r") {
    type = "_rank"
  } else {
    type = ""
  }
  return place.data[s[i][0]][s[i][1]+type][2011][s[i][3]]
}

function cha(s, place, i, type) {
  if (type=="rl") {
    type = "_rank_local"
  } else if (type=="r") {
    type = "_rank"
  } else {
    type = ""
  }
  return place.data[s[i][0]][s[i][1]+type]['change'][s[i][3]]
}

function qui(n) {
  return Math.ceil(5*n/331)
}

function otherEst(s, place, i, hiLo, type) {
  if (typeof hiLo==="number" & hiLo<0) {
    hiLo = "highest"
  } else if (typeof hiLo==="number") {
    hiLo = "lowest"
  }
  
  let optAr = Object.assign({}, place.data[s[i][0]][s[i][1]+'_rank_local'][type]);
  let l = new Set(chains[s[i][3]])

  for (let prop of Object.keys(optAr)) {
    if (!l.has(prop)) {
      delete optAr[prop];
    }
  }
  let optArKey
  if (Object.keys(optAr).length>1) {
    if (hiLo=='lowest') {
      for (let [k, v] of Object.entries(optAr)) {
        if (v > 0) {
          delete optAr[k];
        }
      }
      if (optAr.length>0) {
        optArKey = Object.keys(optAr).reduce((a, b) => optAr[a] > optAr[b] ? a : b);
      } else {
        optArKey = undefined
      }
      
    }
    if (hiLo=='highest') {
      for (let [k, v] of Object.entries(optAr)) {
        if (v < 0) {
          delete optAr[k];
        }
      }
      if (optAr.length>0) {
        optArKey = Object.keys(optAr).reduce((a, b) => optAr[a] < optAr[b] ? a : b);
      } else {
        optArKey = undefined
      }
    }
  } else {
    optArKey = Object.keys(optAr)
  }
  return optArKey
}

function otherRank(s, place, i, t="r") {
  let locExt = ""
  if (t=="rl") {
    locExt = "_local"
  }
  return place.data[s[i][0]][s[i][1]+'_rank'+locExt]['change'][otherEst(s, place, i, cha(s, place, i, t), 'change')]
}

function ud(n, w1, w2) { if (n<0) { return w2 } else { return w1 } }
var city
if (parent=="London") {
  city = "city"
} else {
  city = "region"
}


var ones = ['', '', 'second-', 'third-', 'fourth-', 'fifth-', 'sixth-', 'seventh-', 'eighth-', 'ninth-'];

function suffixer(int) {
  let ord
  if (int==12) {
    ord = 'twelfth'
  } else if ((int>10)&(int<20)) {
    ord = int+"th"
  } else {
    let mod = Math.round(int) % 10;
    ord = mod == 1 ? int+'st' : mod == 2 ? int+'nd' : mod == 3 ? int+'rd' : int+'th';
  }
  return ord
}

function ord(x) {
  console.log("X", x)
  let ordin
  if (Math.abs(x)<10) {
    ordin = ones[Math.abs(x)]
  } else {
    ordin = suffixer(Math.abs(x))+"-"
  }
  return ordin
}


async function getData(url) {
  let response = await fetch(url);
  let string = await response.text();
	let data = await csvParse(string, autoType);
  return data;
}

export { uncap1, regionThe, ud, otherRank, otherEst, qui, cha, cur, figs, get_word, ord, getData };