function Writer(doc, opts)
  local filter = {
    Quoted = function(element)
      if element.quotetype == 'SingleQuote' then
        table.insert(
          element.content,
          1,
          pandoc.RawInline('latex', '\\textquote{')
        )
        table.insert(
          element.content,
          pandoc.RawInline('latex', '}')
        )
        return element.content
      elseif element.quotetype == 'DoubleQuote' then
        table.insert(
          element.content,
          1,
          pandoc.RawInline('latex', '\\textquote{')
        )
        table.insert(
          element.content,
          pandoc.RawInline('latex', '}')
        )
        return element.content
      end
    end
  }

  return pandoc.write(doc:walk(filter), 'latex', opts)
end

Template = pandoc.template.default 'latex'
