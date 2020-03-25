.SECONDARY:
.DELETE_ON_ERROR:

all : figure2.pdf

# =============================== SETTINGS =====================================
# path to here from ../scripts/simulation/ where scripts are
pathToHere=../../figure2

# number of simulations
NSIM=20
NSIM_3D=1



# ================================ FIGURE ======================================

figure2.pdf : latex/figure2.pdf
	cp $< $@

latex/figure2.pdf : latex/figure2.tex simulation-panels
	cd latex && latexmk -pdf figure2.tex && cp figure2.pdf ../ ;\
	latexmk -c


panels=panelB-1D panelB-2D panelB-3D panelC
simulation-panels : $(foreach p, $(panels), plots/F2$(p).pdf)



# ============================= PANEL B 3D ======================================
# The 3D plot for panel B

# STEP 1: Simulate tracks.
# 
# Automatically generate a Makefile with a recipe for each of the tracks to generate.
# This ensures that these can then be generated in parallel. 
data/mkfiles/CPM3D.make : ../scripts/simulation/simulations-lact-mact-makeout.sh \
	settings/params3D.txt settings/conf-3D.js | data/mkfiles
	bash $< ../scripts/simulation settings/conf-3D.js settings/params3D.txt $(NSIM_3D) CPM3D $(pathToHere) > $@

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
