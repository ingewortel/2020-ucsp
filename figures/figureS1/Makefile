.SECONDARY:
.DELETE_ON_ERROR:

all : figureS1.pdf


# ================================ FIGURE ======================================
# This figure contains no simulation data, and only requires the images in folders
# cartoons/ and example-img/.

figureS1.pdf : latex/figureS1.pdf
	cp $< $@

latex/figureS1.pdf : latex/figureS1.tex
	cd latex && latexmk -pdf figureS1.tex && cp figureS1.pdf ../ ;\
	latexmk -c


# ============================ FOLDERS/OTHER ====================================
# Automatically generate the directory structure.


latex-clean : 
	rm -f latex/*.pdf
	
clean : latex-clean
	rm -f figure*.pdf 
