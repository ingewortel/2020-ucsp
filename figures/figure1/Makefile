.SECONDARY:
.DELETE_ON_ERROR:

all : figure1.pdf

# =============================== SETTINGS =====================================
# path to here from ../scripts/simulation/ where scripts are
pathToHere=../../figure1

# number of simulations
NSIM=20
SIMULATIONS := $(shell seq 1 ${NSIM})

# for the example tract with act model: lambda_act, max_act, and number of tracks
# to plot:
EXAMPLELACT=200
EXAMPLEMACT=30
EXAMPLEN=5


# ================================ FIGURE ======================================

figure1.pdf : latex/figure1.pdf
	cp $< $@

latex/figure1.pdf : latex/figure1.tex cartoon-panels simulation-panels
	cd latex && latexmk -pdf figure1.tex && cp figure1.pdf ../ ;\
	latexmk -c

cartoon-panels : cartoons/cpm-cartoon.pdf cartoons/brownian-example-track.pdf \
	cartoons/act-example-tracks.pdf

panels=panelE
simulation-panels : $(foreach p, $(panels), plots/F2$(p).pdf)



# =============================== PANEL E =======================================
# Example brownian tracks. To get brownian motion, we simply set max_act and lambda_act
# both to zero (although setting either one to zero would already work). 
data/tracks/CPM2D-lact0-mact0-sim%.txt : ../scripts/simulation/simple-track.js \
	settings/conf-2D.js | data/tracks
	@echo "...Brownian sim $*.. " && node $< "$(pathToHere)/settings/conf-2D.js" 0 0 "none" $* > $@

progress/brownian : $(foreach i, $(SIMULATIONS), data/tracks/CPM2D-lact0-mact0-sim$(i).txt ) | progress
	@touch $@

plots/brownian-example.pdf : ../scripts/plotting/plot-track-brownian.R progress/brownian | plots
	Rscript $< $@


# example actmodel tracks (for parameters, see settings on top of this makefile)
data/tracks/CPM2D-lact$(EXAMPLELACT)-mact$(EXAMPLEMACT)-sim%.txt : ../scripts/simulation/simple-track.js \
	settings/conf-2D.js | data/tracks
	@echo "...Act model sim $*.. " && \
	node $< "$(pathToHere)/settings/conf-2D.js" $(EXAMPLEMACT) $(EXAMPLELACT) "none" $* > $@

progress/exampletracks-act : $(foreach i, $(SIMULATIONS), data/tracks/CPM2D-lact$(EXAMPLELACT)-mact$(EXAMPLEMACT)-sim$(i).txt ) | progress
	@touch $@

plots/act-examples.pdf : ../scripts/plotting/plot-track-actmodel.R progress/exampletracks-act | plots
	Rscript $< $(EXAMPLELACT) $(EXAMPLEMACT) $(EXAMPLEN) 2 1000 $@

# Get the displacement analysis
plots/F2panelE.pdf : ../scripts/plotting/plot-displacement-actvsbrownian.R \
	progress/brownian progress/exampletracks-act | plots
	Rscript $< $(EXAMPLELACT) $(EXAMPLEMACT) $(NSIM) 2 5 $@


# ============================ FOLDERS/OTHER ====================================
# Automatically generate the directory structure.

data :
	@mkdir -p $@
	
data/tracks :
	@mkdir -p $@
	
plots : 
	@mkdir -p $@
	
progress :
	@mkdir -p $@
	
latex-clean : 
	rm -f latex/*.pdf
	
clean : latex-clean
	rm -f figure*.pdf && rm -rf data && rm -rf plots && rm -rf progress
