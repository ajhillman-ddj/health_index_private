<svelte:options accessors={true} />

<script>
	import 'whatwg-fetch';

	import { scaleLinear } from 'd3-scale';
    import { forceSimulation, forceX, forceY, forceCollide } from 'd3-force';
    import AxisY from './doubleVerticalBeeswarmComponents/AxisY.svelte';
    import AxisX from './doubleVerticalBeeswarmComponents/AxisX.svelte';
    import SlopeLines from './doubleVerticalBeeswarmComponents/SlopeLines.svelte';
    import BeeswarmCircles from './doubleVerticalBeeswarmComponents/BeeswarmCircles.svelte';
    import Annotation from './doubleVerticalBeeswarmComponents/Annotation.svelte';
    import { range, randomInt, line, filter } from 'd3';
    import { onMount } from "svelte";
	export let data;

	export let height = 600; // number of pixels or valid css height string
	export let width = 720;

	let padding = {top: 120, left: 280, right: 120, bottom: 35}

	let x = scaleLinear()
		.domain([0, 1])
		.range([0, width-padding["left"]-padding["right"]]);
    
	let maxValue = Math.round(Math.max(110,Math.max(...data.map(el => {return Math.max(el.value, el.value2019)}))+5));
	let minValue = Math.round(Math.min(90,Math.min(...data.map(el => {return Math.min(el.value, el.value2019)}))-5));

	let y = scaleLinear()
		.domain([minValue,maxValue])
		.range([height-padding["top"]-padding["bottom"], 0]);

    let mainLAData = data.filter(function(e,i) {return e["id"] == e["unique"] && e["id"] != "Average across England"})
    let englandData = data.filter(function(e,i) {return e["id"] == "Average across England"})
    let surroundingLAData = data.filter(function(e,i) {return e["id"] != e["unique"]})

    data.forEach(function(e,i) {

        e["x"] = x(0)
        e["y"] = y(e["value2019"])
        e["r"] = 6

    })

    $: nodes2019 = data.map((d) => ({ ...d }));

    data.forEach(function(e,i) {

        e["x"] = x(1)
        e["y"] = y(e["value"])
    })

    $: nodes2020 = data.map((d) => ({ ...d }));

    let simulation2019, simulation2020;

    function simulation2019Update() {
        simulation2019.tick();
        nodes2019 = [...nodes2019]; //refresh the nodes array to render/trigger simulation
    }

    function simulation2020Update() {
        simulation2020.tick();
        nodes2020 = [...nodes2020]; //refresh the nodes array to render/trigger simulation
    }

    onMount(() => {
        simulation2019 = forceSimulation(nodes2019)
        .force('x', forceX(x(0)).strength(0.05))
	    .force('y', forceY().y(d => y(d["value2019"])).strength(0.5))
        .force("collide", forceCollide(6.5))
        .on("tick", simulation2019Update)
        .alphaTarget(0.01);

        simulation2020 = forceSimulation(nodes2020)
        .force('x', forceX(x(1)).strength(0.05))
	    .force('y', forceY().y(d => y(d["value"])).strength(0.5))
        .force("collide", forceCollide(6.5))
        .on("tick", simulation2020Update)
        .alphaTarget(0.01);
    });

    let annotationsArray = [
{position:[-115, y(100)], path:"M0 0 l-20 0 l0 40", textAnchor:"end", fontSize: 14, opacity:0.75, text:["Health in", "England in 2015"], stroke:"black", x:0, y:54, arrowhead: true},
];

const prefix = ["London", "Yorkshire and The Humber"].includes(surroundingLAData[0]["id"]) ? "" : "the "

let labelsYPositionArray;

let annotationCircle

if ((mainLAData[0]["value"] > englandData[0]["value"]) & (englandData[0]["value"] > Math.min(...surroundingLAData.map(o => o.value)))) {

    labelsYPositionArray = [24,-2]

    annotationCircle = surroundingLAData.reduce(function(prev, current) {
                        return (prev.y > current.y) ? prev : current
                })

    if (Math.abs(annotationCircle["value"]-mainLAData[0]["value"]) > 8) {

        annotationsArray.push({position:[300, y(annotationCircle["value"])], path:"M0 0 l-40 0 l0 20", textAnchor:"end", fontSize: 14, opacity:0.75, text: [annotationCircle["unique"]+" has the lowest" , "value of all local authorities", "in "+prefix+annotationCircle["id"]], stroke:"#404040", x:-10, y:32, arrowhead: true},)

    }
} else {

    labelsYPositionArray = [-2,24]

    annotationCircle = surroundingLAData.reduce(function(prev, current) {
                        return (prev.y > current.y) ? current : prev
                })

    if (Math.abs(annotationCircle["value"]-mainLAData[0]["value"]) > 8) {

        annotationsArray.push({position:[300, y(annotationCircle["value"])], path:"M0 0 l-40 0 l0 -20", textAnchor:"end", fontSize: 12, opacity:0.75, text: [annotationCircle["unique"]+" has the highest" , "value of all local authorities", "in "+prefix+annotationCircle["id"]], stroke:"#404040", x:-10, y:-52, arrowhead: true},)

    }
}

const colorPalette = {mainLA: ["#27A0CC", "#27A0CC"], england: ["#871A5B","#871A5B"], surroundingLAs: ["#e0dede","#333"]};
const keyObject = {mainLA: mainLAData[0]["id"], england: "Average across England", surroundingLAs: "Other local authorities in "+prefix+annotationCircle["id"]};

</script>

<div class="chart-container">
	<svg
	{height}
	{width}
	>

    <g class="key"
    transform="translate(20,20)scale(1.2)"
    > 

        {#each Object.keys(colorPalette) as el, i}

        <g class="keyElement"
        transform={"translate("+(0)+","+(i*20)+")"}>

            <text
            x=15
            text-anchor="start"
            stroke="none"
            fill={colorPalette[el][1]}
            font-size="12px"
            >{keyObject[el]}</text>

            {#if el == "england"}

                <path
                class="node"
                transform={"translate("+0+","+(-4)+")"}
                d={"M0 "+(-6)+" L"+6+" 0 L 0 "+6+" L "+(-6) +" 0 z" }
                fill={colorPalette[el][0]}
                stroke="none"
                ></path>

            {:else}

                <circle
                class="node"
                r={6}
                fill={colorPalette[el][0]}
                cx={0}
                cy={-4}
                ></circle>

            {/if}

        </g>


        {/each}

    </g>

    <g 
    transform={"translate("+padding["left"]+","+padding["top"]+")"}
    >

        <AxisY
        {maxValue}
        {minValue}
        {y}
        {x}
        {height}
        ></AxisY> 

        {#each [{data: surroundingLAData, visible: false, color: colorPalette["surroundingLAs"][0]}, {data: englandData, visible: true, color: colorPalette["england"][0]}, {data: mainLAData, visible: true, color: colorPalette["mainLA"][0]}] as linesGroup}

            <SlopeLines
            {x}
            {y}
            data={linesGroup["data"]}
            visible={linesGroup["visible"]}
            color={linesGroup["color"]}
            ></SlopeLines>

        {/each}

        {#each [{data: nodes2019, visible: false}, {data: nodes2020, visible: false},{data: nodes2019, visible: true}, {data: nodes2020, visible: true} ] as circlesGroup}

            <BeeswarmCircles
            data={circlesGroup["data"]}
            visible={circlesGroup["visible"]}
            colors={colorPalette}
            ></BeeswarmCircles>

        {/each}

        {#if mainLAData[0]["id"].length <= 25}

            {#if !((mainLAData[0]["value"] < englandData[0]["value"] & mainLAData[0]["value2019"] > englandData[0]["value2019"]) | (mainLAData[0]["value"] > englandData[0]["value"] & mainLAData[0]["value2019"] < englandData[0]["value2019"]))}

                {#each [...englandData, ...mainLAData] as point, i}

                    <g transform={"translate("+x(0.5)+","+((y(point["value2019"])+y(point["value"]))/2-5)+")"}>

                        <g transform={"rotate("+60*Math.atan((y(point["value"])-y(point["value2019"]))/(x(1)-x(0)))+")"}>

                            <text
                            y={labelsYPositionArray[i]}
                            text-anchor="middle"
                            stroke="none"
                            fill={(point["id"] == point["unique"]) ? (point["id"] == "Average across England" ? "#871A5B" : "#27A0CC") : "#e0dede"}
                            font-size="16px"
                            >{point["id"]}</text>

                        </g>

                    </g>
                {/each}

            {/if}

        {/if}

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
                arrowhead={d["arrowhead"]}
                ></Annotation>
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