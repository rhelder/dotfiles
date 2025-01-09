\NeedsTeXFormat{LaTeX2e}[2021/11/15]
\ProvidesClass{rheldersyllabus}[Opinionated class for syllabus]

% Build on 'article' document class {{{1

\DeclareKeys{
  rhelder.code = \PassOptionsToPackage{#1}{rhelder},
  twoside.code = \OptionNotUsed,
  draft.code = \OptionNotUsed,
  openright.code = \OptionNotUsed,
  titlepage.code = \OptionNotUsed,
  leqno.code = \OptionNotUsed,
  fleqn.code = \OptionNotUsed,
  openbib.code = \OptionNotUsed,
}

\DeclareUnknownKeyHandler{\PassOptionsToClass{#1}{article}}

\protected\def\rhs@error#1#2{\ClassError{rheldersyllabus}{#1}{#2}}
\protected\def\rhs@warning#1#2{\ClassWarning{rheldersyllabus}{#1}{#2}}

\ProcessKeyOptions
\LoadClass{article}

% Load Packages {{{1

\usepackage{parskip}
\RequirePackage[pagestyles]{titlesec}
\RequirePackage{rhelder}

% Title {{{1

\def\@maketitle{%
  \begingroup
  \setlength\parskip{0pt plus 1pt}
  \begin{center}
    {\LARGE\rhs@title\par}%
    \vskip 1em
    {\Large\rhs@institution , \rhs@term\par}%
    \vskip 1em
    \begin{tabular*}{\textwidth}{l@{\extracolsep{\fill}}r}
      \toprule
      \textbf{\rhs@role} & \textbf{\rhs@detailsheading} \\
      \midrule
      \rhs@author & \rhs@classtime \\
      \rhs@callme & \rhs@room \\
      \url{\rhs@email} & \\
      \bottomrule
    \end{tabular*}
  \end{center}
  \par
  \vskip 1.5em
  \endgroup
}

\RenewDocumentCommand{\title}{m}{\def\@title{#1}\def\rhs@title{#1}}
\NewDocumentCommand{\institution}{m}{\def\rhs@institution{#1}}
\NewDocumentCommand{\term}{m}{\def\rhs@term{#1}}
\NewDocumentCommand{\role}{m}{\def\rhs@role{#1}}
\RenewDocumentCommand{\author}{m}{\def\@author{#1}\def\rhs@author{#1}}
\NewDocumentCommand{\callme}{m}{\def\rhs@callme{#1}}
\NewDocumentCommand{\email}{m}{\def\rhs@email{#1}}
\NewDocumentCommand{\detailsheading}{m}{\def\rhs@detailsheading{#1}}
\NewDocumentCommand{\classtime}{m}{\def\rhs@classtime{#1}}
\NewDocumentCommand{\room}{m}{\def\rhs@room{#1}}
\NewDocumentCommand{\class}{m}{\def\rhs@class{#1}}

\def\rhs@title{\rhs@error{No \noexpand\title given}{\@ehc}}
\def\rhs@institution{\rhs@error{No \noexpand\institution given}{\@ehc}}
\def\rhs@term{\rhs@error{No \noexpand\term given}{\@ehc}}
\def\rhs@role{\rhs@error{No \noexpand\role given}{\@ehc}}
\def\rhs@author{\rhs@error{No \noexpand\author given}{\@ehc}}
\def\rhs@callme{\rhs@error{No \noexpand\callme given}{\@ehc}}
\def\rhs@email{\rhs@error{No \noexpand\email given}{\@ehc}}
\def\rhs@detailsheading{\rhs@error{No \noexpand\detailsheading given}{\@ehc}}
\def\rhs@classtime{\rhs@error{No \noexpand\classtime given}{\@ehc}}
\def\rhs@room{\rhs@error{No \noexpand\room given}{\@ehc}}
\def\rhs@class{\rhs@error{No \noexpand\class given}{\@ehc}}

% Page Style {{{1

\newpagestyle{syllabus}{
  \headrule
  \sethead
    {\firsttitlemarks\emph{\sectiontitle}}
    {}
    {\rhs@class}
  \setfoot
    {\rhs@institution, \rhs@term}
    {\thepage}
    {\rhs@author}
}

\AtBeginDocument{\pagestyle{syllabus}}
\geometry{vcentering}
