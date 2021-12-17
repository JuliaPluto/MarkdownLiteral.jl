# MarkdownLiteral.jl *(beta release)*
HypertextLiteral.jl + CommonMark.jl = 🤯

A combination of [HypertextLiteral.jl](https://github.com/MechanicalRabbit/HypertextLiteral.jl) by @clarkevans and CommonMark.jl, and I think it is really cool!!

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