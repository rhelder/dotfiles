# Comprehensively lists dependencies for conversion from 'markdown' to 'latex'
# and 'html'. Tailor to specific projects by removing targets or dependencies.

input := $(wildcard *.md)

latex_defaults := ${XDG_DATA_HOME}/pandoc/defaults/latex.yaml
latex_output := $(input:.md=.tex)

html_defaults := ${XDG_DATA_HOME}/pandoc/defaults/html.yaml
html_output := $(input:.md=.html)

handout_metadata := ${XDG_DATA_HOME}/pandoc/metadata/handout.yaml

latex_deps := $(input)
latex_deps += $(latex_defaults)
latex_deps += ${XDG_DATA_HOME}/pandoc/custom/latex.lua
latex_deps += ${XDG_DATA_HOME}/pandoc/metadata/latex.yaml
latex_deps += ${XDG_DATA_HOME}/pandoc/templates/custom.latex
latex_deps += ${HOME}/Library/texmf/tex/latex/rhelderhandout/rhelderhandout.cls
latex_deps += ${HOME}/Library/texmf/tex/latex/rhelder/rhelder.sty
latex_deps += ${HOME}/Library/texmf/bibtex/bib/my_library.bib

html_deps := $(input)
html_deps += $(html_defaults)
html_deps += ${XDG_DATA_HOME}/pandoc/templates/default.html5
html_deps += ${XDG_DATA_HOME}/pandoc/templates/styles.html
html_deps += ${XDG_DATA_HOME}/pandoc/templates/styles.citations.html
html_deps += ${XDG_DATA_HOME}/pandoc/csl/chicago-author-date-shorttitles.csl
html_deps += ${XDG_DATA_HOME}/pandoc/my_library.yaml

latex_deps += $(handout_metadata)
html_deps += $(handout_metadata)

all: $(latex_output) $(html_output)

$(latex_output): $(latex_deps)
	pandoc --defaults=$(latex_defaults) \
		--metadata-file=$(handout_metadata) \
		--biblatex \
		--output=$(latex_output) $(input)

$(html_output): $(html_deps)
	pandoc --defaults=$(html_defaults) \
		--metadata-file=$(handout_metadata) \
		--output=$(html_output) $(input)
