module MarkdownLiteral

import HypertextLiteral, CommonMark

macro md(expr)
    cm_parser = CommonMark.Parser()
    CommonMark.enable!(cm_parser, CommonMark.MathRule())
    quote
        result = $(esc(Expr(:macrocall, HypertextLiteral.var"@htl", __source__, expr)))
        htl_output = repr(MIME"text/html"(), result)

        $(cm_parser)(htl_output)
    end
end

end