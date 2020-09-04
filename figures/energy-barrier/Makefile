.SECONDARY:
.DELETE_ON_ERROR:

all: latex/energy.pdf

figs : plots/energies.pdf plots/lambda-energy.pdf
	touch $@

lambdas=0 40 80 160 320 640 1000
imglambda=80



data/energies.txt : $(foreach l, $(lambdas), data/energy-$(l).txt )
	cat $^ > $@

data/energy-%.txt : barrier.js | data
	node $< -l $* -i $(imglambda) | awk -F "\t" -v lact=$* '{print lact, $$0}' > $@

latex/energy.pdf : latex/energy.tex figs
	cd latex && pdflatex energy.tex



# This script makes two plots (panels A,C)
plots/energies.pdf : plot-barrier.R data/energy-$(imglambda).txt data/energy-160.txt | plots
	Rscript $^ $@ plots/diagram.pdf


# panel D:
plots/lambda-energy.pdf : plot-barrier-lambda.R data/energies.txt | plots
	Rscript $^ $@

plots :
	mkdir -p $@


data :
	mkdir -p $@