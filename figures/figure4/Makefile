.SECONDARY:
.DELETE_ON_ERROR:

all : figure4.pdf

# =============================== SETTINGS =====================================
# path to here from ../scripts/simulation/ where scripts are
pathToHere=../../figure4

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

figure4.pdf : latex/figure4.pdf
	cp $< $@

latex/figure4.pdf : latex/figure4.tex simulation-panels
	cd latex && latexmk -pdf figure4.tex && cp figure4.pdf ../ ;\
	latexmk -c


panels=panelA panelB
simulation-panels : $(foreach p, $(panels), plots/F4$(p).pdf)

# ================================ PANEL A ======================================
# Panel A is the 2D plot.
#
# Get data from figure 2
data/CPM2D-speedpersistence-all.txt : | data
	cd ../figure2 && $(MAKE) data/CPM2D-speedpersistence-all.txt && \
	cd ../figure4/data && ln -s ../../figure2/data/CPM2D-speedpersistence-all.txt

# Make the plot
plots/F4panelA.pdf : ../scripts/plotting/plot-vs-lact-facet-selection.R \
	data/CPM2D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM2D-speedpersistence-all.txt $@ mact $(CL2D) "30 100" 2 $@

# ================================ PANEL B ======================================
# Panel B is the 3D plot.
#
# Get data from figure 3
data/CPM3D-speedpersistence-all.txt : | data
	cd ../figure2 && $(MAKE) data/CPM3D-speedpersistence-all.txt && \
	cd ../figure4/data && ln -s ../../figure2/data/CPM3D-speedpersistence-all.txt

# Make the plot
plots/F4panelB.pdf : ../scripts/plotting/plot-vs-lact-facet-selection.R \
	data/CPM3D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM3D-speedpersistence-all.txt $@ mact $(CL3D) "30 50" 2 $@

# ============================ FOLDERS/OTHER ====================================
# Automatically generate the directory structure.

data :
	@mkdir -p $@
	
plots : 
	@mkdir -p $@
	
progress :
	@mkdir -p $@
	
latex-clean : 
	rm -f latex/*.pdf
	
clean : latex-clean
	rm -f figure*.pdf && rm -rf data && rm -rf plots && rm -rf progress
