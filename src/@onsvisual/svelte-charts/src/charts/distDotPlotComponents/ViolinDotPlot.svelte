<script>

export let key, x, yPosition, violinPlotData, violinFuncs, seriesParametersArray, circleData, label, labelYValue = 0, backgroundToLabel = true, labelFontSize = "14px", radius=8;

</script>

<g class="plot-group"
transform={"translate("+0+","+yPosition+")"}>

    {#if !key}

        <line
        y1=0
        y2=0
        x1=5
        x2={x(Math.min(...circleData))}
        stroke="#e0dede"
        fill="none"
        stroke-width="0.5px"
        opacity=1
        ></line>

    {/if}

    <g class="distribution-curve-group">

        {#each violinFuncs as violinFunc}

            <path
            d={violinFunc(violinPlotData)}
            stroke="none"
            fill="#e0dede"
            opacity=1
            ></path>
            
        {/each}
    
    </g>

    {#each seriesParametersArray as series, j}
        <circle
        cx={x(circleData[j])}
        cy={circleData.length == 2 ? (Math.abs(x(circleData[0])-x(circleData[1]))>10 ? 0 : [4,-4][j]) : 0}
        r={radius}
        stroke="white"
        fill={series["color"]}
        stroke-width="1.5px"
        ></circle>
    {/each}

    {#if !key}

        {#if backgroundToLabel}

            <text class="subdomain-labels-border"
            y={4+labelYValue}
            x=0
            stroke="white"
            fill="white"
            font-size="14px"
            text-anchor="start"
            stroke-width="6px"
            >{label}</text>

        {/if}

        <text class="subdomain-labels-main"
        y={4+labelYValue}
        x=0
        stroke="none"
        fill="#333"
        font-size={labelFontSize}
        text-anchor="start"
        >{label}</text>

    {/if}

</g>
