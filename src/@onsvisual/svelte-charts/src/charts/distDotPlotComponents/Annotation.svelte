<script>

export let id, position, path, textAnchor, fontSize, opacity, text, stroke, x, y;

</script>

<g class={"annotation"+id}

			transform={"translate("+position[0]+","+position[1]+")"}>
		
				<path
				d={path}
				{stroke}
                {opacity}
                fill="none"
				></path>

				<text
				{x}
				{y}
                {opacity}
				stroke="none"
				fill={stroke}
				font-size={fontSize}
				text-anchor={textAnchor}
				>{text}
                </text>~
</g>