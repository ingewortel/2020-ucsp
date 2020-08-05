.SECONDARY:
.DELETE_ON_ERROR:

all : figures.pdf supp-figures.pdf

figs=1 2 3 4 5 S1 S2 S3 S4 S5
mainfigs=1 2 3 4 5
suppfigs=S1 S2 S3 S4 S5

clean-all : $(foreach f, $(figs), clean-figure-$(f))

clean-figure-% :
	cd figure$* && make clean

all-figures : $(foreach f, $(figs), figure$(f)/figure$(f).pdf)

main-figures : $(foreach f, $(mainfigs), figure$(f)/figure$(f).pdf)
supp-figures : $(foreach f, $(suppfigs), figure$(f)/figure$(f).pdf)

# Combined figures
figures.pdf : latex/figures.pdf
	cp $< $@
	
latex/figures.pdf : latex/figures.tex  main-figures
	cd latex && latexmk -pdf figures.tex ;\
	latexmk -c

supp-figures.pdf : latex/supp-figures.pdf
	cp $< $@
	
latex/supp-figures.pdf : latex/supp-figures.tex  supp-figures
	cd latex && latexmk -pdf supp-figures.tex ;\
	latexmk -c



progress : 
	mkdir -p $@

# figures 1, 2, 5, and S1 do not depend on others. A lot of data generated in
# figure 2 and 5 will be used by other figures as well, so these need to be
# generated first. 
figure1/figure1.pdf : | progress
	cd figure1 && $(MAKE) && touch ../progress/figure1

figureS1/figureS1.pdf : figure1/figure1.pdf | progress
	cd figureS1 && $(MAKE) && touch ../progress/figureS1
	
progress/phase-diag : | progress
	cd phase-diagram && $(MAKE) && touch ../progress/phase-diag

figure2/figure2.pdf : figureS1/figureS1.pdf progress/phase-diag | progress
	cd figure2 && $(MAKE) && touch ../progress/figure2
	
figure5/figure5.pdf : figure2/figure2.pdf | progress
	cd figure5 && $(MAKE) && touch ../progress/figure5

# figures 3, 4, S3 analyze data from figure2
figure3/figure3.pdf : figure5/figure5.pdf figure2/figure2.pdf
	cd figure3 && $(MAKE) && touch ../progress/figure3

figure4/figure4.pdf : figure3/figure3.pdf figure2/figure2.pdf
	cd figure4 && $(MAKE) && touch ../progress/figure4

figureS3/figureS3.pdf : figure4/figure4.pdf figure2/figure2.pdf
	cd figureS3 && $(MAKE) && touch ../progress/figureS3
	
# figure S2 uses data from figure2 and figure3 
figureS2/figureS2.pdf : figureS3/figureS3.pdf figure3/figure3.pdf figure2/figure2.pdf
	cd figureS2 && $(MAKE) && touch ../progress/figureS2

# figures S4 and S5 use data from figure5 (skin simulations)
figureS4/figureS4.pdf : figureS2/figureS2.pdf figure5/figure5.pdf
	cd figureS4 && $(MAKE) && touch ../progress/figureS4

figureS5/figureS5.pdf : figureS4/figureS4.pdf figure5/figure5.pdf
	cd figureS5 && $(MAKE) && touch ../progress/figureS5





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
