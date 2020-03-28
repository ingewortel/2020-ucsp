.SECONDARY:
.DELETE_ON_ERROR:

all : figureS5.pdf

# =============================== SETTINGS =====================================

NSIM=20
CLskin=45

# ================================ FIGURE ======================================

figureS5.pdf : latex/figureS5.pdf
	cp $< $@

latex/figureS5.pdf : latex/figureS5.tex simulation-panels
	cd latex && latexmk -pdf figureS5.tex && cp figureS5.pdf ../ ;\
	latexmk -c && rm -f ../Rplots.pdf


panels=panel-speed
simulation-panels : $(foreach p, $(panels), plots/SF5$(p).pdf)



# =============================== PANEL  ======================================
# This is the analysis of skin speed and persistence saturation, comparable to the
# 2D/3D analysis in figure 4. Data have already been analyzed in
# ../figure5/data/CPMskin-speedpersistence-all.txt, so get the data from there.
data/CPMskin-speedpersistence-all.txt : | data
	cd ../figure5 && $(MAKE) data/CPMskin-speedpersistence-all.txt &&\
	cp data/CPMskin-speedpersistence-all.txt ../figureS5/data/


# this script generates both plots at once (also plots/SF3panel-persistence.pdf)
plots/SF5panel-speed.pdf : ../scripts/plotting/plot-vs-lact2.R \
	data/CPMskin-speedpersistence-all.txt ../scripts/plotting/mytheme.R | plots
	Rscript $< data/CPMskin-speedpersistence-all.txt plots/SF5panel $(CLskin)



# ============================ FOLDERS/OTHER ====================================
# Automatically generate the directory structure.

data :
	@mkdir -p $@
	

plots : 
	@mkdir -p $@
	
	
progress :
	@mkdir -p $@

settings :
	@mkdir -p $@
	
latex-clean : 
	rm -f latex/*.pdf
	
clean : latex-clean
	rm -f figure*.pdf && rm -rf data && rm -rf plots
