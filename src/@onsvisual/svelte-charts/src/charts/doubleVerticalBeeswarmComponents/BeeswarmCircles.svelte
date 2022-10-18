<script>


export let data, visible, colors;

</script>

<g class="points">

    {#each data as point, i}

        {#if point["id"] == point["unique"] && visible}

            {#if point["id"] == "Average across England"}

                <path
                class="node"
                transform={"translate("+point.x+","+point.y+")"}
                d={"M0 "+(-point.r)+" L"+point.r+" 0 L 0 "+point.r+" L "+(-point.r) +" 0 z" }
                fill={colors["england"][0]}
                stroke="none"
                ></path>

            {:else}

                <circle
                class="node"
                r={point.r}
                fill={colors["mainLA"][0]}
                cx={point.x}
                cy={point.y}
                ></circle>

        
            {/if}

        {:else}

            <circle
            class="node"
            r={visible ? point.r : 12}
            fill={visible ? colors["surroundingLAs"][0] : "white"}
            cx={point.x}
            cy={point.y}
            ></circle>

        {/if}

    {/each}

</g>