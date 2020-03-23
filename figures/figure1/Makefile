.SECONDARY:
#.DELETE_ON_ERROR:

all : figure1.pdf


figure1.pdf : latex/figure1.pdf
	cp $< $@

latex/figure1.pdf : cartoon-panels
	cd latex && latexmk -pdf figure1.tex && cp figure1.pdf ../ ;\
	latexmk -c

cartoon-panels : cartoons/cpm-cartoon.pdf

panels=panelB panelD panelE
simulation-panels : $(foreach p, $(panels), plots/F2$(p).pdf)



