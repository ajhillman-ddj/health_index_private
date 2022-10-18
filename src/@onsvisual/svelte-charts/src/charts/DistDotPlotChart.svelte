<svelte:options accessors={true} />

<script>
	import 'whatwg-fetch';

	import { scaleLinear } from 'd3-scale';
	import { line } from 'd3-shape';
	import XAxis from './distDotPlotComponents/XAxis.svelte';
	import Annotation from './distDotPlotComponents/Annotation.svelte';
    import ViolinDotPlot from './distDotPlotComponents/ViolinDotPlot.svelte';


	export let data;

	export let height = 720; // number of pixels or valid css height string
	export let width = 720;
	export let distributionData;

	let padding = {top: 110, left: 10, right: 10, bottom: 20}

	let maxValue = Math.max(...data.map(el => {return Math.max(el.value, el.value2019)}));

	let x = scaleLinear()
		.domain([10, Math.max(maxValue,125)+10])
		.range([0, width-padding["left"]-padding["right"]]);

	let seriesPadding = 10;

	let y = scaleLinear()
		.domain([0,data.length])
		.range([height-padding["top"]-padding["bottom"]-seriesPadding*2, 0]);

	let seriesParametersArray = [{key: "value2019", yAdj: -5, color: "#003C57"}, {key: "value", yAdj: 5, color: "#00A3A6"}];

	let gridlinesParametersArray = [
	//{value: 80, opacity: 0.10},
	{value: 90, opacity: 0.20},
	{value: 100, opacity: 0.75},
	{value: 110, opacity: 0.20},
	//{value: 120, opacity: 0.10},
	]

	let yDist = scaleLinear()
		.domain([0,50])
		.range([0,20]);
	
	let pathCalc = line()
    	.x((d) => { return x(d["midpoint"]); })
    	.y((d) => { return -yDist(d["yValue"]); });

	let pathCalcInv = line()
    	.x((d) => { return x(d["midpoint"]); })
    	.y((d) => { return yDist(d["yValue"]); });


	let xKey = scaleLinear()
		.domain([10, 125])
		.range([0, width/2]);

	let pathCalcXKey = line()
    	.x((d) => { return xKey(d["midpoint"]); })
    	.y((d) => { return -yDist(d["yValue"]); });

	let pathCalcInvXKey = line()
    	.x((d) => { return xKey(d["midpoint"]); })
    	.y((d) => { return yDist(d["yValue"]); });


	let annotationsArray = [
{position:[xKey(100), -21], path:"M0 0 l0 -5 l-40 0", textAnchor:"end", fontSize: "14px", opacity:0.75, text:"Health in England in 2015", stroke:"#333", x:-43, y:-4},
{position:[xKey(95), 15], path:"M0 0 l0 10 l-20 0", textAnchor:"end", fontSize: "14px", opacity:1, text:"Distribution of local authority values in 2019", stroke:"#919090", x:-23, y:15},
{position:[xKey(110), 0], path:"M0 0 l0 -10 l10 0", textAnchor:"start", fontSize: "14px", opacity:1, text:"2019 value", stroke:"#003C57", x:13, y:-9},
{position:[xKey(120), 18], path:"M0 0 l0 10 l10 0", textAnchor:"start", fontSize: "14px", opacity:1, text:"2020 value", stroke:"#00A3A6", x:13, y:15},
];

	

</script>


<div class="chart-container">
	<svg
	{height}
	{width}
	>

	<g class="key"
	transform="translate(60,40)scale(1)"
	>

		<XAxis
		x={xKey}
		gridlinesParametersArray={gridlinesParametersArray.filter(function(e,i) {return e.value == 100})}
		y=20
		></XAxis>

		<g class="annotations">

			{#each annotationsArray as d, i}
				<Annotation
				id={i}
				position={d["position"]}
				path={d["path"]}
				textAnchor={d["textAnchor"]}
				fontSize={d["fontSize"]}
				opacity={d["opacity"]}
				text={d["text"]}
				stroke={d["stroke"]}
				x={d["x"]}
				y={d["y"]}
				></Annotation>
			{/each}
		</g>

		<g class="dot-plot-container"
		transform={"translate("+0+","+seriesPadding+")"}
		>	

			{#each [data[0]] as d, i}

				<ViolinDotPlot
				key={true}
				{i}
				yPosition=0
				x={xKey}
				violinPlotData={distributionData.default.map(el=> {return {midpoint: el.midpoint, yValue: el[d["unique"]]}})}
				violinFuncs={[pathCalcXKey, pathCalcInvXKey]}
				{seriesParametersArray}	
				circleData={[110,120]}
				></ViolinDotPlot>
				
			{/each}
			
		</g>
	</g>

	<g 
	class="chart-body"
	transform={"translate("+padding["left"]+","+padding["top"]+")"}
	>

		<XAxis
		{x}
		{gridlinesParametersArray}
		y={height-padding["top"]}
		></XAxis>

		<g class="dot-plot-container"
		transform={"translate("+0+","+seriesPadding+")"}
		>	

			{#each data as d, i}

				<ViolinDotPlot
				key={false}
				yPosition={y(i)}
				{x}
				violinPlotData={distributionData.default.map(el=> {return {midpoint: el.midpoint, yValue: el[d["unique"]]}})}
				violinFuncs={[pathCalc, pathCalcInv]}
				{seriesParametersArray}	
				circleData={[d.value2019, d.value]}
				label={d["unique"]}
				></ViolinDotPlot>
				
			{/each}
			
		</g>
	
	</g>

	</svg>



</div>






<style>
	.chart-container {
		width: 100%;
		height: 720px !important;
    	/* margin-left: auto; */
	}

</style>