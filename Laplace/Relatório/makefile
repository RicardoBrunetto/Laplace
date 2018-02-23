all: clear
	@echo "\n\tSucesso!\n"

compile:
	@pdflatex --interaction=batchmode Documento


clear: compile
	@rm -f *.synctex.gz
	@rm -f *.aux
	@rm -f *.log
	@rm -f *.out
	@rm -f *.blg
	@rm -f *.bbl
