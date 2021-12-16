module MarkdownLiteral

import HypertextLiteral, CommonMark

macro md(expr)
    cm_parser = CommonMark.Parser()
    enable!(cm_parser, MathRule())
    quote
        result = HypertextLiteral.@htl($expr)
        htl_output = repr(MIME"text/html"(), result)

        $(cm_parser)(htl_output)
    end
end

end