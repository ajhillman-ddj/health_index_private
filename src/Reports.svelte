<script>
	import { regionThe, uncap1, uncap, getData, ord, ud, otherRank, otherEst, qui, cha, cur, figs, get_word } from "./utils";
	
	import Select from "./ui/Select.svelte";
	import { load } from "archieml";
	import robojournalist from 'robojournalist';
	import { LineChart, ScatterChart, BarChart } from './@onsvisual/svelte-charts';
	import * as d3 from 'd3';

	var selected, place, region, england, props, subDist;

	import * as someJSON from '../data/healthindexdata.json';
	import * as someregJSON from '../data/healthindexregdata.json';

	import * as indisJSON from '../data/indis.json';
	import * as indikeyJSON from '../data/indikey.json';
	import * as domluJSON from '../data/domlu.json';
	import * as indluJSON from '../data/indlu.json';

	$: domLU = domluJSON.default
	let indis;
	$: if (place) {
		indis = indisJSON.default[place.area]
	}
	$: indikey = indikeyJSON.default
	$: indLU = indluJSON.default
	$: console.log('Indicator Lookup', indLU)
	
	function capi(s) {
		return s.charAt(0).toUpperCase() + s.slice(1);
	}

	$: data = someJSON.default
	$: if (place) {
		region = someregJSON.default[place.region.code]
		england = someregJSON.default['E92000001']
		console.log('England', england)
		console.log('region', region)
	}
	let options2 = []
	$: if (data) {
		Object.keys(data).forEach(e => {
			options2.push({ 'code': data[e]['area'], 'name': capi(data[e]['name']) })
		}) 
		options2 = options2.sort((a, b) => { 
			if(a.name < b.name) { return -1; }
			if(a.name > b.name) { return 1; }
			return 0;
		 })
	}

	function topbotnp(i, yr, sto) {
		let x = ""
		if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) > 0.4) {
			x = x + 'close to average'
		} else {
			if (place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank>0) {
				x = x + "top"
			} else {
				x = x + "bottom"
			}
			if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.05) {
				x = x + 0.05
			} 
			else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.1) {
				x = x + 0.1
			}
			else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.15) {
				x = x + 0.15
			}
			else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.2) {
				x = x + 0.2
			}
			else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.25) {
				x = x + 0.25
			}
			else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.3) {
				x = x + 0.3
			}
			else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.4) {
				x = x + 0.4
			}
			else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.5) {
				x = x + 0.5
			}
		}
		return x
	}

	selected = {code: "E07000124", name: 'Ribble Valley'}
	// selected = {code: "E07000223", name: 'Adur'}
	$: place = data[selected.code]
	$: subDomains = place.stories
	$: console.log('Place', place)

	var template = `
h2
  if (place.data.Overall.total[2019].rank==1)
    | #[+value(place.name)] has the highest Health Index score across England 
  else if (place.data.Overall.total[2019].rank==307)
    | #[+value(place.name)] has the lowest Health Index score across England 
  else
    | Health in #[+value(place.name)]
    if ((place.data.Overall.total[2019].rank>122)&(place.data.Overall.total[2019].rank<185))
      | close to the national average
    else if (place.data.Overall.total[2019].rank<184)
      | top
      if (place.data.Overall.total[2019].rank/307 < 0.05)
        | #[+value(Math.ceil((place.data.Overall.total[2019].rank/307)*100)/100, {'FORMAT': '0%'})]
      else if (place.data.Overall.total[2019].rank/307 < 0.1)
        | #[+value(0.1, {'FORMAT': '0%'})]
      else if (place.data.Overall.total[2019].rank/307 < 0.2)
        | #[+value(0.2, {'FORMAT': '0%'})]
      else if (place.data.Overall.total[2019].rank/307 < 0.25)
        | #[+value(0.25, {'FORMAT': '0%'})]
      else if (place.data.Overall.total[2019].rank/307 < 0.3)
        | #[+value(0.3, {'FORMAT': '0%'})]    
      else if (place.data.Overall.total[2019].rank/307 < 0.4)
        | #[+value(0.4, {'FORMAT': '0%'})]
      else if (place.data.Overall.total[2019].rank/307 < 0.5)
        | #[+value(0.5, {'FORMAT': '0%'})]
    else if (place.data.Overall.total[2019].rank>185)
      | bottom
      if ((1-(place.data.Overall.total[2019].rank/307))<0.05)
        | #[+value(Math.ceil((1-(place.data.Overall.total[2019].rank/307))*100)/100, {'FORMAT': '0%'})]
      else if ((1-(place.data.Overall.total[2019].rank/307))<0.1)
        | #[+value(0.1, {'FORMAT': '0%'})]
      else if ((1-(place.data.Overall.total[2019].rank/307))<0.2)
        | #[+value(0.2, {'FORMAT': '0%'})]
      else if ((1-(place.data.Overall.total[2019].rank/307))<0.25)
        | #[+value(0.25, {'FORMAT': '0%'})]
      else if ((1-(place.data.Overall.total[2019].rank/307))<0.3)
        | #[+value(0.3, {'FORMAT': '0%'})]
      else if ((1-(place.data.Overall.total[2019].rank/307))<0.4)
        | #[+value(0.4, {'FORMAT': '0%'})]
      else if ((1-(place.data.Overall.total[2019].rank/307))<0.5)
        | #[+value(0.5, {'FORMAT': '0%'})]
    | across England

p#subhead
  - var cha1 = place.data.Overall.total[2019].value - place.data.Overall.total[2018].value
  | #[+value(place.name)]'s Health Index score
  if ( Math.abs(cha1) < 0.3 )
    | remained relatively stable in the year before the coronavirus pandemic.
  else
    if ( cha1 < 0 )
      | decreased
    else
      | increased
    if ( Math.abs(cha1) > 2 )
      | considerably
    else if ( Math.abs(cha1) < 0.8 )
      | slightly
    | in the year before the coronavirus pandemic.

div#co-box
  if (place.data.Overall.total[2019].value>100)
    div#callout-bigno4d
      p
        | #[+value(place.data.Overall.total[2019].value, {'FORMAT': '0.0'})]
  else
    div#callout-bigno3d
      p
        | #[+value(place.data.Overall.total[2019].value)]
  div#callout-text
    p
      - var locChange = place.data.Overall.total[2019].value - place.data.Overall.total[2018].value
      - var engChange = england.data.Overall.total[2019].value - england.data.Overall.total[2018].value
      | #[+value(place.name)] has an overall Health Index score of #[+value(place.data.Overall.total[2019].value, {'FORMAT': '0.0'})],
      if (cha1==0)
        | which means it remains unchanged
      else
        | which is #[+value((cha1<0)? 'down' : 'up' )]
        | #[+value(Math.abs(locChange), {'FORMAT': '0.0'})] 
        | points 
      | compared with the previous year.

div#co-box
  div#callout-bigno3d
    p
      | #[+value(place.data.Overall.total[2019].rank, {'ORDINAL_NUMBER':true })]
  div#callout-text
    p
      | The area is ranked
      if (place.data.Overall.total[2019].rank != 1)
        | #[+value(place.data.Overall.total[2019].rank, {'ORDINAL_NUMBER':true })]
      | most healthy out of 307 local authority areas in England,
      | according to newly released data from 2019.

p#score
  | A score of 100 equates to the average across England when the index was first calculated in 2015.

mixin firstrank(i, met)
  if (Math.abs(sto[i][met])>5)
    | !{place.name}'s score for health relating to 
    | #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")] is 
    if ( sto[i]['value'] > england.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value + 1 )
      | above
    else if ( sto[i]['value'] < england.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value - 1 )
      | below 
    else
      | close to
    | the average across England
  else
    | #[+value(place.name)]
    | has !{parent}'s
    if (Math.abs(sto[i][met+"_Reg"])!=1)
      | #[+value(Math.abs(sto[i][met+"_Reg"]), {'ORDINAL_TEXTUAL':true})]
    if (sto[i][met]>0)
      if (negs.includes((sto[i].metric).toLowerCase()))
        | best score for
      else
        | highest score for
    else
      if (negs.includes((sto[i].metric).toLowerCase()))
        | worst score for
      else
        | lowest score for
    | health relating to 
    | #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")]

mixin firstchange(i, met)
  | #[+value(place.name)]
  if (Math.abs(sto[i][met])>5)
    | 's Health Index value for #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")]
    if (sto[i][met.split(" ")[0]] > 0)
      | improved
    else
      | worsened
    if (met=="Change1year Rank")
      | by #[+value(Math.abs(sto[i]['Change1year']))] points
      | between 2018 and 2019
    else if (met=="Change4year Rank")
      | by #[+value(Math.abs(sto[i]['Change4year']))] points
      | in the four years between 2015 and 2019
  else
    | saw England’s
    if (Math.abs(sto[i][met])>1)
      | #[+value(Math.abs(sto[i][met]), {'ORDINAL_TEXTUAL':true})]
    | greatest #[+value((sto[i][met]>0)?'improvement':'decline')] in
    | health relating to #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")]
    if (met=="Change1year Rank")
      | between 2018 and 2019
    else if (met=="Change4year Rank")
      | in the four years between 2015 and 2019

mixin firstfirst(i, met)
  | Health in #[+value(place.name)] is strongest among measures relating to the 
  | #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")] subdomain

mixin firstSen(i, met)
  if (i==0)
    | #[+firstfirst(i, met)]
  else if (met=="rank")
    | #[+firstrank(i, met)]
  else
    | #[+firstchange(i, met)]

mixin subd(i)
  | #[+value("&quot"+(sto[i].metric)+"&quot")] 
  synz {mode:'sequence'}
    syn
      | looks at
    syn
      | addresses
  if (twoindis.includes(sto[i].metric))
    eachz indic in indLU[sto[i].metric] with { separator:',', last_separator:' and' }
      | #[+value(uncap(indikey[indic]))]
  else
    eachz indic in indLU[sto[i].metric] with { separator:',', last_separator:', and' }
      | #[+value(uncap(indikey[indic]))]
  | .

mixin accessfirst(i)
  | #[+value(place.name)] has a Health Index score of 
  | #[+value(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value, {'FORMAT': '0.0'})]
  | for #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")]. 
  | The average across #[+value(parent)] is 
  | #[+value(region.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value, {'FORMAT': '0.0'})],
  | while England has a score of 
  | #[+value(england.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value, {'FORMAT': '0.0'})].

mixin access(i)
  | #[+value(place.name)] scored particularly low for
  | #[+value(indiSort(indis[sto[i].metric], -1, 'rank')[0])]
  | , with an index value of 
  | #[+value(indiSort(indis[sto[i].metric], -1, 'rank')[1])].
  if ( ['Access to services'].includes(sto[i].metric) )
    | The highest scoring indicator for this subdomain is 
    | #[+value(indiSort(indis[sto[i].metric], 0, 'rank')[0])]
    | , which has an index value of 
    | #[+value(indiSort(indis[sto[i].metric], 0, 'rank')[1])].
  else 
    | The index value for
    | #[+value(indiSort(indis[sto[i].metric], 0, 'rank')[0])]
    | in #[+value(place.name)] is
    | #[+value(indiSort(indis[sto[i].metric], 0, 'rank')[1])].

mixin topBot(i, yr)
  if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) > 0.4)
    | close to average
  else
    if (place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank>0)
      | in the top
    else
      | in the bottom
    if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.05)
      | #[+value((Math.ceil(Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank)*100/307)/100), {'FORMAT': '0%'})]
    else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.1)
      | #[+value(0.1, {'FORMAT': '0%'})]
    else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.15)
      | #[+value(0.15, {'FORMAT': '0%'})]
    else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.2)
      | #[+value(0.2, {'FORMAT': '0%'})]
    else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.25)
      | #[+value(0.25, {'FORMAT': '0%'})]
    else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.3)
      | #[+value(0.3, {'FORMAT': '0%'})]
    else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.4)
      | #[+value(0.4, {'FORMAT': '0%'})]
    else if (Math.abs(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[yr].rank/307) < 0.5)
      | #[+value(0.5, {'FORMAT': '0%'})]

mixin secondSenfirst(i, met)
  | #[+value(place.name)]'s highest score across all subdomains is 
  | #[+value(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value, {'FORMAT': '0.0'})]
  | for health relating to #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")].

mixin secondSenA(i, met)
  - var subchaa = place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value - ((met=="Change1year Rank")?place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2018].value:place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2015].value)
  - var actrankaa = ((met=="Change1year Rank")?place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2018].rank:place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2015].rank)
  - if (actrankaa<0) { actrankaa = actrankaa +308}
  - var actrankba = place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].rank
  - if (actrankba<0) { actrankba = actrankba +308}
  - var subrankchaa = actrankba - actrankaa
  | Between #[+value((met=="Change1year Rank")?'2018':'2015')] and 2019,
  | #[+value(place.name)]'s Health Index value for #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")] 
  if (subchaa==0)
    | remained close
  else
    | went from 
    if (met=="Change1year Rank")
      | #[+value(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2018].value, {'FORMAT': '0.0'})]
    else
      | #[+value(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2015].value, {'FORMAT': '0.0'})]
  | to #[+value(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value, {'FORMAT': '0.0'})].
  if ((Math.sign(subchaa) != Math.sign(subrankchaa)) | (subchaa==0))
    | This means 
  else 
    | Despite the #[+value( (subchaa>0)? "increase" : "decrease" )],
  | #[+value(place.name)]
  if (met=="Change1year Rank")
    if ( topbotnp(i, 2018, sto) != topbotnp(i, 2019, sto) )
      | went from being #[+topBot(i, 2018)] to being
    else
      | remained
    | #[+topBot(i, 2019)] 
  else
    if ( topbotnp(i, 2015, sto) != topbotnp(i, 2019, sto) )
      | went from being #[+topBot(i, 2015)] to being
    else
      | remained
    | #[+topBot(i, 2019)]
  |for this subdomain.


mixin secondSenB(i, met)
  - var subcha = place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value - ((met=="Change1year Rank")?place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2018].value:place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2015].value)

  - var actranka = ((met=="Change1year Rank")?place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2018].rank:place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2015].rank)
  - if (actranka<0) { actranka = actranka +308}
  - var actrankb = place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].rank
  - if (actrankb<0) { actrankb = actrankb +308}
  - var subrankcha = actrankb - actranka
  | #[+value(place.name)]'s score for #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")] 
  if (subcha==0)
    | remained close to 
    | #[+value(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value, {'FORMAT': '0.0'})]
  else
    | #[+value( (subcha>0)? "improved" : (Math.abs(subcha)<0.4)?"decreased":"fell" )]
    | from 
    if (met=="Change1year Rank")
      | #[+value(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2018].value, {'FORMAT': '0.0'})] in 2018
    else
      | #[+value(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2015].value, {'FORMAT': '0.0'})] in 2015
    | to #[+value(place.data[domLU[sto[i].metric]].subdomains[sto[i].metric].total[2019].value, {'FORMAT': '0.0'})] in 2019.
  if ((Math.sign(subcha) != Math.sign(subrankcha)) | (subcha==0))
    | This means 
  else 
    | Despite the #[+value( (subcha>0)? "increase" : "decrease" )],
  | #[+value(place.name)]
  if (met=="Change1year Rank")
    if ( topbotnp(i, 2018, sto) != topbotnp(i, 2019, sto) )
      | went from being #[+topBot(i, 2018)] to being
    else
      | remained
    | #[+topBot(i, 2019)] 
  else
    if ( topbotnp(i, 2015, sto) != topbotnp(i, 2019, sto) )
      | went from being #[+topBot(i, 2015)] to being
    else
      | remained
    | #[+topBot(i, 2019)]
  | across England for this subdomain.

mixin secondSen(i, met)
  synz {mode:'sequence'}
    syn
      | #[+secondSenB(i, met)]
    syn
      | #[+secondSenA(i, met)]


mixin declineImp(i, change, index, impDec)
  //- - console.log("********")
  //- - console.log(' - - > > ',sto[i].metric)
  //- - console.log('change', change)
  //- - console.log('impDec', impDec)
  //- - console.log('indis[sto[i].metric]', indiSort(indis[sto[i].metric], 0, change))
  //- - console.log('indis[sto[i].metric', indis[sto[i].metric])
  - var poscha = indiSort(indis[sto[i].metric], index, change)[1]
  - var negcha = indiSort(indis[sto[i].metric], (-1-index), change)[1]
  if ((impDec=="improvement")&(poscha>0.5))
    | #[+value((index!=0)?'and':'')]
    if (negs.includes(indiSort(indis[sto[i].metric], index, change)[0]))
      | a decrease in
      | #[+value(indiSort(indis[sto[i].metric], index, change)[0])]
      | (the index improved by #[+value(poscha, {'FORMAT': '0.0'})] points)
    else
      | improvements in
      | #[+value( indiSort(indis[sto[i].metric], index, change)[0] )]
      | (an increase of #[+value( Math.abs(poscha), {'FORMAT': '0.0'})])
  else if (negcha<0.5)
    | #[+value((index!=0)?'and':'')]
    if (negs.includes(indiSort(indis[sto[i].metric], (-1-index), change)[0]))
      | an increase in
      | #[+value(indiSort(indis[sto[i].metric], (-1-index), change)[0])]
      | (index worsened by #[+value(Math.abs(negcha), {'FORMAT': '0.0'})] points)
    else
      | a decline in
      | #[+value(indiSort(indis[sto[i].metric], (-1-index), change)[0])]
      | (a decrease of #[+value(Math.abs(negcha), {'FORMAT': '0.0'})])

mixin however(i, change, impDec)
  if (impDec=="improvement")
    if ( indiSort(indis[sto[i].metric], -1, change)[1] < 0 )
      if (negs.includes(indiSort(indis[sto[i].metric], -1, change)[0]))
        | . However there was also an increase in
        | #[+value(indiSort(indis[sto[i].metric], -1, change)[0])]
        | (index worsened by #[+value(Math.abs(indiSort(indis[sto[i].metric], -1, change)[1]), {'FORMAT': '0.0'})] points)
      else
        | . However there was a decline in
        | #[+value(indiSort(indis[sto[i].metric], -1, change)[0])]
        | (a deacrease of #[+value(Math.abs(indiSort(indis[sto[i].metric], -1, change)[1]), {'FORMAT': '0.0'})])
  else
    if (indiSort(indis[sto[i].metric], -1, change)[1]>0)
      if (negs.includes(indiSort(indis[sto[i].metric], -1, change)[0]))
        | . However there was an improvement in
        | #[+value(indiSort(indis[sto[i].metric], 0, change)[0])]
        | (an increase of #[+value(indiSort(indis[sto[i].metric], 0, change)[1], {'FORMAT': '0.0'})])
      else
        | . However there was an decrease in
        | #[+value(indiSort(indis[sto[i].metric], 0, change)[0])]
        | (the index improved by #[+value(indiSort(indis[sto[i].metric], 0, change)[0], {'FORMAT': '0.0'})] points)

mixin driven(i, change, impDec)
  | #[+declineImp(i, change, 0, impDec)]
  | #[+declineImp(i, change, 1, impDec)]
  | #[+however(i, change, impDec)]
  | .

mixin lastSen(i, met)
  - var imprDecl = (met == 'rank') ? ( (sto[i]['Change4year']>0) ? 'improvement' : 'decline' ) : ( (sto[i][met.split(" ")[0]]>0) ? 'improvement' : 'decline' )
  | The change was largely driven by
  if (met=="Change1year Rank")
    | #[+driven(i, "Change1year", imprDecl)]
  else
    | #[+driven(i, "change4year", imprDecl)]

mixin chartTitle(i, met)
  | #[+firstSen(i, met)]

mixin chartSubTitle(i, met)
  if (i==0)
    | Health Index values for each subdomain in #[+value(place.name)], 2019
  else if (met=="rank")
    | Health Index values for the #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")] subdomain 
    | across local authority areas in #[+value(parent)] and 
    | the average across England, 2019
  else 
    | Health Index values for the #[+value("&quot"+(sto[i].metric).toLowerCase()+"&quot")] subdomain, 
    | #[+value(place.name)], #[+value(parent)] and England,
    | 2015 to 2019

mixin thirdfirst(i, met)
  | The second highest scoring subdomain is #[+value("&quot"+ (orda[1].metric.toLowerCase()) +"&quot")], 
  | while #[+value(place.name)]'s worst score is for 
  | #[+value("&quot"+ (orda[orda.length-1].metric.toLowerCase()) +"&quot")].

- console.log('sto[0]', sto[0])
- console.log('sto[1]', sto[1])
- console.log('sto[2]', sto[2])
- console.log('sto[3]', sto[3])
mixin para(i, met)
  if (i == 0)
    p #[+secondSenfirst(i, met)]
    p #[+subd(i, met)]
    p #[+thirdfirst(i, met)]
  else if ( ['Access to green space', 'Access to services'].includes(sto[i].metric) )
    p #[+accessfirst(i, met)]
    p #[+subd(i, met)]
    p #[+access(i, met)]
  else
    p #[+subd(i, met)]
    p #[+secondSen(i, met)]
    p #[+lastSen(i, met)]

if (sto.length>0)
  - var met = whichMet(sto[0])
  if ( ['Access to green space', 'Access to services'].includes( sto[0].metric ) )
    - met = "rank"
  h4 #[+chartTitle(0, met)]
  h5 #[+chartSubTitle(0, met)]
  div#esc123
  div#catchthisdivforchart1
  div#legend1
  div#info1
  div#chart1
    h6 Source: Office for National Statistics – Health Index for England
  div#source1
  p #[+para(0, met)]
  div.funky
if (sto.length>1)
  - var met = whichMet(sto[1])
  if ( ['Access to green space', 'Access to services'].includes( sto[1].metric ) )
    - met = "rank"
  h4 #[+chartTitle(1, met)]
  h5 #[+chartSubTitle(1, met)]
  div#esc123
  div#legend2
  div#info2
  div#chart2
    h6 Source: Office for National Statistics – Health Index for England
  div#source2
  p #[+para(1, met)]
  div.funky
if (sto.length>2)
  - var met = whichMet(sto[2])
  if ( ['Access to green space', 'Access to services'].includes( sto[2].metric ) )
    - met = "rank"
  h4 #[+chartTitle(2, met)]
  h5 #[+chartSubTitle(2, met)]
  div#esc123
  div#legend3
  div#info3
  div#chart3
    h6 Source: Office for National Statistics – Health Index for England
  div#source3
  p #[+para(2, met)]
  div.funky
if (sto.length>3)
  - var met = whichMet(sto[3])
  if ( ['Access to green space', 'Access to services'].includes( sto[3].metric ) )
    - met = "rank"
  h4 #[+chartTitle(3, met)]
  h5 #[+chartSubTitle(3, met)]
  div#esc123
  div#legend4
  div#info4
  div#chart4 
    h6 Source: Office for National Statistics – Health Index for England
  div#source4
  p #[+para(3, met)]
  div.funky
  h2 Creating this content
  p This article was created using methods of semi-automated journalism. The topics were selected and the text generated based on rules preprogrammed by ONS staff prior to the release of data.
`

    // fetch("text/template.pug")
    //     .then((res) => res.text())
    //     .then((txt) => (template = txt))

	let loaded = false
	let placeload = false
	const onRosaeNlgLoad = () => { loaded = true }

	const asyncLoop = async () => {
		subDist = {}
		for (const i of [0,1,2,3]) {
			const data = await d3.csv('data/'+subDomains[i].metric.replace(/\s/g, '')+'.csv')
			subDist[subDomains[i].metric] = data
		}
	}
	$: if (subDomains) {
		asyncLoop();
	}

	function whichMet(ob) {
		let ar = []
		Object.keys(ob).forEach(e => {
			let tob = {}

			if (['rank', 'Change1year Rank', 'Change4year Rank'].includes(e)) {
				tob[e] = ob[e]
				ar.push(tob)
			}
		})
		ar.sort((a, b) => {
			return Math.abs(Object.values(a)[0]) - Math.abs(Object.values(b)[0]);
		});
		return Object.keys(ar[0])[0]
	}

	function indiSort(ob, index, change) {
		// console.log('ob', ob)
		let ar = []

		Object.keys(ob).forEach(e => {
			let tob = {}
			// console.log('change in ', change)
			if (change == 'rank') {
				tob[e] = ob[e][2019]
			}
			else if (change == 'change4year') {
				tob[e] = ob[e][2019] - ob[e][2015]
			} else {
				tob[e] = ob[e][2019] - ob[e][2018]
			}
			ar.push(tob)
		})
		ar.sort((a, b) => {
			return Object.values(b)[0] - Object.values(a)[0];
		});

		if (index == -1) {
			index = ar.length -1
		}
		else if (index == -2) {
			index = ar.length -2
		}

		// console.log('ar', ar)
		let inciar = ["Low birth weight"]

		let indiname = Object.keys(ar[index])[0]

		let incidents = ""

		if (inciar.includes(indiname)) {
			incidents = "incidents of "
		}

		return [incidents+uncap(indikey[indiname]), Object.values(ar[index])[0]]
	}


	function loadArea(code) {
		place = data[code]
	}

	function iterate(obj, pname) {
		Object.keys(obj).forEach(key => {
			if (typeof obj[key] === 'object') {
				iterate(obj[key], pname)
			} else {
				obj[key] = robojournalist(obj[key], {
					plcname: pname,
				})
			}
		})
	}

	let twoindis = ['Access to green space', 'Crime', 'Difficulties in daily life']

	function results(place) {

		let preres = rosaenlg_en_US.render(template, {
			language: 'en_UK',
			twoindis: twoindis,
			place: place,
			region: region,
			england: england,
			sto: place.stories,
			orda: place.stories.sort((a, b) =>  b.value  - a.value ),
			parent: uncap1(regionThe(region.name)),
			uncap: uncap,
			get_word: get_word,
			figs: figs,
			otherEst: otherEst,
			cur: cur,
			cha: cha,
			qui: qui,
			otherRank: otherRank,
			ud: ud,
			ord: ord,
			whichMet: whichMet,
			topbotnp: topbotnp,
			domLU: domLU,
			indLU: indLU,
			indis: indis,
			indiSort: indiSort,
			indikey: indikey,
			negs: ['smoking', 'anxiety', 'alcohol misuse', 'drug misuse', 'neighbourhood noise', 'air pollution', 'depression', 'self-harm', 'suicides', 'cancer', 'kidney disease', 'cardiovascular conditions', 'crime', 'unemployment', 'low pay', 'difficulties in daily life', 'avoidable mortality', 'infant mortality', "sexually transmitted infections", "hypertension", "low birth weight", "overweight and obesity in adults", "overweight and obesity in children", "cancer", "cardiovascular conditions", "dementia", "diabetes", "kidney disease", "musculoskeletal conditions", "respiratory conditions", "feelings of anxiety", "avoidable mortality", "infant mortality", "self-harm", "suicides", "rough sleeping", "air pollution", "household overcrowding", "noise complaints", "unemployment", "child poverty", "disability", "hip fractures", "low level crime", "personal crime", "pupil absences", "teenage pregnancy", "sedentary behaviour", "smoking", "alcohol misuse", "drug misuse", "distance to gp services", "distance to pharmacies", "distance to sports or leisure facilities", "mortality", "physiological risk factors", "physical health conditions", "difficulties in daily life", "behavioural risk factors"],
		})
		
		return preres.split(`<div id="esc123"></div>`)
	}

	function makeChartData(place, region, england, i) {
		let temp = []
		let arr = [place, region, england]
		if (place) {
			for (const k in {2015: "", 2016: "", 2017: "", 2018: "", 2019: ""}) {
				for (const j in arr) {
					let top = arr[j].data[domLU[place.stories[i].metric]]['subdomains'][place.stories[i].metric].total
					temp.push({
						year: parseInt(k),
						value: top[k]['value'],
						group: arr[j].name
					});
				}
			}
		}
		return temp
	}

	function makeProps(i) {
		if ((i==0)|(whichMet(subDomains[i]) == 'rank')|(['Access to green space', 'Access to services'].includes(subDomains[i].metric))) {
			// SCATTER
			let chart_data 
			let yKey
			let zKey
			if (i==0) {
				chart_data = subDomains.map(d => ({ 'id': (subDomains[i].metric==d.metric)?d.metric:'Other subdomains', 'unique': d['metric'], 'value': d['value'] })).reverse()
				chart_data.sort((a, b) => a.value - b.value)

				yKey = 'unique'
				zKey = 'unique'
			}
			else {
				chart_data = subDist[subDomains[i].metric].map(d => ({ 'id': d['RGN21NM'], 'unique': d['AREANM'], 'value': d['time5'] }))
				chart_data.forEach((item, i) => {
					if (item.unique==place.name) {
						item.id = place.name
					} else if (item.id == place.region.name) {
						item.id = region.name
					} else {
						item.id = "Rest of England"
					}
				});
				chart_data.push({'id': 'Average across England', 'unique': 'Average across England', 'value': england.data[domLU[subDomains[i].metric]].subdomains[subDomains[i].metric].total[2019].value})

				chart_data = chart_data.filter(d => d.id != 'Rest of England')

				console.log('subDomains[i].metric', subDomains[i].metric)
				console.log('chart_data', chart_data)

				yKey = null
				zKey = 'id'
			}

			return props = {
				i: i,
				topic: subDomains[i],
				data: chart_data,
				xKey: "value",
				yKey: yKey,
				zKey: zKey,
				// title: "Multi-line chart"
			}
		} else {
			// LINE
			return props = {
				topic: subDomains[i],
				data: makeChartData(place, region, england, i),
				xKey: "year",
				yKey: "value",
				zKey: "group",
				area: false,
				// title: "Multi-line chart"
			}
		}
	}
</script>

<svelte:head>
	<script src="./rosaenlg.js" on:load="{onRosaeNlgLoad}"></script>
</svelte:head>

<div style="height: 50px"></div>
{#if loaded}
{#if options2}
{#if template}
{#if domLU}
{#if indLU}
		<div class="col">
		<div style="margin-right: 32px;">
			<div class="container">
				<div id="pcSearch">
					<div id="pcSearch-inner">
						<p id="searchLabel" style="font-size: medium; color: #206095;">Explore data in your area</p>
						<div id="dropdown">
							<div style="margin: 20px auto;">
								<Select options={options2} bind:selected value="code" label="name" search={true} on:select="{() => { if (selected) { loadArea(selected.code) }}}"/>
							</div>
						</div>
					</div>
				</div>
				<span id="myText"></span>
			</div>
			{#if place}	

			{#each results(place) as res, i (i)}
				{@html res}
				{#if i<4}
					{#if subDist[subDomains[i].metric]}
						<svelte:component this="{(i==0)? BarChart : ((whichMet(subDomains[i]) == 'rank')|(['Access to green space', 'Access to services'].includes(subDomains[i].metric)))? ScatterChart : LineChart}" {...makeProps(i)}/>
					{/if}
				{/if}
			{/each}
	
			{/if}
		</div>
		</div>

{:else}
	<div style="padding-left: 40%;">Loading...</div>
{/if}
{/if}
{/if}
{/if}
{/if}

<style>

	@import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;700&display=swap');
	:global(body) {
		font-family: 'Open Sans', sans-serif;
		padding: 0px;
		line-height: 2;
		color: #323132;
	}

	main {
		text-align: left;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
		width: 640px
	}

	h1 {
		font-size: 3em;
		line-height: 1.5;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}
	div#visph {
		background-color: #afcbd6;
		color: #003C57;
		height: 240px;
		padding: 80px;
		font-size: 3rem;
		font-weight: 600;
	}
	span.back-to-top {
		text-decoration: underline;
		color: #206095;
		cursor: pointer;
	}
	div#sf {
		background-color: #F5F5F6;
		padding: 15px;
		font-size: 1.2rem;
	}



	:global(body) {
	  margin:0;
	  padding:0;
	  font-family: 'Open Sans', sans-serif;
	  font-size: 14px !important;
	  max-width:950px;
	  margin: 0px auto;
	  display: block;
	  color: #323132 !important;
	}
	:global(#callout-text > p) {
		color: white
	}
	:global(div.container) {
	  /* width: 640px;; */
	  margin: auto;
	}

	:global(div#pcSearch) {
		background: #20609540;
		width: 100%;
		/* border-radius: 10px; */
	}
	:global(div#pcSearch-inner) {
		width: 90%;
		padding: 24px;
	}
	:global(p#searchLabel) {
		font-size: x-large !important;
		color: #206095;
		font-weight: bold;
	}
	:global(p#subhead) {
	  font-size: 20px;
	}
	:global(h2) {
	  font-size: 30px;
	  margin: 32px 0 32px 0;
	  padding: 24px 0 0 0;
	  font-weight: bold;
	  line-height: 40px;
	}
	:global(h3) {
	  font-size: 24px;
	  margin: 32px 0 16px 0;
	  padding: 24px 0 0 0;
	  font-weight: bold;
	  line-height: 32px;
	}
	:global(h4) {
	  font-size: 18px;
	  margin: 24px 0 16px 0;
	  padding: 24px 0 0 0;
	  font-weight: bold;
	  line-height: 32px;
	}

	:global(div#co-box) {
	  display: grid !important;
	  grid-template-columns: 30% auto;
	  gap: 3%;
	  background: #1F6095;
	  background-color: #206095 !important;
	  padding: 20px;
	  margin-bottom: 20px;
	  padding-left: 0;
	  /* border-radius: 10px; */
	}
	:global(#callout-text > p) {
		margin: 15px 15px;
	}
	@media (max-width: 500px) {
		:global(div#co-box) {
			grid-template-columns: auto !important
		}
		:global(div#callout-bigno4d) {
			border-right: none !important;
			border-bottom: 1px solid white;
			height: 80px;
			width: 60%;
			margin: auto;
		}		
		:global(div#callout-bigno3d) {
			border-right: none !important;
			border-bottom: 1px solid white;
			height: 80px;
			width: 60%;
			margin: auto;
		}
		:global(div#callout-text) {
			width: 80%;
    		margin: auto;
    		margin-top: 20px;
		}
		:global(div#callout-text) {
			width: 80%;
    		margin: auto;
    		margin-top: 20px;
		}
		/* :global(#callout-text > p) {
			text-align: justify;
		} */

	}
	:global(div#callout-text) > p {
	  color: white;
	  /* margin: 0px 0px 0px 0px; */
	}
	:global(div#callout-bigno3d) {
	  position: absolute;
	  /* width: 120px; */
	  border-right: 1px solid white;
	  position: relative;
	  text-align: center;
	}
	:global(div#callout-bigno3d > p) {
	  color: white;
	  font-size: xxx-large;
	  font-weight: bold;
	  top: 50%;
	  left: 50%;
		position: absolute;
		transform: translate(-50%, -50%);
	}
	:global(div#callout-bigno4d) {
	  position: absolute;
	  /* width: 150px; */
	  border-right: 1px solid white;
	  position: relative;
	  text-align: center;
	}
	:global(div#callout-bigno4d > p) {
	  color: white;
	  font-size: xxx-large;
	  font-weight: bold;
	  top: 50%;
	  left: 50%;
		position: absolute;
		transform: translate(-50%, -50%);
	}
	:global(.dropdown) {
		height: 44px;
		border-style: solid;
		color: #206095;
		background-color: #FFF;
		font-size: 1.1em;
		border: none;
		box-shadow: none;
		border-radius: 0;
		background: transparent;
		cursor: pointer;
		outline: none;
		padding-left: 6px;
		margin-bottom: 20px;
		border: 2px solid #206095;
		-moz-appearance: none;
		-webkit-appearance: none;
		}

		:global(.dropdown:focus-within) {
box-shadow: 0 0 0px 3pt orange;
}
:global(p#score) {
color: #206095;
/* font-style: italic; */
}

	:global(div.funky) {
		background-color: #206095;
		height: 4px;
		width: 100%;
		/* border-radius: 5px; */
	}
	:global(p) {
		font-size: 18px;
		font-weight: 400;
		line-height: 32px;
		margin: 0 0 24px 0;
		padding: 0;
		color: #323132;
	}

	@media (max-width: 767px) {
		:global(p) {
			font-size: 16px;
		}

	}

	/* @media (min-width: 992px) {
		.col {

		}
	} */
	.col {
		width: 100%;
		float: left;
	}
	@media (min-width: 768px) {
		.col {
			margin: 0;
			/* margin-left: 16px!important; */
			width: 640px;
		}
	}

	:global(h4) {
		font-size: 18px;
		line-height: 24px;
		margin: 16px 0;
		padding: 24px 0 0;
		font-weight: 700;
		color: #323132 !important;
	}
	:global(h5) {
		margin: 0 0 16px;
		font-weight: 400;
		font-size: 16px;
		color: #323132 !important;
	}
	@media (max-width: 767px) {
		:global(h4) {
			font-size: 16px;
		}
		:global(h5) {
			font-size: 14px;
		}
	}
	@media (max-width: 400px) {
		:global(text.label-text) {
			font-size: 10px !important;
		}
	}
	:global(h6) {
		font-size: 16px;
		margin: 16px 0 8px 0;
		font-weight: 700;
		color: #323132;
		font-family: "Open Sans";
	}
</style>