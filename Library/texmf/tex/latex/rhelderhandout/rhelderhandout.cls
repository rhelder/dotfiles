\NeedsTeXFormat{LaTeX2e}[2021/11/15]
\ProvidesClass{rhelderhandout}[Opinionated class for handouts]

\RequirePackage{etoolbox}

\protected\def\rhh@error{\ClassError{rhelderhandout}}
\protected\def\rhh@warning{\ClassWarning{rhelderhandout}}

% Build on 'article' document class {{{1

\DeclareKeys{
  class.if = rhh@class,
  titlesec.code = \PassOptionsToPackage{#1}{titlesec},
  rhelder.code = \PassOptionsToPackage{#1}{rhelder},
  twoside.code = \OptionNotUsed,
  twoside.code = \OptionNotUsed,
  draft.code = \OptionNotUsed,
  titlepage.code = \OptionNotUsed,
  leqno.code = \OptionNotUsed,
  fleqn.code = \OptionNotUsed,
  openbib.code = \OptionNotUsed,
}

\DeclareUnknownKeyHandler{\PassOptionsToClass{#1}{article}}

\ProcessKeyOptions
\LoadClass{article}

% Modify 'article' title handling
\def\@maketitle{%
  \begin{center}
    \LARGE
    \rhh@title
  \end{center}
  \par
  \vskip 1.5em%
}

\RenewDocumentCommand{\title}{m}{\def\@title{#1}\def\rhh@title{#1}}
\RenewDocumentCommand{\author}{m}{\def\@author{#1}\def\rhh@author{#1}}
\RenewDocumentCommand{\date}{m}{\def\@date{#1}\def\rhh@date{#1}}

\def\rhh@title{\rhh@error{No \noexpand\title given}{\@ehc}}
\def\rhh@author{\rhh@warning{No \noexpand\author given}}
\def\rhh@date{\today}

% Page styles {{{1

\RequirePackage[pagestyles]{titlesec}
\renewpagestyle{plain}{\rhh@setfoot}

\newpagestyle{handout}{
  \headrule
  \sethead
    {%
      \ifdefempty{\sectiontitle}{%
        \firsttitlemarks\texttitle{\rhh@title}%
      }{%
        \firsttitlemarks\texttitle{\sectiontitle}%
      }%
    }
    {}
    {}
  \rhh@setfoot
}

\ifbool{rhh@class}{
  \def\rhh@setfoot{
    \setfoot
      {\rhh@class, \rhh@institution}
      {\thepage}
      {\copyright{} \rhh@copyrightyear{} \rhh@author}
  }

  \NewDocumentCommand{\class}{m}{\def\rhh@class{#1}}
  \NewDocumentCommand{\institution}{m}{\def\rhh@institution{#1}}
  \NewDocumentCommand{\copyrightyear}{m}{\def\rhh@copyrightyear{#1}}

  \def\rhh@class{Philosophy 25A}
  \def\rhh@institution{UC Berkeley}
  \def\rhh@copyrightyear{2024}

}{
  \def\rhh@setfoot{
    \setfoot
      {\rhh@author}
      {\thepage}
      {\rhh@date}
  }
}

\AtBeginDocument{\pagestyle{handout}}

\RequirePackage{rhelder}
\geometry{vcentering}

% }}}1
