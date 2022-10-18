<script>

export let x, y, data, visible, color;

</script>

{#each data as d, i}

    <line
    x1={x(0)}
    x2={x(1)}
    y1={y(d["value2019"])}
    y2={y(d["value"])}
    stroke={color}
    stroke-width="2px"
    opacity={visible ? 1 : 0}
    ></line>

{/each}