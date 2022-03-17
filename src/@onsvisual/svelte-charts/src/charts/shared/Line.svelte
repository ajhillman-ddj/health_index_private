<script>
	import { getContext, createEventDispatcher } from 'svelte';

	const { data, xScale, yScale, zGet, config, custom } = getContext('LayerCake');
	const dispatch = createEventDispatcher();

	export let lineWidth = 2.5;
	export let hover = false;
	export let hovered = null;
	export let select = false;
	export let selected = null;
	export let highlighted = [];
	
	let coords = $custom.coords;
	let idKey = $custom.idKey;
	let colorHover = $custom.colorHover ? $custom.colorHover : 'orange';
	let colorSelect = $custom.colorSelect ? $custom.colorSelect : '#206095';
	let colorHighlight = $custom.colorHighlight ? $custom.colorHighlight : '#206095';

	// Function to make SVG path
	const makePath = (group) => {
		let path = 'M' + group
		.map(d => {
			return $xScale(d.x) + ',' + $yScale(d.y);
		})
		.join('L');
		return path;
	}

	function doHover(e, d) {
		if (hover) {
			hovered = d ? d : null;
			dispatch('hover', {
				id: hovered,
				data: d,
				event: e
			});
		}
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
</script>

{#if $coords}
<g class="line-group">
	{#each $coords as group, i}
		<path
		  class="path-hover"
			d="{makePath(group)}"
		/>
	  <path
		  class="path-line"
			d="{makePath(group)}"
			stroke="{
				$config.z ? $zGet($data[i][0]) : $config.zRange[0]}"
			stroke-width="{
				lineWidth
			}"
		/>

		{#each group as e, j}
			<circle
				class
				cx={$xScale(e.x)}
				cy={$yScale(e.y)}
				r={(hovered)? ((hovered.x == e.x)&(hovered.y == e.y)) ? 8 : 5 : 5}
				fill={(hovered)? ((hovered.x == e.x)&(hovered.y == e.y)) ? $zGet($data[i][0]) : "white" : "white"}
				stroke="{(hovered)? ((hovered.x == e.x)&(hovered.y == e.y)) ? 'orange' : $zGet($data[i][0]) : $zGet($data[i][0])}"
				stroke-width="{(hovered)? ((hovered.x == e.x)&(hovered.y == e.y)) ? 2 : 3 : 3}"
				on:mouseover={f => doHover(f, e)}
				on:mouseleave={f => doHover(f)}
				on:focus={f => doHover(f, e)}
				on:blur={f => doHover(f, e)}
				on:click={f => doSelect(f, e)}
			/>
		{/each}
	{/each}
	
	{#if idKey && (hover || selected || highlighted[0])}
	{#each $coords as group, i}
		{#if [hovered, selected, ...highlighted].includes($data[i][0][idKey]) }
	  <path
		  class="path-overlay"
			d="{makePath(group)}"
			stroke="{
				$data[i][0][idKey] == hovered ? colorHover :
				$data[i][0][idKey] == selected ? colorSelect :
				colorHighlight
			}"
			stroke-width="{
				lineWidth + 1.5
			}"
		/>
		{/if}
	{/each}
	{/if}
</g>
{/if}

<style>
	path {
		fill: none;
		stroke-linejoin: round;
		stroke-linecap: round;
	}
	.path-hover {
		stroke: rgba(255,255,255,0);
		stroke-width: 7;
	}
	.path-line, .path-overlay {
		pointer-events: none;
	}
</style>


