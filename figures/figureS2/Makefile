.SECONDARY:
.DELETE_ON_ERROR:

all : figureS2.pdf

# =============================== SETTINGS =====================================


# number of simulations
NSIM=30
CL2D=22.36


# ================================ FIGURE ======================================

figureS2.pdf : latex/figureS2.pdf
	cp $< $@

latex/figureS2.pdf : latex/figureS2.tex simulation-panels
	cd latex && latexmk -pdf figureS2.tex && cp figureS2.pdf ../ ;\
	latexmk -c && rm -f ../Rplots.pdf


panels=panelA panelB panelC panelD-speed panelE-speed
simulation-panels : $(foreach p, $(panels), plots/SF2$(p).pdf)



# =============================== PANEL A =======================================
# This is the analysis of 2D speed and persistence for other max_act values than
# those in the main figure. They have already been analyzed and the data is in
# ../figure2/data/CPM2D-speedpersistence-all.txt, so get the data from there.
data/CPM2D-speedpersistence-all.txt : | data
	cd ../figure2 && $(MAKE) data/CPM2D-speedpersistence-all.txt &&\
	cp data/CPM2D-speedpersistence-all.txt ../figureS2/data/

# Make the plot:
plots/SF2panelA.pdf : ../scripts/plotting/plot-speed-persistence-MactLact-facet-selection.R \
	data/CPM2D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM2D-speedpersistence-all.txt $@ phalf $(CL2D) "0.7 -0.7" "40 50 60 80" 4


# =============================== PANEL B =======================================
# This is the analysis of 2D instantaneous speeds for other max_act values than
# those in figure 3. They have already been analyzed and the data is in
# ../figure3/data/CPM2D-instantaneous.Rdata, so get the data from there.
data/CPM2D-instantaneous.Rdata : | data
	cd ../figure3 && $(MAKE) data/CPM2D-instantaneous.Rdata &&\
	cp data/CPM2D-instantaneous.Rdata ../figureS2/data/
	
# Make the plot:
plots/SF2panelB.pdf : ../scripts/plotting/plot-instantaneous-speed-MactLact-facet-selection.R \
	data/CPM2D-instantaneous.Rdata | plots
	Rscript $^ $@ "40 50 60 80" 4
	
# =============================== PANEL C =======================================
# This is the analysis of 2D speed/persistence versus lambda_act, for other max_act 
# values than those in figure 4. This uses the same analysis file as panel A.
plots/SF2panelC.pdf : ../scripts/plotting/plot-vs-lact-facet-selection.R \
	data/CPM2D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM2D-speedpersistence-all.txt $@ mact $(CL2D) "40 50 60 80" 4 $@

# =============================== PANEL D =======================================
# One more analysis on the data in CPM2D-speedpersistence-all.txt
# this generates both the speed and persistence plots
plots/SF2panelD-speed.pdf : ../scripts/plotting/plot-saturation-vs-mact.R \
	data/CPM2D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM2D-speedpersistence-all.txt plots/SF2panelD
	
# =============================== PANEL E =======================================
# And now on CPM3D-speedpersistence-all.txt; get it from figure 2.
data/CPM3D-speedpersistence-all.txt : | data
	cd ../figure2 && $(MAKE) data/CPM3D-speedpersistence-all.txt &&\
	cp data/CPM3D-speedpersistence-all.txt ../figureS2/data/


# this generates both the speed and persistence plots
plots/SF2panelE-speed.pdf : ../scripts/plotting/plot-saturation-vs-mact.R \
	data/CPM3D-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPM3D-speedpersistence-all.txt plots/SF2panelE



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
