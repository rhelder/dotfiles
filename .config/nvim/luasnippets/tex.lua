local get_visual = function(args, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

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

return { -- not autosnippets
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

}, { -- autosnippets
  -- Preamble/package commands

  s('dc',
    {
      c(1, {
        sn(nil, fmta('\\documentclass[<>]{<>}', {
          i(1, '12pt, letterpaper'),
          i(2, 'article'),
        })),
        sn(nil, fmta('\\documentclass{<>}', {
          i(1, 'minimal'),
        })),
      }),
    }
  ),

  s({trig = '^([^%w_\\]?)pk', regTrig = true, wordTrig = false},
    {
      c(1, {
        sn(nil, fmta('\\usepackage{<>', {i(1)})),
        sn(nil, fmta('\\usepackage[<>]{<>', {i(2), i(1)})),
      }),
    }
  ),

  s('rk',
    {
      c(1, {
        sn(nil, fmta('\\RequirePackage{<>', {i(1)})),
        sn(nil, fmta('\\RequirePackage[<>]{<>', {i(2), i(1)})),
      }),
    }
  ),

  s('ptp',
    fmta('\\PassOptionsToPackage{<>}{<>', {
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

  s({trig = 'xx', wordTrig = false},
    {t('\\expandafter')}
  ),

  s('tl',
    fmta('\\title{<>}', {i(1)})
  ),

  s('dd',
    fmta('\\date{<>}', {i(1, '\\today')})
  ),

  s('bb',
    fmta(
      [[
        \begin{document}
        <>
        \end{document}
      ]],
      {i(0)}
    )
  ),

  s('mk', {t('\\maketitle')}),

  -- Quotations

  s('tq',
    {
      c(1, {
        sn(nil, fmta('\\textquote{<>}', {i(1)})),
        sn(nil, fmta('\\textquote[][<>]{<>}', {i(2), i(1)})),
      }),
    }
  ),

  s('tcq',
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

  s('tfq',
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

  -- Other

  s('cc',
    {
      c(1, {
        sn(nil, fmta('\\autocite{<>', {i(1)})),
        sn(nil, fmta('\\autocite[<>]{<>', {i(2), i(1)})),
        sn(nil, fmta('\\autocite[<>][<>]{<>', {i(1), i(3), i(2)})),
      }),
    }
  ),

  s('mc',
    fmta(
      [[
        %    \begin{macrocode}
        <>
        %    \end{macrocode}
      ]],
      {d(1, get_visual)}
    )
  ),

  s('tt',
    fmta('\\texttt{<>}', {d(1, get_visual)})
  ),

  s('ss',
    fmta('\\section{<>}', {i(1)})
  ),

  s('sbs',
    fmta('\\subsection{<>}', {i(1)})
  ),

  s('sbbs',
    fmta('\\subsubsection{<>}', {i(1)})
  ),
}
