local function tcq_with_postnote(_, parent)
  if parent.snippet.stored.punct.nodes[1]['static_text'][1] == '<punct>' then
    return sn(nil, {
      t('\\textcquote['),
      r(3, 'postnote'),
      t(']{'),
      r(2, 'cite'),
      t('}{'),
      r(1, 'text'),
      t('}'),
    })
  else
    return sn(nil, {
      t('\\textcquote['),
      r(4, 'postnote'),
      t(']{'),
      r(3, 'cite'),
      t('}['),
      r(2, 'punct'),
      t(']{'),
      r(1, 'text'),
      t('}'),
    })
  end
end

local function tcq_with_prenote(_, parent)
  if parent.snippet.stored.punct.nodes[1]['static_text'][1] == '<punct>' then
    return sn(nil, {
      t('\\textcquote['),
      r(2, 'prenote'),
      t(']['),
      r(4, 'postnote'),
      t(']{'),
      r(3, 'cite'),
      t('}{'),
      r(1, 'text'),
      t('}'),
    })
  else
    return sn(nil, {
      t('\\textcquote['),
      r(3, 'prenote'),
      t(']['),
      r(5, 'postnote'),
      t(']{'),
      r(4, 'cite'),
      t('}['),
      r(2, 'punct'),
      t(']{'),
      r(1, 'text'),
      t('}'),
    })
  end
end

return {
  -- Preamble/package commands

  s('dc',
    fmta('\\documentclass[<>]{<>}', {
      i(1, '12pt, letterpaper'),
      i(2, 'article'),
    })
  ),

  s('pk',
    {
      c(1, {
        sn(nil, fmta('\\usepackage{<>}', {i(1)})),
        sn(nil, fmta('\\usepackage[<>]{<>}', {i(2), i(1)})),
      }),
    }
  ),

  s('qk',
    {
      c(1, {
        sn(nil, fmta('\\RequirePackage{<>}', {i(1)})),
        sn(nil, fmta('\\RequirePackage[<>]{<>}', {i(2), i(1)})),
      }),
    }
  ),

  s('ptp',
    fmta('\\PassOptionsToPackage{<>}{<>}', {
      i(2, '<options>'),
      i(1, '<package>'),
    })
  ),

  s('nc',
    {
      c(1, {
        sn(nil, fmta('\\newcommand*{<>}', {i(1)})),
        sn(nil, fmta('\\newcommand*[<>]{<>}', {i(1), i(2)})),
        sn(nil, fmta('\\newcommand{<>}', {i(1)})),
        sn(nil, fmta('\\newcommand[<>]{<>}', {i(1), i(2)})),
      })
    }
  ),

  s('rc',
    {
      c(1, {
        sn(nil, fmta('\\renewcommand*{<>}', {i(1)})),
        sn(nil, fmta('\\renewcommand*[<>]{<>}', {i(1), i(2)})),
        sn(nil, fmta('\\renewcommand{<>}', {i(1)})),
        sn(nil, fmta('\\renewcommand[<>]{<>}', {i(1), i(2)})),
      })
    }
  ),

  s('ndc',
    fmta('\\NewDocumentCommand{<>}{<>}{<>}', {i(1), i(2), i(3)})
  ),

  s('rdc',
    fmta('\\RenewDocumentCommand{<>}{<>}{<>}', {i(1), i(2), i(3)})
  ),

  s('ncc',
    fmta('\\NewCommandCopy\\<>\\<>', {i(1), i(2)})
  ),

  s('rcc',
    fmta('\\RenewCommandCopy\\<>\\<>', {i(1), i(2)})
  ),

  s('dd',
    fmta(
      [[
        \begin{document}
        <>
        \end{document}
      ]],
      {i(0)}
    )
  ),

  -- Quotations

  s({trig = 'tq', snippetType = 'autosnippet'},
    {
      c(1, {
        sn(nil, fmta('\\textquote{<>}', {i(1)})),
        sn(nil, fmta('\\textquote[][<>]{<>}', {i(2), i(1)})),
      }),
    }
  ),

  s({trig = 'tcq', snippetType = 'autosnippet'},
    {
      c(1, {
        sn(nil, {
          t('\\textcquote{'),
          r(2, 'cite'),
          t('}{'),
          r(1, 'text'),
          t('}'),
        }),
        sn(nil, {
          t('\\textcquote{'),
          r(3, 'cite'),
          t('}['),
          r(2, 'punct'),
          t(']{'),
          r(1, 'text'),
          t('}'),
        }),
        d(nil, tcq_with_postnote, {}),
        d(nil, tcq_with_prenote, {}),
      }, {restore_cursor = true}),
    },
    {
      stored = {
        ['prenote'] = i(nil, '<prenote>'),
        ['postnote'] = i(nil, '<postnote>'),
        ['cite'] = i(nil, '<cite>'),
        ['punct'] = i(nil, '<punct>'),
        ['text'] = i(nil, '<text>'),
      },
    }
  ),

  s({trig = 'tfq', snippetType = 'autosnippet'},
    {
      c(1, {
        sn(nil, fmta('\\textquote{<>}', {i(1)})),
        sn(nil, fmta('\\textquote[][<>]{<>}', {i(2), i(1)})),
      }),
    }
  ),

  s('dq',
    fmta(
      [[
        \begin{displayquote}
          <>
        \end{displayquote}
      ]],
      {i(1)}
    )
  ),

  s('env',
    fmta(
      [[
        \begin{<>}
          <>
        \end{<>}
      ]],
      {i(1), i(2), rep(1)}
    )
  ),
}
