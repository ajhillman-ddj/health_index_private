<script>
	import { getContext } from 'svelte';

	const { data, xScale, yScale, custom } = getContext('LayerCake');

	export let hovered = null;
	export let selected = null;
	
	let coords = $custom.coords;
	let idKey = $custom.idKey;
	let labelKey = $custom.labelKey;
	// let colorHover = $custom.colorHover ? $custom.colorHover : 'orange';
	// let colorSelect = $custom.colorSelect ? $custom.colorSelect : '#206095';

	// let say = $coords.map(d => d.at(-1).y)[0]
	

	function similarY(x, i) {
		let azza = $coords.map( d => $yScale(d[d.length -1].y) - x )
		let azzaorder = azza.sort((a, b) => { return Math.abs(a) - Math.abs(b) } )

		if (Math.abs(azzaorder[1])<6) {
			if (azzaorder[1]>0) {
				x = x - 5
			} else {
				x = x + 5
			}
		}
		else if (Math.abs(azzaorder[1])<12) {
			if (azzaorder[1]>0) {
				x = x - 3
			} else {
				x = x + 3
			}
		}
		return x
	}
	function capi(s) {
		return s.charAt(0).toUpperCase() + s.slice(1);
	}

</script>

{#if $coords}
<defs>
	<filter x="0" y="0" width="1" height="1" id="bgfillhov">
		<feFlood flood-color="rgba(255,255,255,0.8)" result="bg" />
		<feMerge>
			<feMergeNode in="bg"/>
			<feMergeNode in="SourceGraphic"/>
		</feMerge>
	</filter>
	<filter x="0" y="0" width="1" height="1" id="bgfill">
		<feFlood flood-color="rgba(255,255,255,0.8)" result="bg" />
		<feMerge>
			<feMergeNode in="bg"/>
			<feMergeNode in="SourceGraphic"/>
		</feMerge>
	</filter>
</defs>

<g class="label-group">
	{#if $coords[0] && $coords[0][0] && $coords[0][0].x}
		{#each $coords as d, i}
			<!-- {#if [hovered, selected].includes($data[i][0][idKey])} -->
			<text
				class="label"
				transform="translate(2,3)"
				filter="url(#bgfill)"
				fill="#333"
				x={$xScale(d[d.length - 1].x)+10}
				y={ similarY($yScale(d[d.length - 1].y), i) }>
				{capi($data[i][0][labelKey])}
			</text>
		{/each}
	{/if}
</g>


<g class="hover-label-group">
	{#if $coords[0] && $coords[0][0] && $coords[0][0].x}
		{#each $coords as d, i}
			{#each d as dd}	
				{#if hovered == dd}
					<text
						class="hover-label"
						filter="url(#bgfillhov)"
						fill="#333"
						x={$xScale(dd.x)-12}
						y={$yScale(dd.y)-15}>
							{dd.y}
					</text>
				{/if}
			{/each}
		{/each}
	{/if}
</g>


{/if}

<style>
	.hover-label {
		font-size: 0.8em;
		font-weight: 800;
	}
	.label {
		font-size: 0.8em;
	}
</style>