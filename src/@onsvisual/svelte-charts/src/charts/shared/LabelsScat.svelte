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

<g class="hover-label-group">
	{#if $coords[0]}
		{#each $coords as d, i}
			<!-- {#each d as dd} -->
				{#if hovered == d}
					<text
						class="hover-label"
						filter="url(#bgfillhov)"
						fill="#333"
						x={$xScale(d.x)-12}
						y={$yScale(d.y)-15}>
							{d.u + ': ' + Math.round(d.x*10)/10}
					</text>
				{/if}
			<!-- {/each} -->
		{/each}
	{/if}
</g>

{/if}

<style>
	.hover-label {
		font-weight: 800;
	}
	.label {
	}
</style>