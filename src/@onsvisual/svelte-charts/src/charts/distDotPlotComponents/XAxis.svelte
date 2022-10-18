<script>

export let x, y, gridlinesParametersArray, fontSize = "14px"

</script>


<g class="x-gridlines">

    {#each gridlinesParametersArray as d, i}

        <text
        y=-6
        x={x(d["value"])}
        stroke="none"
        fill="#333"
        font-size={fontSize}
        text-anchor="middle"
        opacity={d["opacity"]*3}
        >{d["value"]}</text>

        <!-- svelte-ignore component-name-lowercase -->
        <line
        x1={x(d["value"])}
        x2={x(d["value"])}
        y1=0
        y2={y}
        stroke="#333"
        opacity={d["opacity"]}
        ></line>

    {/each}

</g>