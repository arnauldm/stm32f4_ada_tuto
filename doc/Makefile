
TEX=$(wildcard *.tex)
PDF=$(patsubst %.tex, %.pdf, $(TEX))
BIB=$(patsubst %.tex, %.aux, $(TEX))

all: $(PDF)

%.pdf: %.tex
	pdflatex $^

full: $(TEX)
	pdflatex $^
	bibtex $(BIB)
	pdflatex $^
	pdflatex $^

clean:
	rm *.log *.aux *.out *.tex~ *.toc *.blg *.bbl *.bib~

