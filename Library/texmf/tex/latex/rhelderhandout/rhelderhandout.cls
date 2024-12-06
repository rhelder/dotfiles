\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{rhelderhandout}[2024-12-05 Opinionated class for handouts]

\RequirePackage{etoolbox}

% Options {{{1

\newbool{@class}
\DeclareOption{class}{\booltrue{@class}}

\DeclareOption{twoside}{\OptionNotUsed}
\DeclareOption{draft}{\OptionNotUsed}
\DeclareOption{titlepage}{\OptionNotUsed}
\DeclareOption{leqno}{\OptionNotUsed}
\DeclareOption{fleqn}{\OptionNotUsed}
\DeclareOption{openbib}{\OptionNotUsed}

% Pass remaining options to `article` class
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}

% Title {{{1
\RenewDocumentCommand{\@maketitle}{}{%
    \begin{center}
        \LARGE
        \@title
    \end{center}
    \par
    \vskip 1.5em%
}

% Page styles {{{1

\RequirePackage[pagestyles]{titlesec}
\RequirePackage{rhelder}

\renewpagestyle{plain}{\sethandoutfoot}
\newpagestyle{handout}{
    \headrule
    \sethead{%
      \ifdefempty{\sectiontitle}{%
        \firsttitlemarks\textit{\rhh@title}%
      }{%
        \firsttitlemarks\textit{\sectiontitle}%
      }%
    }{}{}
    \sethandoutfoot
}

\AtBeginDocument{\pagestyle{handout}}
\geometry{vcentering}

\if@class
    \NewDocumentCommand{\sethandoutfoot}{}{
        \setfoot{\@class{}, \@institution{}}
        {\thepage}
        {\copyright{} \@copyrightyear{} \rhh@author}
    }
    \newcommand*{\@class}{Philosophy 25A}
    \newcommand*{\@institution}{UC Berkeley}
    \newcommand*{\@copyrightyear}{2024}
    \NewDocumentCommand{\class}{m}{\renewcommand*{\@class}{#1}}
    \NewDocumentCommand{\institution}{m}{\renewcommand*{\@institution}{#1}}
    \NewDocumentCommand{\copyrightyear}{m}{\renewcommand*{\@copyrightyear}{#1}}

\else
    \NewDocumentCommand{\sethandoutfoot}{}{
        \setfoot{\rhh@author}
        {\thepage}
        {\rhh@date}
    }
\fi

\NewCommandCopy\rhh@title\@title
\NewCommandCopy\rhh@author\@author
\NewCommandCopy\rhh@date\@date
\expandafter\apptocmd\csname title \endcsname{%
    \renewcommand*{\rhh@title}{#1}
}{}{}
\expandafter\apptocmd\csname author \endcsname{%
    \renewcommand*{\rhh@author}{#1}
}{}{}
\expandafter\apptocmd\csname date \endcsname{%
    \renewcommand*{\rhh@date}{#1}
}{}{}

% }}}1
