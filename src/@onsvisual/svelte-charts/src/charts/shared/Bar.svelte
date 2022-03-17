<script>
	import { getContext, createEventDispatcher } from 'svelte';

	const { data, xScale, zGet, zRange, config, custom } = getContext('LayerCake');
	const dispatch = createEventDispatcher();

	export let hover = false;
	export let hovered = null;
	export let hovmouse = null;
	export let select = false;
	export let selected = null;
	export let highlighted = [];
	export let overlayFill = false;
	
	let coords = $custom.coords;
	let idKey = $custom.idKey;

	let colorHover = $custom.colorHover ? $custom.colorHover : 'orange';
	let colorSelect = $custom.colorSelect ? $custom.colorSelect : 'black';
	let colorHighlight = $custom.colorHighlight ? $custom.colorHighlight : 'black';
	let lineWidth = $custom.lineWidth ? $custom.lineWidth : 2;
	let markerWidth = $custom.markerWidth ? $custom.markerWidth : 2.5;
	$: mode = $custom.mode ? $custom.mode : 'default';

	function doHover(e, d) {
		hovered = d ? d : null;
		hovmouse = e
	}

	function doSelect(e, d) {
		selected = d ? d[idKey] : null;
		dispatch('select', {
			id: selected,
			data: d,
			event: e
		});
	}
</script>

{#if $coords}
<g class="bar-group">
	{#each $coords as group, i}
	  {#each group as d, j}
		  <rect
				class='bar-rect'
				data-id="{j}"
				x="{0}"
				y="{d.y + 10}"
				height={3}
				width="{$xScale(d.w)}"
				rx='5px'
				stroke="{d == hovered ? colorHover : null}"
				stroke-width="{d == hovered ? 1 : 0}"
				fill="lightgrey"
					on:mouseover={e => doHover(e, d)}
					on:mouseleave={e => doHover(e)}
					on:focus={e => doHover(e, d)}
					on:blur={e => doHover(e, d)}
					on:click={e => doSelect(e, d)}
			/>
			<rect
				class="voronoi-cell"
				data-id="{j}"
				x="{0}"
				y="{d.y}"
				height={25}
				width="{$xScale(d.w)+30}"
				rx='5px'
				stroke="{d == hovered ? colorHover : null}"
				stroke-width="{d == hovered ? 1 : 0}"
					on:mouseover={e => doHover(e, d)}
					on:mousemove={e => doHover(e, d)}
					on:mouseleave={e => doHover(e)}
					on:focus={e => doHover(e, d)}
					on:blur={e => doHover(e, d)}
					on:click={e => doSelect(e, d)}
			/>
			<circle
				class='bar-circle'
				data-id="{j}"
				cx="{$xScale(d.w)}"
				cy="{d.y + 12}"
				height={d.h}
				r='8px'
				stroke="{d == hovered ? colorHover : null}"
				stroke-width="{d == hovered ? 2 : 0}"
				fill="{overlayFill && $data[i][j][idKey] == selected ? colorSelect : overlayFill && highlighted.includes($data[i][j][idKey]) ? colorHighlight : $config.z ? $zGet($data[i][j]) : $zRange[0]}"
				on:mouseover={e => doHover(e, d)}
				on:mouseleave={e => doHover(e)}
				on:focus={e => doHover(e, d)}
				on:blur={e => doHover(e, d)}
				on:click={e => doSelect(e, d)}
			/>

	  {/each}
	{/each}
</g>
{/if}

<style>
	.voronoi-cell {
		fill: none;
		stroke: none;
		pointer-events: all;
	}
</style>