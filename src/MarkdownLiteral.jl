module MarkdownLiteral

import HypertextLiteral, CommonMark

"""
```julia
@markdown(""\"
# MarkdownLiteral.jl

The macro `@markdown` lets you write [Markdown](https://www.markdownguide.org/getting-started/) inside Pluto notebooks. *Here is an example:*
""\")
```

You can also use the macro to write HTML!

```julia
@markdown(""\"
<p>
	The macro <code>@markdown</code> lets you write <a href="https://developer.mozilla.org/docs/Web/HTML">HTML</a> inside Pluto notebooks.
	<em>Here is an example:</em>
</p>
""\")
```


## Interpolation

You can unlock superpowers by combining `@markdown` with **interpolation** (using `\$`). For our example, let's create some data:

```julia
films = [
	(title="Frances Ha", director="Noah Baumbach", year=2012)
	(title="Portrait de la jeune fille en feu", director="Céline Sciamma", year=2019)
	(title="De noorderlingen", director="Alex van Warmerdam", year=1992)
]
```
Now, we can use *interpolation* to display our data:
```julia
@markdown(""\"
My films:
\$([
	"- **\$(f.title)** (\$(f.year)) by _\$(f.director)_\n"
	for f in films
])
""\")
```

This gives us:

> My films:
> - **Frances Ha** (2012) by _Noah Baumbach_
> - **Portrait de la jeune fille en feu** (2019) by _Céline Sciamma_
> - **De noorderlingen** (1992) by _Alex van Warmerdam_

Alternatively, you could write this using HTML instead of Markdown (*with the same macro!*):

```julia
@markdown(""\"
<p>My films:</p>
<ul>
\$([
	@markdown("<li>
		<b>\$(f.title)</b> (\$(f.year)) by <em>\$(f.director)</em>
	</li>")
	for f in films
])
</ul>
""\")
```

## Advanced interpolation

Because interpolation is powered by [HypertextLiteral.jl](https://github.com/MechanicalRabbit/HypertextLiteral.jl), you can use advanced features:
- Interpolated attributes are automatically escaped
- You can use a `NamedTuple` or `Dict` for the CSS `style` attribute
- Interpolating Julia objects into a `<script>` will automatically convert to JavaScript code(!)

For
```julia
logs = [
	(text="Info", urgent=false),
	(text="Alert", urgent=true),
	(text="Update", urgent=false),
]
```

```julia
@markdown("\$((
	@markdown("<div style=\$((
        font_weight=900,
		padding=".5em",
		background=log.urgent ? "pink" : "lightblue",
	))>\$(log.text)</div>")
	for log in logs
))")
```
Result:

![](https://user-images.githubusercontent.com/6933510/146623300-316e5a17-2daf-43ed-b70c-6c33278faf32.png)
"""
macro markdown(expr)
    cm_parser = CommonMark.Parser()
    CommonMark.enable!(cm_parser, [
        CommonMark.AdmonitionRule(),
        CommonMark.AttributeRule(),
        CommonMark.AutoIdentifierRule(),
        CommonMark.CitationRule(),
        CommonMark.FootnoteRule(),
        CommonMark.MathRule(),
        CommonMark.RawContentRule(),
        CommonMark.TableRule(),
        CommonMark.TypographyRule(),
    ])
    quote
        result = $(esc(Expr(:macrocall, getfield(HypertextLiteral, Symbol("@htl")), __source__, expr)))
        htl_output = repr(MIME"text/html"(), result)

        $(cm_parser)(htl_output)
    end
end

# Some aliases, it's up to you which one to import.

var"@markdownliteral" = var"@markdown"
var"@mdx" = var"@markdown"

end