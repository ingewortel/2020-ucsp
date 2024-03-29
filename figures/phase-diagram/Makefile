.SECONDARY:
.DELETE_ON_ERROR:

# =============================== SETTINGS =====================================
# path to here from ../scripts/simulation/ where scripts are
pathToHere=../../phase-diagram

# Get other make variables from a general configuration file.
include ../settings.env
NSIM=30
RUNTIME=25000
N=30

all : plots/phase-diagram.pdf plots/dx-insets.pdf

# ============================= PHASE DIAGRAM ======================================
# The 1D plot for panel B.


# step 0: parms maxact from 10-100, lact from 10-1500 range.
settings/params1D.txt : ../scripts/simulation/make-parms.R
	Rscript $< "0 100" "0 1500" $(N) $@
	

# STEP 1: Simulate tracks. The raw tracks will be saved under:
#	data/tracks/CPM1D-lact[value]-mact[value]-sim[value].txt
# 
# Automatically generate a Makefile with a recipe for each of the tracks to generate.
# This ensures that these can then be generated in parallel. 
data/mkfiles/CPM1D.make : ../scripts/simulation/simulations-lact-mact-makeout.sh \
	settings/params1D.txt settings/conf-1D.js | data/mkfiles
	bash $< ../scripts/simulation settings/conf-1D.js settings/params1D.txt \
		$(NSIM) CPM1D $(pathToHere) $(RUNTIME) > $@

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
	
# STEP 2: Analyze tracks. 
# Analysis per parameter combination in settings/params1D.txt. Loop over numbers 
# 1:nrow(paramfile)	do do each step for the appropriate parameters.

# Make a folder
data/analysis/p%data :
	@mkdir -p $@

# Collect the tracks of individual simulations into a tracks object, and check how many
# cells broke during the simulation.
data/analysis/p%data/tracks.rds : ../scripts/analysis/collect-tracks-params.R \
	settings/params1D.txt | data/analysis/p%data
	Rscript $< settings/params1D.txt $* CPM1D $(NSIM) $@	data/analysis/p$*data/broken.rds

# Extract dx displacements
data/analysis/p%data/dx.rds : ../scripts/analysis/get-dx-params.R data/analysis/p%data/tracks.rds 
	Rscript $^ $@ data/analysis/p$*data/dx.pdf
	
# Fit the mixture model to compute number of components and BICs
data/analysis/p%data/model.txt : ../scripts/analysis/fit-mixture-model-params.R data/analysis/p%data/dx.rds
	Rscript $^ data/analysis/p$*data/broken.rds $@

# Ensure that these steps are performed for all parameter combinations.
data/filelist.txt : ../scripts/analysis/list-analysis-output.R settings/params1D.txt | data
	Rscript $^ $@
	
FILES=$$(cat data/filelist.txt)

progress/analyses : progress/CPM1D-tracks data/filelist.txt
		$(MAKE) $(FILES) && touch $@

# Merge all into a single file:
data/analysis/phases.txt : progress/analyses
	echo "n dBIC13 dBIC12 dBIC23 broken dmuRel mp mact lact" > $@ &&\
	cat $(FILES) >> $@
	
# STEP 3: plotting
plots/phase-diagram.pdf : ../scripts/plotting/plot-phase-diagram.R data/analysis/phases.txt \
	settings/highlights.txt | plots
	Rscript $< data/analysis/phases.txt $@ $(N) $(NSIM) settings/highlights.txt
	
plots/dx-insets.pdf : ../scripts/plotting/plot-dx-insets.R settings/params1D.txt \
	settings/highlights.txt progress/analyses | plots 
	Rscript $< settings/params1D.txt settings/highlights.txt $@




# ============================ FOLDERS/OTHER ====================================
# Automatically generate the directory structure.

data :
	@mkdir -p $@
	
data/tracks :
	@mkdir -p $@
	
data/mkfiles :
	@mkdir -p $@
	
data/analysis :
	@mkdir -p $@
	
plots : 
	@mkdir -p $@
	
progress :
	@mkdir -p $@
	
latex-clean : 
	rm -f latex/*.pdf
	
clean : latex-clean
	rm -f figure*.pdf && rm -rf data && rm -rf plots && rm -rf progress
