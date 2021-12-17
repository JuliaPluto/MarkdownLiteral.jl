using MarkdownLiteral
using Test

import HypertextLiteral

@test try
    var"@md"
    false
catch e
    e isa UndefVarError
end


import MarkdownLiteral: @md

@testset "Not much" begin

    code_snippet = """
    xs = [1:10..., 20]
    map(xs) do x
    	f(x^2)
    end
    """

    plot(x, y) = HypertextLiteral.@htl("""
    <script src="https://cdn.plot.ly/plotly-1.58.0.min.js"></script>

    <script>
        const container = html`<div style="width: 100%;"></div>`

        Plotly.newPlot( container, [{
            x: $(x),
            y: $(y),
        }], {
            margin: { t: 0, b:0, l: 0, r:0 } ,
    		height: 100,
        })

        return container
    </script>
    """)


    result = @md("""
    # Hello!
    This is *Markdown* but **supercharged**!!
    <marquee style=$((color="purple", font_family="cursive"))>Inline HTML supported!</marquee>

    Here is a list, created using simple string interpolation:
    $((
    	"- item $i\n" for i in 1:3
    ))

    Another list, interpolated as HTML:
    <ul>
    $((
    	HypertextLiteral.@htl("<li>item $i</li>") for i in 1:3
    ))
    </ul>

    ![](https://media.giphy.com/media/JmUfwENE6i4Jxig27n/giphy.gif)

    Hello ``world``

    ```math
    \\sqrt{1+1}
    ```

    ## Intepolating a plotly plot
    It works!
    $(plot(1:10, rand(10)))

    ## Code block
    ```julia
    function f(x::Int64)
    	"hello \$(x)"
    end


    # we can interpolate into code blocks!
    $(code_snippet)
    ```
    """)


    htmle = repr(MIME"text/html"(), result)

    @test htmle isa String
    @test occursin("Hello", htmle)
end