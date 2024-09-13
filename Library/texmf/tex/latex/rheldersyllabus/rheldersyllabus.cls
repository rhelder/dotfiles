\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{rheldersyllabus}[2024-09-07 Opinionated class for syllabus]

% Declare options from `article` class not to be used

\DeclareOption{twoside}{\OptionNotUsed}
\DeclareOption{draft}{\OptionNotUsed}
\DeclareOption{titlepage}{\OptionNotUsed}
\DeclareOption{twocolumn}{\OptionNotUsed}
\DeclareOption{leqno}{\OptionNotUsed}
\DeclareOption{fleqn}{\OptionNotUsed}
\DeclareOption{openbib}{\OptionNotUsed}

% Pass remaining options to `article` class

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass{article}
\RequirePackage{rhelder}

\newcommand*{\@secnum}{}
\NewDocumentCommand{\secnum}{m}{\renewcommand*{\@secnum}{#1}}

\newcommand*{\@sectime}{}
\NewDocumentCommand{\sectime}{m}{\renewcommand*{\@sectime}{#1}}

\newcommand*{\@room}{}
\NewDocumentCommand{\room}{m}{\renewcommand*{\@room}{#1}}

\newcommand*{\@semester}{}
\NewDocumentCommand{\semester}{m}{\renewcommand*{\@semester}{#1}}

\RenewDocumentCommand{\@maketitle}{}{%
    \begin{center}
        \LARGE
        \@title{}
    \end{center}

    \begin{center}
        \begin{tabular}{lcr}
            \toprule
            Section \@secnum{} & Russell Wright Helder & UC Berkeley \\
            \@sectime{} & (You can call me \attn{Russ}) & \@semester{} \\
            \@room{} & \url{russell_helder@berkeley.edu} & \\
            \bottomrule
        \end{tabular}
    \end{center}
}
