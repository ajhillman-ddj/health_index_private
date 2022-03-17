<script>
	import { getContext } from 'svelte';

	const { padding, xRange, yScale } = getContext('LayerCake');

	export let ticks = 4;
	export let tickMarks = false;
	export let gridlines = true;
	export let tickDashed = false;
	export let tickColor = '#bbb';
	export let textColor = 'white';
	export let formatTick = d => d;
	export let xTick = 0;
	export let yTick = 0;
	export let dxTick = 0;
	export let dyTick = -4;
	export let textAnchor = 'start';
	export let prefix = '';
	export let suffix = '';

	$: isBandwidth = typeof $yScale.bandwidth === 'function';

	$: tickVals = Array.isArray(ticks) ? ticks :
		isBandwidth ?
			$yScale.domain() :
			typeof ticks === 'function' ?
				ticks($yScale.ticks()) :
					$yScale.ticks(ticks);
</script>

<defs>
	<filter x="{-0.4}" y="{-0.2}" width="1.5" height="1.2" id="barYcover">
		<feFlood flood-color="white" result="bg" />
		<feMerge>
			<feMergeNode in="bg"/>
			<feMergeNode in="SourceGraphic"/>
		</feMerge>
	</filter>
</defs>

<g class='axis y-axis' transform='translate({-$padding.left}, 0)'>
	{#each tickVals as tick, i}
		<g class='tick tick-{tick}' transform='translate({$xRange[0] + (isBandwidth ? $padding.left : 0)}, {$yScale(tick)})'>
			
			{#if gridlines !== false}
				<line
					class="gridline"
					x2='100%'
					y1={yTick + (isBandwidth ? ($yScale.bandwidth() / 2) : 0)}
					y2={yTick + (isBandwidth ? ($yScale.bandwidth() / 2) : 0)}
					class:dashed={tickDashed}
					style='stroke: {tickColor}'
				></line>
			{/if}

			{#if tickMarks === true}
				<line
					class='tick-mark'
					x1='0'
					x2='{isBandwidth ? -6 : 6}'
					y1={yTick + (isBandwidth ? ($yScale.bandwidth() / 2) : 0)}
					y2={yTick + (isBandwidth ? ($yScale.bandwidth() / 2) : 0)}
					style='stroke: {tickColor}'
				></line>
			{/if}
			<text
				class='label-text'
				filter="url(#barYcover)"
				x='{xTick}'
				y='{(yTick + (isBandwidth ? $yScale.bandwidth() / 2 : 0))-2}'
				dx='{10}'
				dy='{isBandwidth ? 4 : dyTick}'
			>
				{i == tickVals.length - 1 ? prefix + formatTick(tick) + suffix : formatTick(tick)}
			</text>
		</g>
	{/each}
</g>

<style>
	.label-text {
		text-anchor: start;
		fill: black;
		font-size: 12px;
	}
	.tick {
		font-size: .8em;
	}

	.dashed {
		stroke-dasharray: 2;
	}

	.tick.tick-0 line {
		stroke-dasharray: 0;
	}
</style>
