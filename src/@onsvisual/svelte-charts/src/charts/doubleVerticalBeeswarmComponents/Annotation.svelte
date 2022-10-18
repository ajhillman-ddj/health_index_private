<script>

export let id, position, path, textAnchor, fontSize, opacity, text, stroke, x, y, arrowhead;

</script>

<g class={"annotation"+id}

			transform={"translate("+position[0]+","+position[1]+")"}>

                {#if arrowhead}

                    <path
                    d="M1 -6 l6 6 l-6 6 z"
                    stroke="none"
                    fill={stroke}
                    {opacity}
                    ></path>

                {/if}
		
				<path
				d={path}
				{stroke}
                {opacity}
                fill="none"
				></path>

                {#each text as line, j}

                    <text
                    {x}
                    y={y+j*(fontSize+1)}
                    {opacity}
                    stroke="none"
                    fill={stroke}
                    font-size={fontSize+"px"}
                    text-anchor={textAnchor}
                    >{line}
                    </text>

                {/each}
</g>