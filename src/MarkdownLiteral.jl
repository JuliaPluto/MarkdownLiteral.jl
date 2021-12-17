module MarkdownLiteral

import HypertextLiteral, CommonMark

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

end