\NeedsTeXFormat{LaTeX2e}[2021/11/15]
\ProvidesClass{rhelderhandout}[Opinionated class for handouts]

% Build on 'article' document class {{{1

\DeclareKeys{
  class.if = rhh@class,
  titlesec.code = \PassOptionsToPackage{#1}{titlesec},
  rhelder.code = \PassOptionsToPackage{#1}{rhelder},
  biblatex.code = \PassOptionsToPackage{biblatex={#1}}{rhelder},
  twoside.code = \OptionNotUsed,
  draft.code = \OptionNotUsed,
  openright.code = \OptionNotUsed,
  titlepage.code = \OptionNotUsed,
  leqno.code = \OptionNotUsed,
  fleqn.code = \OptionNotUsed,
  openbib.code = \OptionNotUsed,
}

\DeclareUnknownKeyHandler{\PassOptionsToClass{#1}{article}}

\protected\def\rhh@error#1#2{\ClassError{rhelderhandout}{#1}{#2}}
\protected\def\rhh@warning#1#2{\ClassWarning{rhelderhandout}{#1}{#2}}

\ProcessKeyOptions
\LoadClass{article}

% Load packages {{{1

\RequirePackage[pagestyles]{titlesec}
\RequirePackage{etoolbox}
\AtEndOfClass{\RequirePackage{rhelder}}

% Title {{{1

\def\@maketitle{%
  \begin{center}
    \LARGE
    \rhh@title
  \end{center}
  \par
  \vskip 1.5em
}

\RenewDocumentCommand{\title}{m}{\def\@title{#1}\def\rhh@title{#1}}
\RenewDocumentCommand{\author}{m}{\def\@author{#1}\def\rhh@author{#1}}
\RenewDocumentCommand{\date}{m}{\def\@date{#1}\def\rhh@date{#1}}

\def\rhh@title{\rhh@error{No \noexpand\title given}{\@ehc}}
\def\rhh@author{\rhh@warning{No \noexpand\author given}}
\def\rhh@date{\today}

% Page styles {{{1

\renewpagestyle{plain}{\rhh@setfoot}

\newpagestyle{handout}{
  \headrule
  \sethead
    {\firsttitlemarks\emph{\sectiontitle}}
    {}
    {}
  \rhh@setfoot
}

\ifbool{rhh@class}{
  \def\rhh@setfoot{
    \setfoot
      {\rhh@class, \rhh@institution}
      {\thepage}
      {\copyright\ \rhh@date\ \rhh@author}
  }

  \NewDocumentCommand{\class}{m}{\def\rhh@class{#1}}
  \NewDocumentCommand{\institution}{m}{\def\rhh@institution{#1}}

  \def\rhh@class{\rhh@error{No \noexpand\class given}{\@ehc}}
  \def\rhh@institution{\rhh@error{No \noexpand\institution given}{\@ehc}}

}{
  \def\rhh@setfoot{
    \setfoot
      {\rhh@author}
      {\thepage}
      {\rhh@date}
  }
}

\AtBeginDocument{\pagestyle{handout}}
\AtEndOfClass{\geometry{vcentering}}

% }}}1
