# Comprehensively lists dependencies for conversion from 'markdown' to 'latex'
# and 'html'. Tailor to specific projects by removing targets or dependencies.

input := $(wildcard *.md)

latex_handout_defaults := ${XDG_DATA_HOME}/pandoc/defaults/handout_latex.yaml
latex_defaults := ${XDG_DATA_HOME}/pandoc/defaults/latex.yaml
latex_output := $(input:.md=.tex)

html_handout_defaults := ${XDG_DATA_HOME}/pandoc/defaults/handout_html.yaml
html_defaults := ${XDG_DATA_HOME}/pandoc/defaults/html.yaml
html_output := $(input:.md=.html)

handout_metadata := ${XDG_DATA_HOME}/pandoc/metadata/handout.yaml

latex_deps := $(input)
latex_deps += ${XDG_DATA_HOME}/pandoc/custom/latex.lua
latex_deps += $(latex_handout_defaults)
latex_deps += $(handout_metadata)
latex_deps += $(latex_defaults)
latex_deps += ${XDG_DATA_HOME}/pandoc/metadata/latex.yaml
latex_deps += ${XDG_DATA_HOME}/pandoc/templates/custom.latex
latex_deps += ${HOME}/Library/texmf/tex/latex/rhelderhandout/rhelderhandout.cls
latex_deps += ${HOME}/Library/texmf/tex/latex/rhelder/rhelder.sty
latex_deps += ${HOME}/Library/texmf/bibtex/bib/my_library.bib

html_deps := $(input)
html_deps += $(html_handout_defaults)
html_deps += $(handout_metadata)
html_deps += $(html_defaults)
html_deps += ${XDG_DATA_HOME}/pandoc/templates/default.html5
html_deps += ${XDG_DATA_HOME}/pandoc/templates/styles.html
html_deps += ${XDG_DATA_HOME}/pandoc/templates/styles.citations.html
html_deps += ${XDG_DATA_HOME}/pandoc/styles/chicago-author-date-shorttitles.csl
html_deps += ${XDG_DATA_HOME}/pandoc/my_library.yaml

all: $(latex_output) $(html_output)

$(latex_output): $(latex_deps)
	pandoc --defaults=$(latex_handout_defaults) \
		--output=$(latex_output) $(input)

$(html_output): $(html_deps)
	pandoc --defaults=$(html_handout_defaults) \
		--output=$(html_output) $(input)
