<script>
	import { getContext } from 'svelte';

	const { data, xScale, yScale, custom } = getContext('LayerCake');

	export let hovered = null;
	export let hovmouse = null;
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
	{#each $coords as group, i}
		{#each group as t, j}
				{#if hovered == t}
					<text
						class="hover-label"
						filter="url(#bgfillhov)"
						fill="#333"
						x={$xScale(t.w)-15}
						y={t.y-2}>
							{t.w}
					</text>
				{/if}
		{/each}
	{/each}
</g>


{/if}

<style>
	.hover-label {
		font-size: 1em;
		font-weight: 800;
	}
	.label {
		font-size: 0.8em;
	}
</style>