\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{rhelderhandout}[2024/12/05 Opinionated class for handouts]

\RequirePackage{etoolbox}
\protected\def\rhh@error{\ClassError{rhelderhandout}}
\protected\def\rhh@warning{\ClassWarning{rhelderhandout}}

% Options {{{1

\DeclareOption{class}{\booltrue{rhh@class}}

\newbool{rhh@class}

\DeclareOption{twoside}{\OptionNotUsed}
\DeclareOption{draft}{\OptionNotUsed}
\DeclareOption{titlepage}{\OptionNotUsed}
\DeclareOption{leqno}{\OptionNotUsed}
\DeclareOption{fleqn}{\OptionNotUsed}
\DeclareOption{openbib}{\OptionNotUsed}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions\relax

% Load dependencies {{{1
\LoadClass{article}
\RequirePackage[pagestyles]{titlesec}
\RequirePackage{rhelder}

% Title {{{1
\def\@maketitle{%
  \begin{center}
    \LARGE
    \rhh@title
  \end{center}
  \par
  \vskip 1.5em%
}

% Page styles {{{1

\renewpagestyle{plain}{\rhh@setfoot}
\newpagestyle{handout}{
  \headrule
  \sethead{%
    \ifdefempty{\sectiontitle}{%
      \firsttitlemarks\texttitle{\rhh@title}%
    }{%
      \firsttitlemarks\texttitle{\sectiontitle}%
    }%
  }{}{}
  \rhh@setfoot
}
\def\rhh@title{\rhh@error{No\space \protect\title\space given}{\@ehc}}

\ifbool{rhh@class}{
  \def\rhh@setfoot{
    \setfoot
      {\rhh@class, \rhh@institution}
      {\thepage}
      {\copyright{} \rhh@copyrightyear{} \rhh@author}
  }
  \def\rhh@class{Philosophy 25A}
  \def\rhh@institution{UC Berkeley}
  \def\rhh@copyrightyear{2024}
  \NewDocumentCommand{\class}{m}{\def\rhh@class{#1}}
  \NewDocumentCommand{\institution}{m}{\def\rhh@institution{#1}}
  \NewDocumentCommand{\copyrightyear}{m}{\def\rhh@copyrightyear{#1}}
}{
  \def\rhh@setfoot{
    \setfoot
      {\rhh@author}
      {\thepage}
      {\rhh@date}
  }
  \def\rhh@author{\rhh@warning{No\space \protect\author\space given}}
  \def\rhh@date{\today}
}

\RenewDocumentCommand{\title}{m}{%
  \def\rhh@title{#1}%
}
\RenewDocumentCommand{\author}{m}{%
  \def\rhh@author{#1}%
}
\RenewDocumentCommand{\date}{m}{%
  \def\rhh@date{#1}%
}

\AtBeginDocument{\pagestyle{handout}}
\geometry{vcentering}

% }}}1
