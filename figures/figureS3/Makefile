.SECONDARY:
.DELETE_ON_ERROR:

all : figureS3.pdf

# =============================== SETTINGS =====================================
# Expected cell-length of a cell.
# This is used to compare the persistence time to the time it takes a cell to move
# one cell length at the current speed.
# 1D/2D cells are modelled as rectangles/squares respectively, with an area=500pix.
CL1D=50

# ================================ FIGURE ======================================

figureS3.pdf : latex/figureS3.pdf
	cp $< $@

latex/figureS3.pdf : latex/figureS3.tex simulation-panels
	cd latex && latexmk -pdf figureS3.tex && cp figureS3.pdf ../ ;\
	latexmk -c && rm -f ../Rplots.pdf


panels=panel-speed
simulation-panels : $(foreach p, $(panels), plots/SF3$(p).pdf)



# =============================== PANEL A/B ======================================
# This is the analysis of 1D speed and persistence saturation, comparable to the
# 2D/3D analysis in figure 4. Data have already been analyzed in
# ../figure2/data/CPM1D-speedpersistence-all.txt, so get the data from there.
data/CPM1D-speedpersistence-all.txt : | data
	cd ../figure2 && $(MAKE) data/CPM1D-speedpersistence-all.txt &&\
	cp data/CPM1D-speedpersistence-all.txt ../figureS3/data/


# this script generates both plots at once (also plots/SF3panel-persistence.pdf)
plots/SF3panel-speed.pdf : ../scripts/plotting/plot-vs-lact-facet.R \
	data/CPM1D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM1D-speedpersistence-all.txt plots/SF3panel mact $(CL1D)




# ============================ FOLDERS/OTHER ====================================
# Automatically generate the directory structure.

data :
	@mkdir -p $@
	

plots : 
	@mkdir -p $@

	
latex-clean : 
	rm -f latex/*.pdf
	
clean : latex-clean
	rm -f figure*.pdf && rm -rf data && rm -rf plots
