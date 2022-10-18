<script>
	import { getContext, createEventDispatcher } from 'svelte';

	const { xScale, zGet, zRange, config, custom } = getContext('LayerCake');
	const dispatch = createEventDispatcher();

    export let dataOrig;
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
<!-- {console.log($coords)} -->
<g class="bar-group">
	{#each $coords as group, i}
	  {#each group as d, j}
            <!--{console.log(d)} -->
			<circle
				class='bar-circle'
				data-id="{j}"
				cx="{$xScale(d.w)}"
				cy="{d.y + 12}"
				height={d.h}
				r='6px'
				stroke="{d == hovered ? colorHover : null}"
				stroke-width="{d == hovered ? 2 : 0}"
				fill="green"
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