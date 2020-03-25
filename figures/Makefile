.SECONDARY:
.DELETE_ON_ERROR:

all : all-figures

figs=1


clean-all : $(foreach f, $(figs), clean-figure-$(f))

clean-figure-% :
	cd figure$* && make clean

all-figures : $(foreach f, $(figs), figure$(f)/figure$(f).pdf)


progress : 
	mkdir -p $@


figure1/figure1.pdf : | progress
	cd figure1 && $(MAKE) && touch ../progress/figure1

figure2/figure2.pdf : figure1/figure1.pdf
	cd figure2 && $(MAKE) && touch ../progress/figure2


aux/setup : aux/nodesetup

aux/nodesetup : aux/Rsetup
	@echo "Installing node packages..." &&\
	npm install

aux/Rsetup : scripts/Rsetup.R aux/Rpackages.txt
	Rscript scripts/Rsetup.R aux/Rpackages.txt && touch $@

aux/Rpackages.txt :  aux/basics | aux
	@echo Searching for used R packages... && \
	grep -r "library(" scripts/*/*.R | sed "s/suppressMessages(//g" | sed "s/library(/ /g" | awk '{print $$2}' | sed 's/[),\,]//g' | sort | uniq > $@  && \
	grep -r "require(" scripts/*/*.R | sed "s/suppressMessages(//g" |  sed 's/require(/ /g' | awk '{print $$2}' | sed 's/[),\,]//g' | sort | uniq >> $@

aux/basics : | aux
	bash scripts/check-setup.sh && touch $@

aux : 
	mkdir -p $@
