.SECONDARY:
.DELETE_ON_ERROR:

all : figure4.pdf

# =============================== SETTINGS =====================================
# path to here from ../scripts/simulation/ where scripts are
pathToHere=../../figure4

# Get other make variables from a general configuration file.
include ../settings.env


# ================================ FIGURE ======================================

figure4.pdf : latex/figure4.pdf
	cp $< $@

latex/figure4.pdf : latex/figure4.tex simulation-panels
	cd latex && latexmk -pdf figure4.tex && cp figure4.pdf ../ ;\
	latexmk -c && rm -f ../Rplots.pdf


panels=panelA panelB
simulation-panels : $(foreach p, $(panels), plots/F4$(p).pdf)

# ================================ PANEL A ======================================
# Panel A is the 2D plot.
#
# Get data from figure 2
data/CPM2D-speedpersistence-all.txt : | data
	cd data && ln -s ../../figure2/data/CPM2D-speedpersistence-all.txt

# Make the plot
plots/F4panelA.pdf : ../scripts/plotting/plot-vs-lact-facet-selection.R \
	data/CPM2D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM2D-speedpersistence-all.txt $@ mact $(CL2D) "30 100" 2 $@

# ================================ PANEL B ======================================
# Panel B is the 3D plot.
#
# Get data from figure 3
data/CPM3D-speedpersistence-all.txt : | data
	cd data && ln -s ../../figure2/data/CPM3D-speedpersistence-all.txt

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
