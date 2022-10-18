<script>
	import { getContext } from 'svelte';

	const { z, xScale, yScale, zGet, zRange, custom, width } = getContext('LayerCake');

	export let hovered = null;
	export let selected = null;
	export let highlighted = [];
	export let overlayFill = false;
	// export let size = 8;

	export let data;

	let coords = $custom.coords;
	let idKey = $custom.idKey;

	console.log($coords)
	console.log(data)

	let colorHover = $custom.colorHover ? $custom.colorHover : 'orange';
	let colorSelect = $custom.colorSelect ? $custom.colorSelect : 'black';
	let colorHighlight = $custom.colorHighlight ? $custom.colorHighlight : 'black';
	let lineWidth = $custom.lineWidth ? $custom.lineWidth : 2;

	function doHover(e, d) {
		hovered = d ? d : null;
	}

	function doSelect(e, d) {
		if (!hovered) {
			hovered = d ? d : null;
			dispatch('select', {
				id: selected,
				data: d,
				event: e
			});
		}
	}
	$: pad = 0.9
	$: adj = -10
	$: size = 4
	$: if ($width>300) {
		size = 5
		pad = 1
		adj = 0
	}
	$: if ($width>400) {
		size = 6
		pad = 1.1
		adj = 10
	}
	$: if ($width>500) {
		size = 7
		pad = 1.2
		adj = 20
	}
	$: if ($width>600) {
		size = 8
		pad = 1.3
		adj = 30
	}


</script>

{#if $coords}
<!--{#if $coords.length == +$data.length}-->

	<g class="scatter-group">
		{#each $coords as d, i}
			<circle
				class=""
				cx={$xScale(d.x)}
				cy={($yScale(d.y)*pad)-adj}
				r={(hovered)? ((hovered.x == d.x)&(hovered.y == d.y)) ? size*1.2 : size : size}
				fill="blue"
				stroke={(hovered)? ((hovered.x == d.x)&(hovered.y == d.y)) ? "orange" : "white" : "white"}
				stroke-width="2"
				on:mouseover={f => doHover(f, d)}
				on:mouseleave={f => doHover(f)}
				on:focus={f => doHover(f, d)}
				on:blur={f => doHover(f, d)}
			/>
		{/each}
	</g>

<!--{/if}-->
{/if}
