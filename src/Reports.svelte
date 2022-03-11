<script>
	import { regionThe, uncap1, getData, ord, ud, otherRank, otherEst, qui, cha, cur, figs, get_word } from "./utils";
	import Select from "./ui/Select.svelte";
	import { load } from "archieml";
	import robojournalist from 'robojournalist';
	import { LineChart, ScatterChart } from './@onsvisual/svelte-charts';
	import * as d3 from 'd3';

	var selected, place, topics, region, england, props, subDist;

	import * as someJSON from '../data/healthindexdata.json';
	import * as someregJSON from '../data/healthindexregdata.json';

	import * as indisJSON from '../data/indis.json';
	import * as domluJSON from '../data/domlu.json';
	import * as indluJSON from '../data/indlu.json';

	$: domLU = domluJSON.default
	let indis;
	$: if (place) {
		indis = indisJSON.default[place.area]
	}
	$: indLU = indluJSON.default

	$: data = someJSON.default
	$: if (place) {
		region = someregJSON.default[place.region.code]
		england = someregJSON.default['E92000001']
		console.log('England', england)
	}
	let options2 = []
	$: if (data) {
		Object.keys(data).forEach(e => {
			options2.push({ 'code': data[e]['area'], 'name': data[e]['name'] })
		}) 
		options2 = options2
	}

	selected = {code: 'E06000043', name: 'Brighton and Hove'}
	$: place = data[selected.code]
	$: subDomains = place.stories
	$: console.log('Place', place)

	$: console.log('subDomains', subDomains)

    var topics;
    fetch("./archie.aml")
        .then((res) => res.text())
        .then((txt) => (topics = load(txt)))

	var template;
    fetch("./template.pug")
        .then((res) => res.text())
        .then((txt) => (template = txt))

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

		let ar = []

		Object.keys(ob).forEach(e => {
			let tob = {}
			if (change == 'rank') {
				tob[e] = ob[e][2019]
			}
			else {
				tob[e] = ob[e][2019] - ob[e][2015]
			}
			ar.push(tob)
		})
		ar.sort((a, b) => {
			return Object.values(b)[0] - Object.values(a)[0];
		});

		return [Object.keys(ar.at(index))[0].toLowerCase(), Object.values(ar.at(index))[0]]
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

	function results(place, topicsIn) {
		
		var topicLU = JSON.parse(JSON.stringify(topicsIn));
		iterate(topicLU, place.name)

		let preres = rosaenlg_en_US.render(template, {
			language: 'en_UK',
			place: place,
			region: region,
			england: england,
			sto: place.stories,
			topics: topicLU,
			parent: uncap1(regionThe(region.name)),
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
			domLU: domLU,
			indLU: indLU,
			indis: indis,
			indiSort: indiSort,
			negs: ['smoking', 'anxiety', 'alcohol misuse', 'drug misuse', 'neighbourhood noise', 'air pollution', 'depression', 'self-harm', 'suicides', 'cancer', 'kidney disease', 'cardiovascular conditions', 'crime', 'unemployment', 'low pay', 'difficulties in daily life'],
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
		if (whichMet(subDomains[i]) == 'rank') {
			// SCATTER
			let chart_data = subDist[subDomains[i].metric].map(d => ({ 'id': d['RGN21NM'], 'unique': d['AREANM'], 'value': d['time5'] }))
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

			return props = {
				i: i,
				topic: subDomains[i],
				data: chart_data,
				xKey: "value",
				yKey: null,
				zKey: "id",
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
	$: console.log('*** selected', selected)
</script>


<svelte:head>
	<script src="https://unpkg.com/rosaenlg@3.0.1/dist/rollup/rosaenlg_tiny_en_US_3.0.1_comp.js" on:load="{onRosaeNlgLoad}"></script>
</svelte:head>

<div style="height: 50px"></div>
{#if loaded}
{#if options2}
{#if template}
{#if domLU}
{#if indLU}
		<div class="col">
			<div class="container">
				<div id="pcSearch">
					<div id="pcSearch-inner">
						<p id="searchLabel" style="font-size: medium; color: #206095;">Explore data in your area</p>
						<div id="dropdown">
							<div style="margin: 50px auto;">
								<Select options={options2} bind:selected value="code" label="name" search={true} on:select="{() => { if (selected) { loadArea(selected.code) }}}"/>
							</div>
						</div>
					</div>
				</div>
				<span id="myText"></span>
			</div>
			{#if place}
			{#if topics}
	

			{#each results(place, topics) as res, i (i)}
				{@html res}
				{#if i<4}
					{#if subDist[subDomains[i].metric]}
						<svelte:component this="{(whichMet(subDomains[i]) == 'rank')? ScatterChart : LineChart}" {...makeProps(i)}/>
					{/if}
				{/if}
			{/each}
	
			{/if}
			{/if}
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
		border-radius: 10px;
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
	  border-radius: 10px;
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
		:global(#callout-text > p) {
			text-align: justify;
		}
	}
	:global(div#callout-text) > p {
	  color: white;
	  margin: 0px 0px 0px 0px;
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
font-style: italic;
}

	:global(div.funky) {
		background-color: #206095;
		height: 7px;
		width: 75%;
		border-radius: 5px;
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
			margin-left: 16px!important;
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



</style>