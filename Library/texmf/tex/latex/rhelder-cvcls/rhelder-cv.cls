\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{rhelder-cv}[2023-11-01 Opinionated class for academic CV]

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

% Load packages

\RequirePackage{titlesec}
\RequirePackage{tabulary}
\RequirePackage{enumitem}
\RequirePackage{pifont}

% Redefine `\maketitle` and title fields

\newcommand*{\@name}{}
\newcommand*{\@jobtitle}{}
\newcommand*{\@affiliation}{}
\newcommand*{\@contact}{}
\NewDocumentCommand{\name}{m}{\renewcommand*{\@name}{#1}}
\NewDocumentCommand{\jobtitle}{m}{\renewcommand*{\@jobtitle}{#1}}
\NewDocumentCommand{\affiliation}{m}{\renewcommand*{\@affiliation}{#1}}
\NewDocumentCommand{\contact}{m}{\renewcommand*{\@contact}{#1}}

\def\@maketitle{%
    \begin{center}%
        {\Large \bfseries \@name \par}%
        \vspace{1.53ex plus 0.13ex}%
        {\large \@date \par}%
        \vspace{2.3ex plus 0.2ex}%
        {%
            \normalsize
            \begin{tabular}[t]{c}%
                \@jobtitle \\
                \@affiliation \\
                \@contact
            \end{tabular}
        }%
    \end{center}%
    \par
}

% Add rules below section headings and suppress printing of all section
% headings
\titleformat{\section}{\Large\bfseries}{}{0em}{}[\titlerule]
\setcounter{secnumdepth}{0}

% Change `itemize` label and remove excess spacing within lists
\setlist[itemize]{label=\ding{118}}
\setlist{nosep}

% Define environments suitable for each section likely to be found in an
% academic CV

% Define an environment for listing degrees, dates, and institutions; `\item`
% has the format
% \item{<degree>}[<date>]{<institution>}[<date>][<institution>][<date>]
\NewDocumentEnvironment{education}{}{%
    \NewCommandCopy{\defitem}{\item}%
    \RenewDocumentCommand{\item}{momooo}{%
        \defitem[##1]
            \IfValueTF{##2}{\hfill ##2\\}{\\}
            ##3 \IfValueTF{##4}{\hfill ##4\\}{}
            \IfValueTF{##5}{##5}{}
            \IfValueTF{##6}{\hfill ##6}{}
    }%
    \begin{description}
}{%
    \end{description}
}

% Define an environment for listing research interests by type (conventionally,
% by AOS and AOC). `\item` has the format
% \item{<type>}{<description>}
\NewDocumentEnvironment{research}{}{%
    \RenewDocumentCommand{\item}{mm}{%
        \textbf{##1} & ##2 \\
    }%
    \noindent\tabulary{\textwidth}{@{}>{\bfseries}lJ@{}}
}{%
    \endtabulary
}

% Define an environment for listing academic presentations, grouped by paper.
% The list of papers is unnumbered, since it is not the number of papers that
% matters so much as the number of presentations, and the events at which the
% paper was presented are bulleted under each paper. (These could probably be
% numbered, if desired, but this seems simpler and thus aesthetically
% preferable).
\NewDocumentEnvironment{papers}{}{%
    \newlist{talks}{itemize}{5}
    \setlist[talks]{label=\ding{118}}
    \begin{enumerate}[label=,leftmargin=0em,beginpenalty=10000]
}{%
    \end{enumerate}
}

% Define an environment for listing awards or fellowships. If one had very many
% of these, it would probably be better to simply enumerate them; otherwise, it
% is probably worthwhile to describe the award rather than just state its name.
% Thus, this section is formatted after the same fashion as the 'Education'
% section, with the three components being the name of the award, the date, and
% a description. The format of `\item` is
% \item{<award>}[<date>]{<description>}
\NewDocumentEnvironment{awards}{}{%
    \NewCommandCopy{\defitem}{\item}%
    \RenewDocumentCommand{\item}{mom}{%
        \defitem[##1]
        \IfValueTF{##2}{\hfill ##2\\}{\\}
        ##3
    }%
    \begin{description}
}{%
    \end{description}
}

% Define an environment for listing service activities. Again, under some
% circumstances it might be better to just enumerate these, but in my case it
% worked better to offer a description in the same format as that for
% awards/fellowships. The format of `\item` is thus
% \item{<service>}[<date>]{<description>}
\NewDocumentEnvironment{service}{}{%
    \NewCommandCopy{\defitem}{\item}%
    \RenewDocumentCommand{\item}{mom}{%
        \defitem[##1]
        \IfValueTF{##2}{\hfill ##2\\}{\\}
        ##3
    }%
    \begin{description}
}{%
    \end{description}
}
