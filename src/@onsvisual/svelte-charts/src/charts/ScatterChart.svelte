<svelte:options accessors={true} />

<script>	
	import 'whatwg-fetch';

	import { LayerCake, Svg } from 'layercake';
	import { scaleOrdinal, scaleLinear, scaleSymlog } from 'd3-scale';
  import { tweened } from 'svelte/motion';
	import { cubicInOut } from 'svelte/easing';

	import SetCoords from './shared/SetCoords.svelte';
	import Scatter from './shared/Scatter.svg.svelte';
	import Voronoi from './shared/Voronoi.svelte';
	import AxisX from './shared/AxisX.svelte';
	import AxisY from './shared/AxisY.svelte';
	import Legend from './shared/Legend.svelte';
	import Title from './shared/Title.svelte';
	import Footer from './shared/Footer.svelte';
	import Labels from './shared/LabelsScat.svelte';

	export let data;
	export let i;
	export let topic;
	export let height = 250; // number of pixels or valid css height string
  export let animation = false;
  export let duration = 800;
	export let xKey = 'x';
	export let yKey = null;
	export let zKey = null;
  export let rKey = null;
	export let idKey = xKey;
	export let labelKey = idKey;
	export let xScale = 'linear';
	export let yScale = 'linear';
	export let xFormatTick = d => d;
	export let yFormatTick = d => d;
	export let xMax = null;
	export let xMin = null;
	export let yMax = null;
	export let yMin = null;
	export let xAxis = true;
	export let yAxis = true;
	export let xTicks = 4;
	export let yTicks = 4;
	export let textColor = '#666';
	export let tickColor = '#ccc';
	export let tickDashed = false;
	export let title = null;
	export let footer = null;
	export let legend = false;
	export let labels = true;
	export let snapTicks = false;
	export let padding = { top: 0, bottom: 20, left: 35, right: 0 };
	export let buffer = 5;
	export let color = null;
	export let colors = color ? [color] : ['lightgrey', '#27A0CC', '#871A5B'] // ['#27A0CC', '#871A5B', '#A8BD3A'] // ['#A8BD3A', '#27A0CC', '#F66068', '#746CB1', '#22D0B6', 'lightgrey', '#206095', '#003C57', '#118C7B'];
	export let r = 6;
	export let interactive = true;
	export let xPrefix = "";
	export let xSuffix = "";
	export let yPrefix = "";
	export let ySuffix = "";
	export let hover = true;
	export let hovered = null;
	export let colorHover = 'orange';
	export let select = false;
	export let selected = null;
	export let colorSelect = 'black';
	export let highlighted = [];
	export let colorHighlight = 'black';
	export let overlayFill = false;

	const tweenOptions = {
		duration: duration,
		easing: cubicInOut
	};
	$: coords = tweened(undefined, tweenOptions);

	const distinct = (d, i, arr) => arr.indexOf(d) ==  i;

	function domGet(data, key, min, max) {
		let vals = data.map(d => d[key]);
		return [min ? min : vals[0] ? Math.min(...vals) : -1, max ? max : vals[0] ? Math.max(...vals) : 1];
	}
	function xDomUpdate(data, key, min, max) {
		let newDom = domGet(data, key, min, max);
		if (newDom[0] != xDom[0] || newDom[1] != xDom[1]) {
			xDomain.set(newDom);
			xDom = newDom;
		}
	}
	function yDomUpdate(data, key, min, max) {
		let newDom = key ? domGet(data, key, min, max) : yDom;
		if (newDom[0] != yDom[0] || newDom[1] != yDom[1]) {
			yDomain.set(newDom, {duration: animation ? duration : 0});
			yDom = newDom;
		}
	}
	let xDom = domGet(data, xKey, xMin, xMax);
	const xDomain = tweened(xDom, tweenOptions);
	let yDom = domGet(data, yKey, yMin, yMax);
	const yDomain = tweened(yDom, tweenOptions);

	$: xDomUpdate(data, xKey, xMin, xMax);
	$: yDomUpdate(data, yKey, yMin, yMax);
  $: zDomain = zKey ? data.map(d => d[zKey]).filter(distinct) : null;
</script>

{#if title}
  <Title>{title}</Title>
{/if}
<slot name="options"/>
<div class="chart-container" style="height: {typeof height == 'number' ? height + 'px' : height }">
	<LayerCake
    {padding}
		x={xKey}
		y={yKey}
    	z={zKey}
    	r={rKey}
		xScale={xScale == 'log' ? scaleSymlog() : scaleLinear()}
		yScale={yScale == 'log' ? scaleSymlog() : scaleLinear()}
    	zScale={scaleOrdinal()}
		xDomain={$xDomain}
		yDomain={$yDomain}
		{zDomain}
		zRange={colors}
    	rRange={Array.isArray(r) ? r : [r, r]}
		data={data}
	    xPadding={[buffer, buffer]}
	    yPadding={yKey ? [buffer, buffer] : null}
	    custom={{
			type: 'scatter',
			idKey,
			labelKey,
    		coords,
			colorSelect,
			colorHover,
			colorHighlight,
			padding: 1,
    		animation,
    		duration
    	}}
		let:width
	>
	  {#if width > 80} <!-- Hack to prevent rendering before xRange/yRange initialised -->
		<SetCoords/>
    <slot name="back"/>
		<Svg pointerEvents={interactive}>
      {#if xAxis}
			  <AxisX ticks={xTicks} formatTick={xFormatTick} {snapTicks} prefix={xPrefix} suffix={xSuffix} {textColor} {tickColor} {tickDashed}/>
      {/if}
      {#if yAxis && yKey}
			  <AxisY ticks={yTicks} formatTick={yFormatTick} prefix={yPrefix} suffix={ySuffix} {textColor} {tickColor} {tickDashed}/>
      {/if}
			
			<g transform="translate(0,-60)"><Scatter {data} {selected} bind:hovered {highlighted} {overlayFill}/></g>
			<g transform="translate(0,60)"><Scatter {data} {selected} bind:hovered {highlighted} {overlayFill}/></g>

			{#if labels}
				<Labels {hovered} {selected}/>
			{/if}
			<slot name="svg"/>
		</Svg>
	  <slot name="front"/>
		{/if}
	</LayerCake>
</div>
{#if legend && zDomain}
  <Legend domain={zDomain} {colors} markerLength={Array.isArray(r) ? r[0] * 2 : r * 2} round={true}/>
{/if}
<Legend domain={zDomain} {colors} markerLength={13} round={true}/>
{#if footer}
  <Footer>{footer}</Footer>
{/if}

<style>
	.chart-container {
		width: 100%;
	}
</style>