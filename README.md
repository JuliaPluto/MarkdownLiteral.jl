# MarkdownLiteral.jl *(alpha release)*

The macro `@markdown` lets you write [Markdown](https://www.markdownguide.org/getting-started/) inside Pluto notebooks. *Here is an example:*

```julia
@markdown("""
# MarkdownLiteral.jl

The macro `@markdown` lets you write [Markdown](https://www.markdownguide.org/getting-started/) inside Pluto notebooks. *Here is an example:*
""")
```
> The Markdown parsing is powered by [CommonMark.jl](https://github.com/MichaelHatherly/CommonMark.jl), a Julia implementation of the [CommonMark](https://commonmark.org/) specification. Compared to Julia's [built-in Markdown parsing](https://docs.julialang.org/en/v1/stdlib/Markdown/), this system is more *predicatable* and *powerful*.

The macro `@markdown` lets you write [HTML](https://developer.mozilla.org/docs/Web/HTML) inside Pluto notebooks. *Here is an example:*

```julia
@markdown("""
<p>
	The macro <code>@markdown</code> lets you write <a href="https://developer.mozilla.org/docs/Web/HTML">HTML</a> inside Pluto notebooks.
	<em>Here is an example:</em>
</p>
""")
```

> HTML parsing and interpolation is powered by [HypertextLiteral.jl](https://github.com/MechanicalRabbit/HypertextLiteral.jl), an interpolation system that understands HTML, CSS and even JavaScript!

Did you see that? **It is the same macro!** But that's not all!

## Interpolation

You can unlock superpowers by combining `@markdown` with **interpolation** (using `$`). For our example, let's create some data:

```julia
films = [
	(title="Frances Ha", director="Noah Baumbach", year=2012)
	(title="Portrait de la jeune fille en feu", director="Céline Sciamma", year=2019)
	(title="De noorderlingen", director="Alex van Warmerdam", year=1992)
]
```
Now, we can use *interpolation* to display our data:
```julia
@markdown("""
My films:
$([
	"- **$(f.title)** ($(f.year)) by _$(f.director)_\n"
	for f in films
])
""")
```

This gives us:

> My films:
> - **Frances Ha** (2012) by _Noah Baumbach_
> - **Portrait de la jeune fille en feu** (2019) by _Céline Sciamma_
> - **De noorderlingen** (1992) by _Alex van Warmerdam_

Alternatively, you could write this using HTML instead of Markdown (*with the same macro!*):

```julia
@markdown("""
<p>My films:</p>
<ul>
$([
	@markdown("<li>
		<b>$(f.title)</b> ($(f.year)) by <em>$(f.director)</em>
	</li>")
	for f in films
])
</ul>
""")
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
@markdown("$((
	@markdown("<div style=$((
        font_weight=900,
		padding=".5em",
		background=log.urgent ? "pink" : "lightblue",
	))>$(log.text)</div>")
	for log in logs
))")
```
Result:

![](https://user-images.githubusercontent.com/6933510/146623300-316e5a17-2daf-43ed-b70c-6c33278faf32.png)


# Old README

> ### [DEMO NOTEBOOK](https://htmlview.glitch.me/?https://gist.github.com/fonsp/29015dc6fd9438cd164a51fe3bef117d)

<details><summary>Screenshots</summary>

![Schermafbeelding 2021-12-16 om 13 17 09](https://user-images.githubusercontent.com/6933510/146370539-3c6245f7-c171-45d7-928d-083212569de8.png)

![Schermafbeelding 2021-12-16 om 13 15 48](https://user-images.githubusercontent.com/6933510/146370562-6636c73b-61a1-40d8-93c2-b631ba95af98.png)

</details>

# Features
The list of features is really simple to explain: it is everything that CommonMark gives, plus everything that HypertextLiteral gives! This includes:
- CommonMark! Markdown but less glitchy!
- Really flexible interpolation support with infinite nesting and syntax highlighting (since it is a `@markdown("""` macro instead of `md"""`)
- Interpolate Julia objects into `<script>` to automatically convert to JS literals
- Context-aware HTML escaping
- Automatic quote wrapping for HTML attributes
- Use a `Dict` or `NamedTuple` for the `style` attribute inside an HTML tag

# Implementation

Also cool: the code is extremely short!
```julia
macro md(expr)
	cm_parser = CommonMark.Parser()
	quote
		result = @htl($expr)
		htl_output = repr(MIME"text/html"(), result)

		$(cm_parser)(htl_output)
	end
end
```

It is essentially the `@htl` macro for HypertextLiteral.jl, but the result is passed through a CommonMark parser. This works, because:
- CommonMark allows raw HTML
- HypertextLiteral leaves literal content unchanged, so `hello *world*` appears exactly as-is!
