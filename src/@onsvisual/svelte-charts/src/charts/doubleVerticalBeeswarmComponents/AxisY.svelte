<script>

export let maxValue, minValue, x, y;

</script>

{#each [2019, 2020] as year, i}

        <text
        text-anchor="middle"
        x={x(i)}
        y=-3
        stroke="none"
        fill="#333"
        font-size="16px"
        >{year}</text>

        <line
        x1={x(i)}
        x2={x(i)}
        y1=0
        y2={y(minValue)}
        stroke="black"
        ></line>

{/each}

<g
transform="translate(-65,0)">

    <line
    x1=0
    x2=0
    y1=0
    y2={y(minValue)}
    stroke="black"
    ></line>

    {#each [70,80,90,100,110,120] as d, i}

        {#if maxValue >= d && minValue <= d} 

            <line
            x1=0
            x2=-8
            y1={y(d)}
            y2={y(d)}
            stroke="black"
            ></line>

            <text
            text-anchor="end"
            x={-10}
            y={y(d)+5}
            stroke="none"
            fill="#333"
            font-size="14px"
            >{d}</text>

        {/if}

    {/each}

</g>
