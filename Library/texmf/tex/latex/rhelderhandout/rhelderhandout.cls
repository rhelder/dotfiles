\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{rhelderhandout}[2024-09-21 Opinionated class for handouts]

% Declare options from `article` class not to be used

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
\RequirePackage[nosecnum]{rhelder}

\RenewDocumentCommand{\@maketitle}{}{%
    \begin{center}
        \LARGE
        \@title
    \end{center}
    \par
    \vskip 1.5em%
}

\RequirePackage{titleps}
\geometry{vcentering}

\newcommand{\@class}{}
\newcommand{\@copyrightyear}{}
\NewDocumentCommand{\class}{m}{\renewcommand{\@class}{#1}}
\NewDocumentCommand{\copyrightyear}{m}{\renewcommand{\@copyrightyear}{#1}}

\NewDocumentCommand{\sethandoutfoot}{}{
    \setfoot{\@class{}, UC Berkeley}
        {\thepage}
        {\copyright{} \@copyrightyear{} Russell Wright Helder}
}

\newpagestyle{firsthandoutpage}{
    \sethandoutfoot
}

\newpagestyle{handout}{
    \headrule
    \sethead{\firsttitlemarks\textit{\sectiontitle}}{}{}
    \sethandoutfoot
}

\pagestyle{handout}
\apptocmd{\maketitle}{\thispagestyle{firsthandoutpage}}{}{}
