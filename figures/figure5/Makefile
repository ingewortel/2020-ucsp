.SECONDARY:
.DELETE_ON_ERROR:

all : figure5.pdf

# =============================== SETTINGS =====================================
# path to here from ../scripts/simulation/ where scripts are
pathToHere=../../figure5

# Get other make variables from a general configuration file.
include ../settings.env

# ================================ FIGURE ======================================

figure5.pdf : latex/figure5.pdf
	cp $< $@

latex/figure5.pdf : latex/figure5.tex simulation-panels
	cd latex && latexmk -pdf figure5.tex && cp figure5.pdf ../ ;\
	latexmk -c


panels=panelD
simulation-panels : $(foreach p, $(panels), plots/F5$(p).pdf)

# ================================ PANEL D ======================================
# Speed persistence plots for skin.

# STEP 1: Simulate tracks. The raw tracks will be saved under:
#	data/tracks/CPMskin-lact[value]-mact[value]-sim[value]-tissue["stiff"/"deformable"].txt
# 
# Automatically generate a Makefile with a recipe for each of the tracks to generate.
# This ensures that these can then be generated in parallel. 
data/mkfiles/CPMskin.make : ../scripts/simulation/simulations-tissue-makeout.sh \
	settings/paramsskin.txt settings/conf-skin.js | data/mkfiles
	bash $< ../scripts/simulation settings/conf-skin.js settings/paramsskin.txt \
		$(NSIM) CPMskin $(pathToHere) > $@

# To actually generate the tracks, call "make" on the Makefile generated in the 
# previous step. The required scripts are in the dependencies to ensure that tracks
# are updated whenever the underlying scripts change.
# Also ensure that the 'progress' and 'data/tracks' folders exist before the simulations
# are started. The recipe itself ensures that any old tracks are first removed, and
# that a message is printed to the console before the simulations start.
progress/CPMskin-tracks : data/mkfiles/CPMskin.make ../scripts/simulation/skin-track.js \
	settings/paramsskin.txt settings/conf-skin.js | progress data/tracks
	@rm -f data/tracks/CPMskin-* && \
	$(MAKE) -f $< message && \
	$(MAKE) -f $< &&\
	touch $@


# STEP 2: Analyze the tracks; output will be in data/CPMskin-speedpersistence-all.txt.
#
# Automatically generate a Makefile with a recipe to analyze all tracks per parameter
# combination. These can then be analyzed in parallel to save time. 
# This also generates folders data/analysis-CPMskin/tmp (for intermediate analysis files),
# and data/analysis-CPMskin/acorplots (which is currently not used, but the analysis
# script has an option to save autocovariance plots when computing persistence.)
data/mkfiles/analyze-CPMskin.make : ../scripts/analysis/analysis-tissue-makeout.sh \
	progress/CPMskin-tracks settings/paramsskin.txt | data/mkfiles
	rm -f data/CPMskin-speedpersistence-all.txt && rm -rf data/analysis-CPMskin/tmp && \
		rm -rf data/analysis-CPMskin/acorplots && \
	bash $< data/tracks settings/paramsskin.txt $(NSIM) CPMskin 2 "$(torus_skin)" > $@


# To get the final output, the above makefile is called to generate the analysis files.
# For each parameter combination, the NSIM simulations are grouped in groups of 5 tracks
# each. These tracks are then analyzed together for speed and persistence (grouping
# improves the analysis because the analysis is now performed on a number of independent
# tracks, but it still allows an estimate of uncertainty because we analyze multiple 
# groups).
# Once a separate analysis is performed for each parameter combi under 
# data/analysis-CPM1D/tmp, all files are concatenated and a header is added. 
data/CPMskin-speedpersistence-all.txt : data/mkfiles/analyze-CPMskin.make \
	../scripts/analysis/analyze-speed-persistence-combined.R \
	../scripts/analysis/trackAnalysisFunctions.R
	@$(MAKE) -f $< message && $(MAKE) -f $< 


# STEP 3: Make the speed-persistence plot of all parameter combinations.
plots/F5panelD.pdf : ../scripts/plotting/plot-speed-persistence-tissue-facet.R \
	data/CPMskin-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPMskin-speedpersistence-all.txt $@ $(CLskin) "0.5 -1"



# ============================ FOLDERS/OTHER ====================================
# Automatically generate the directory structure.

data :
	@mkdir -p $@
	
data/tracks :
	@mkdir -p $@
	
data/mkfiles :
	@mkdir -p $@
	
plots : 
	@mkdir -p $@
	
progress :
	@mkdir -p $@
	
latex-clean : 
	rm -f latex/*.pdf
	
clean : latex-clean
	rm -f figure*.pdf && rm -rf data && rm -rf plots && rm -rf progress
