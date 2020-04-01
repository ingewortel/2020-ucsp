.SECONDARY:
.DELETE_ON_ERROR:

all : figure2.pdf

# =============================== SETTINGS =====================================
# path to here from ../scripts/simulation/ where scripts are
pathToHere=../../figure2

# Get other make variables from a general configuration file.
include ../settings.env

# ================================ FIGURE ======================================

figure2.pdf : latex/figure2.pdf
	cp $< $@

latex/figure2.pdf : latex/figure2.tex simulation-panels cartoon-panels
	cd latex && latexmk -pdf figure2.tex && cp figure2.pdf ../ ;\
	latexmk -c


panels=panelB-1D panelB-2D panelB-3D panelC
simulation-panels : $(foreach p, $(panels), plots/F2$(p).pdf)

# ================================ PANEL A ======================================
# Panel A is a schematic overview of the simulation setup, no simulations need to
# be performed to produce it.
cartoon-panels : cartoons/all-setup.pdf cartoons/gradient.pdf


# ============================= PANEL B 1D ======================================
# The 1D plot for panel B.

# STEP 1: Simulate tracks. The raw tracks will be saved under:
#	data/tracks/CPM1D-lact[value]-mact[value]-sim[value].txt
# 
# Automatically generate a Makefile with a recipe for each of the tracks to generate.
# This ensures that these can then be generated in parallel. 
data/mkfiles/CPM1D.make : ../scripts/simulation/simulations-lact-mact-makeout.sh \
	settings/params1D.txt settings/conf-1D.js | data/mkfiles
	bash $< ../scripts/simulation settings/conf-1D.js settings/params1D.txt \
		$(NSIM) CPM1D $(pathToHere) > $@

# To actually generate the tracks, call "make" on the Makefile generated in the 
# previous step. The required scripts are in the dependencies to ensure that tracks
# are updated whenever the underlying scripts change.
# Also ensure that the 'progress' and 'data/tracks' folders exist before the simulations
# are started. The recipe itself ensures that any old tracks are first removed, and
# that a message is printed to the console before the simulations start.
progress/CPM1D-tracks : data/mkfiles/CPM1D.make ../scripts/simulation/simple-track.js \
	settings/params1D.txt settings/conf-1D.js | progress data/tracks
	@rm -f data/tracks/CPM1D-* && \
	$(MAKE) -f $< message && \
	$(MAKE) -f $< &&\
	touch $@


# STEP 2: Analyze the tracks; output will be in data/CPM1D-speedpersistence-all.txt.
#
# Automatically generate a Makefile with a recipe to analyze all tracks per parameter
# combination. These can then be analyzed in parallel to save time. 
# This also generates folders data/analysis-CPM1D/tmp (for intermediate analysis files),
# and data/analysis-CPM1D/acorplots (which is currently not used, but the analysis
# script has an option to save autocovariance plots when computing persistence.)
data/mkfiles/analyze-CPM1D.make : ../scripts/analysis/analysis-lact-mact-makeout.sh \
	progress/CPM1D-tracks settings/params1D.txt | data/mkfiles
	rm -f data/CPM1D-speedpersistence-all.txt && rm -rf data/analysis-CPM1D/tmp && \
		rm -rf data/analysis-CPM1D/acorplots && \
	bash $< data/tracks settings/params1D.txt $(NSIM) CPM1D 1 "$(torus_1D)" > $@

# To get the final output, the above makefile is called to generate the analysis files.
# For each parameter combination, the NSIM simulations are grouped in groups of 5 tracks
# each. These tracks are then analyzed together for speed and persistence (grouping
# improves the analysis because the analysis is now performed on a number of independent
# tracks, but it still allows an estimate of uncertainty because we analyze multiple 
# groups).
# Once a separate analysis is performed for each parameter combi under 
# data/analysis-CPM1D/tmp, all files are concatenated and a header is added. 
data/CPM1D-speedpersistence-all.txt : data/mkfiles/analyze-CPM1D.make \
	../scripts/analysis/analyze-speed-persistence-combined.R \
	../scripts/analysis/trackAnalysisFunctions.R
	@$(MAKE) -f $< message && $(MAKE) -f $<


# STEP 3: Make the speed-persistence plot of all parameter combinations.
plots/F2panelB-1D.pdf : ../scripts/plotting/plot-speed-persistence-MactLact.R \
	data/CPM1D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM1D-speedpersistence-all.txt $@ phalf



# ============================= PANEL B 2D ======================================
# The 2D plot for panel B.

# STEP 1: Simulate tracks. The raw tracks will be saved under:
#	data/tracks/CPM2D-lact[value]-mact[value]-sim[value].txt
# 
# Automatically generate a Makefile with a recipe for each of the tracks to generate.
# This ensures that these can then be generated in parallel. 
data/mkfiles/CPM2D.make : ../scripts/simulation/simulations-lact-mact-makeout.sh \
	settings/params2D.txt settings/conf-2D.js | data/mkfiles
	bash $< ../scripts/simulation settings/conf-2D.js settings/params2D.txt \
		$(NSIM) CPM2D $(pathToHere) > $@

# To actually generate the tracks, call "make" on the Makefile generated in the 
# previous step. The required scripts are in the dependencies to ensure that tracks
# are updated whenever the underlying scripts change.
# Also ensure that the 'progress' and 'data/tracks' folders exist before the simulations
# are started. The recipe itself ensures that any old tracks are first removed, and
# that a message is printed to the console before the simulations start.
progress/CPM2D-tracks : data/mkfiles/CPM2D.make ../scripts/simulation/simple-track.js \
	settings/params2D.txt settings/conf-2D.js | progress data/tracks
	@rm -f data/tracks/CPM2D-* && \
	$(MAKE) -f $< message && \
	$(MAKE) -f $< &&\
	touch $@


# STEP 2: Analyze the tracks; output will be in data/CPM2D-speedpersistence-all.txt.
#
# Automatically generate a Makefile with a recipe to analyze all tracks per parameter
# combination. These can then be analyzed in parallel to save time. 
# This also generates folders data/analysis-CPM2D/tmp (for intermediate analysis files),
# and data/analysis-CPM2D/acorplots (which is currently not used, but the analysis
# script has an option to save autocovariance plots when computing persistence.)
data/mkfiles/analyze-CPM2D.make : ../scripts/analysis/analysis-lact-mact-makeout.sh \
	progress/CPM2D-tracks settings/params2D.txt | data/mkfiles
	rm -f data/CPM2D-speedpersistence-all.txt && rm -rf data/analysis-CPM2D/tmp && \
		rm -rf data/analysis-CPM2D/acorplots && \
	bash $< data/tracks settings/params2D.txt $(NSIM) CPM2D 2 "$(torus_2D)" > $@

# To get the final output, the above makefile is called to generate the analysis files.
# For each parameter combination, the NSIM simulations are grouped in groups of 5 tracks
# each. These tracks are then analyzed together for speed and persistence (grouping
# improves the analysis because the analysis is now performed on a number of independent
# tracks, but it still allows an estimate of uncertainty because we analyze multiple 
# groups). Once a separate analysis is performed for each parameter combi under 
# data/analysis-CPM2D/tmp, all files are concatenated and a header is added. 
data/CPM2D-speedpersistence-all.txt : data/mkfiles/analyze-CPM2D.make \
	../scripts/analysis/analyze-speed-persistence-combined.R \
	../scripts/analysis/trackAnalysisFunctions.R
	@$(MAKE) -f $< message && $(MAKE) -f $<


# STEP 3: Make the speed-persistence plot of all parameter combinations.
plots/F2panelB-2D.pdf : ../scripts/plotting/plot-speed-persistence-MactLact.R \
	data/CPM2D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM2D-speedpersistence-all.txt $@ phalf



# ============================= PANEL B 3D ======================================
# The 3D plot for panel B.

# STEP 1: Simulate tracks. The raw tracks will be saved under:
#	data/tracks/CPM3D-lact[value]-mact[value]-sim[value].txt
# 
# Automatically generate a Makefile with a recipe for each of the tracks to generate.
# This ensures that these can then be generated in parallel. 
data/mkfiles/CPM3D.make : ../scripts/simulation/simulations-lact-mact-makeout.sh \
	settings/params3D.txt settings/conf-3D.js | data/mkfiles
	bash $< ../scripts/simulation settings/conf-3D.js settings/params3D.txt \
		$(NSIM) CPM3D $(pathToHere) > $@

# To actually generate the tracks, call "make" on the Makefile generated in the 
# previous step. The required scripts are in the dependencies to ensure that tracks
# are updated whenever the underlying scripts change.
# Also ensure that the 'progress' and 'data/tracks' folders exist before the simulations
# are started. The recipe itself ensures that any old tracks are first removed, and
# that a message is printed to the console before the simulations start.
progress/CPM3D-tracks : data/mkfiles/CPM3D.make ../scripts/simulation/simple-track.js \
	settings/params3D.txt settings/conf-3D.js | progress data/tracks
	@rm -f data/tracks/CPM3D-* && \
	$(MAKE) -f $< message && \
	$(MAKE) -f $< &&\
	touch $@


# STEP 2: Analyze the tracks; output will be in data/CPM3D-speedpersistence-all.txt.
#
# Automatically generate a Makefile with a recipe to analyze all tracks per parameter
# combination. These can then be analyzed in parallel to save time. 
# This also generates folders data/analysis-CPM3D/tmp (for intermediate analysis files),
# and data/analysis-CPM3D/acorplots (which is currently not used, but the analysis
# script has an option to save autocovariance plots when computing persistence.)
data/mkfiles/analyze-CPM3D.make : ../scripts/analysis/analysis-lact-mact-makeout.sh \
	progress/CPM3D-tracks settings/params3D.txt | data/mkfiles
	rm -f data/CPM3D-speedpersistence-all.txt && rm -rf data/analysis-CPM3D/tmp && \
		rm -rf data/analysis-CPM3D/acorplots && \
	bash $< data/tracks settings/params3D.txt $(NSIM) CPM3D 3 "$(torus_3D)" > $@

# To get the final output, the above makefile is called to generate the analysis files.
# For each parameter combination, the NSIM simulations are grouped in groups of 5 tracks
# each. These tracks are then analyzed together for speed and persistence (grouping
# improves the analysis because the analysis is now performed on a number of independent
# tracks, but it still allows an estimate of uncertainty because we analyze multiple 
# groups).
# Once a separate analysis is performed for each parameter combi under 
# data/analysis-CPM3D/tmp, all files are concatenated and a header is added. 
data/CPM3D-speedpersistence-all.txt : data/mkfiles/analyze-CPM3D.make \
	../scripts/analysis/analyze-speed-persistence-combined.R \
	../scripts/analysis/trackAnalysisFunctions.R
	@$(MAKE) -f $< message && $(MAKE) -f $<


# STEP 3: Make the speed-persistence plot of all parameter combinations.
plots/F2panelB-3D.pdf : ../scripts/plotting/plot-speed-persistence-MactLact.R \
	data/CPM3D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM3D-speedpersistence-all.txt $@ phalf

# ================================ PANEL C ======================================
# speed-persistence analysis for the microchannels, stratified by max_act value.
# this plot is based on the same data/CPM1D-speedpersistence-all.txt data as the
# summary plot in panel B.

plots/F2panelC.pdf : ../scripts/plotting/plot-speed-persistence-MactLact-facet-selection.R \
	data/CPM1D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM1D-speedpersistence-all.txt $@ phalf $(CL1D) "0.2 1.7" "30 100" 2


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
