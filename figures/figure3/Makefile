.SECONDARY:
.DELETE_ON_ERROR:

all : figure3.pdf

# =============================== SETTINGS =====================================
# path to here from ../scripts/simulation/ where scripts are
pathToHere=../../figure3

# number of simulations
NSIM=20
NSIM_3D=20

torus_3D=150 150 150
torus_2D=150 150
torus_1D=150 NA

# Expected cell-length of a cell.
# This is used to compare the persistence time to the time it takes a cell to move
# one cell length at the current speed.
# 1D/2D cells are modelled as rectangles/squares respectively, with an area=500pix.
CL1D=50
CL2D=22.36
# 3D cells have volume = 1800 pix, yielding a length of 12 (cell modeled as cube,
# length = volume^(1/3).)
CL3D=12



# ================================ FIGURE ======================================

figure3.pdf : latex/figure3.pdf
	cp $< $@

latex/figure3.pdf : latex/figure3.tex simulation-panels
	cd latex && latexmk -pdf figure3.tex && cp figure3.pdf ../ ;\
	latexmk -c


panels=panelB-2D panelC-2D panelB-3D panelC-3D
simulation-panels : $(foreach p, $(panels), plots/F3$(p).pdf)

# ================================ PANEL A ======================================
# Panel A is a schematic overview of the simulation setup, no simulations need to
# be performed to produce it.


# ================================ PANEL B ======================================

# 2D:
#
# Get data from figure 2:
progress/CPM2D-tracks : | data/tracks progress
	cd ../figure2 && $(MAKE) progress/CPM2D-tracks && \
	cp data/tracks/CPM2D* ../figure3/data/tracks/ && touch $@

data/CPM2D-speedpersistence-all.txt : | data
	cd ../figure2 && $(MAKE) data/CPM2D-speedpersistence-all.txt && \
	cp data/CPM2D-speedpersistence-all.txt ../figure3/data/

# Make the plot
plots/F3panelB-2D.pdf : ../scripts/plotting/plot-speed-persistence-MactLact-facet-selection.R \
	data/CPM2D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM2D-speedpersistence-all.txt $@ phalf $(CL2D) "0.5 -0.6" "30 100" 2


# 3D:
#
# Get data from figure 2:
progress/CPM3D-tracks : | data/tracks progress
	cd ../figure2 && $(MAKE) progress/CPM3D-tracks && \
	cp data/tracks/CPM3D* ../figure3/data/tracks/ && touch $@

data/CPM3D-speedpersistence-all.txt : | data
	cd ../figure2 && $(MAKE) data/CPM3D-speedpersistence-all.txt && \
	cp data/CPM3D-speedpersistence-all.txt ../figure3/data/

# Make the plot
plots/F3panelB-3D.pdf : ../scripts/plotting/plot-speed-persistence-MactLact-facet-selection.R \
	data/CPM3D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM3D-speedpersistence-all.txt $@ phalf $(CL3D) "-0.5 1.2" "30 50" 2


# ================================ PANEL C ======================================
# Speed distribution plots.

# 2D:
#
# First compute instantaneous speeds
data/CPM2D-instantaneous.Rdata : ../scripts/analysis/analyze-instantaneous.R \
	progress/CPM2D-tracks ../figure2/settings/params2D.txt \
	../scripts/analysis/trackAnalysisFunctions.R
	Rscript $< CPM2D $(NSIM) ../figure2/settings/params2D.txt "mact lact" "2 1" 2 "$(torus_2D)" $@

# Make the plot
plots/F3panelC-2D.pdf : ../scripts/plotting/plot-instantaneous-speed-MactLact-facet-selection.R \
	data/CPM2D-instantaneous.Rdata
	Rscript $^ $@ "30 100" 1


# 3D:
#
# First compute instantaneous speeds
data/CPM3D-instantaneous.Rdata : ../scripts/analysis/analyze-instantaneous.R \
	progress/CPM3D-tracks ../figure2/settings/params3D.txt \
	../scripts/analysis/trackAnalysisFunctions.R
	Rscript $< CPM3D $(NSIM_3D) ../figure2/settings/params3D.txt "mact lact" "2 1" 3 "$(torus_3D)" $@

# Make the plot
plots/F3panelC-3D.pdf : ../scripts/plotting/plot-instantaneous-speed-MactLact-facet-selection.R \
	data/CPM3D-instantaneous.Rdata
	Rscript $^ $@ "30 50" 1


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
