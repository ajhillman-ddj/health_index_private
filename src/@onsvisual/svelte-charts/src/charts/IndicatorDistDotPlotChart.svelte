<svelte:options accessors={true} />

<script>
	import 'whatwg-fetch';

	import { scaleLinear } from 'd3-scale';
	import { line } from 'd3-shape';
	import XAxis from './distDotPlotComponents/XAxis.svelte';
	import Annotation from './distDotPlotComponents/Annotation.svelte';
    import ViolinDotPlot from './distDotPlotComponents/ViolinDotPlot.svelte';

	export let data;
	export let width = 720;
	export let distributionData;

    //split out data
    let indicatorCircleData = [];

    Object.keys(data).forEach(function(key) {

        Object.keys(data[key]).forEach(function(subKey) {

            indicatorCircleData.push({label: subKey, value2019: data[key][subKey]["2018"], value: data[key][subKey]["2019"] })
        })
    })

    let circleDataLower = indicatorCircleData.filter(function(e,i) {return e.value <= 90}).sort((a,b) => a.value - b.value); 
    let circleDataHigher = indicatorCircleData.filter(function(e,i) {return e.value >= 110}).sort((a,b) => b.value - a.value); 

	let padding = {top: 160, left: 5, right: 5, bottom: 20}

    let height = padding["top"]+40*Math.max(circleDataLower.length, circleDataHigher.length)+padding["bottom"];

	let maxValue = Math.max(...indicatorCircleData.map(el => {return Math.max(el.value, el.value2019)}));

	let x = scaleLinear()
		.domain([10, Math.max(maxValue,125)+10])
		.range([0,width/2-padding["left"]-padding["right"]]);

	let seriesPadding = 0;

	let y = scaleLinear()
		.domain([0,Math.max(circleDataHigher.length, circleDataLower.length)])
		.range([0, height-padding["top"]-padding["bottom"]-seriesPadding*2]);

	let seriesParametersArray = [
                                {key: "value2019", yAdj: -5, color: "#003C57"}, 
                                {key: "value", yAdj: 5, color: "#00A3A6"}
                            ];

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
{position:[xKey(100), -21], path:"M0 0 l0 -5 l-40 0", textAnchor:"end", fontSize: "14px", opacity:0.75, text:"Health in England in 2015", stroke:"#333", x:-43, y:-2},
{position:[xKey(95), 15], path:"M0 0 l0 10 l-20 0", textAnchor:"end", fontSize: "14px", opacity:1, text:"Distribution of local authority values in 2020", stroke:"#919090", x:-23, y:13},
{position:[xKey(110), 0], path:"M0 0 l0 -10 l10 0", textAnchor:"start", fontSize: "12px", opacity:1, text:"2019 value", stroke:"#003C57", x:13, y:-7},
{position:[xKey(120), 18], path:"M0 0 l0 10 l10 0", textAnchor:"start", fontSize: "14px", opacity:1, text:"2020 value", stroke:"#00A3A6", x:13, y:13},
];

	

</script>


<div class="chart-container">
	<svg
	{height}
	{width}
	>

	<g class="key"
	transform="translate(50,40)scale(1)"
	>

		<XAxis
		x={xKey}
		gridlinesParametersArray={gridlinesParametersArray.filter(function(e,i) {return e.value == 100})}
		y=20
		fontSize={"12px"}
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

			{#each [circleDataLower[0]] as d, i}

				<ViolinDotPlot
				key={true}
				{i}
				yPosition=8
				x={xKey}
				violinPlotData={distributionData.default.map(el=> {return {midpoint: el.midpoint, yValue: el[d["label"]]}})}
				violinFuncs={[pathCalcXKey, pathCalcInvXKey]}
				{seriesParametersArray}	
				circleData={[110,120]}
				radius={6}
				></ViolinDotPlot>
				
			{/each}
			
		</g>
	</g>

    <g class="titles"
	transform={"translate("+padding["left"]+",140)"}
	>

        <text
            stroke="none"
            fill="#333"
            font-size=16px
            text-anchor="start"
            font-weight="bold"
            >Indicators below 90</text>

        <text
            x={width/2}
            stroke="none"
            fill="#333"
            font-size=16px
            text-anchor="start"
            font-weight="bold"
            >Indicators above 110</text>

    </g>

	<g 
	class="chart-body"
	transform={"translate("+0+","+padding["top"]+")"}
	>

        <g transform={"translate("+padding["left"]+",0)"}>

            <XAxis
            {x}
            gridlinesParametersArray={gridlinesParametersArray.filter(function(e,i) {return e.value <= 100})}
            y={(circleDataLower.length)*40+20}
			fontSize={"12px"}
            ></XAxis>

        </g>

        <g transform={"translate("+(padding["left"]+width/2)+",0)"}>

            <XAxis
            {x}
            gridlinesParametersArray={gridlinesParametersArray.filter(function(e,i) {return e.value >= 100})}
            y={(circleDataHigher.length)*40+20}
			fontSize={"12px"}
            ></XAxis>

        </g>

		<g class="dot-plot-container"
		transform={"translate("+padding["left"]+","+seriesPadding+")"}
		>	

			{#each circleDataLower as d, i}

				<ViolinDotPlot
				key={false}
				yPosition={y(i)+40}
				{x}
				violinPlotData={distributionData.default.map(el=> {return {midpoint: el.midpoint, yValue: el[d["label"]]}})}
				violinFuncs={[pathCalc, pathCalcInv]}
				{seriesParametersArray}	
				circleData={[d.value2019, d.value]}
				label={d["label"]}
                labelFontSize={"12px"}
                labelYValue={-12}
                backgroundToLabel={false}
				radius={6}
				></ViolinDotPlot>
				
			{/each}
			
		</g>

        <g class="dot-plot-container"
		transform={"translate("+(width/2+padding["left"])+","+seriesPadding+")"}
		>	

			{#each circleDataHigher as d, i}

				<ViolinDotPlot
				key={false}
				yPosition={y(i)+40}
				{x}
				violinPlotData={distributionData.default.map(el=> {return {midpoint: el.midpoint, yValue: el[d["label"]]}})}
				violinFuncs={[pathCalc, pathCalcInv]}
				{seriesParametersArray}	
				circleData={[d.value2019, d.value]}
				label={d["label"]}
                labelYValue={-12}
                labelFontSize={"12px"}
                backgroundToLabel={false}
				radius={6}
				></ViolinDotPlot>
				
			{/each}
			
		</g>
	
	</g>

	</svg>



</div>






<style>
	.chart-container {
		width: 100%;
		height: 660px !important;
    	/* margin-left: auto; */
	}

</style>