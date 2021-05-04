.SECONDARY:
.DELETE_ON_ERROR:

all : figureS4.pdf

# =============================== SETTINGS =====================================
# Get make variables from a general configuration file.

include ../settings.env

# ================================ FIGURE ======================================

figureS4.pdf : latex/figureS4.pdf
	cp $< $@

latex/figureS4.pdf : latex/figureS4.tex simulation-panels
	cd latex && latexmk -pdf figureS4.tex && cp figureS4.pdf ../ ;\
	latexmk -c && rm -f ../Rplots.pdf


panels=panel
simulation-panels : $(foreach p, $(panels), plots/SF4$(p).pdf)



# =============================== PANEL  ======================================
# Speed distribution analyzed in the skin tracks.
#
# Link the skin tracks and settings here from figure 5
progress/CPMskin-tracks : | data progress
	cd ../figure5 && $(MAKE) progress/CPMskin-tracks && \
	cd ../figureS4/data && ln -s ../../figure5/data/tracks && \
	touch ../progress/CPMskin-tracks

settings/paramsskin.txt : | settings
	cd settings && ln -s  ../../figure5/settings/paramsskin.txt


# Compute the instantaneous speeds etc.
data/CPMskin-instantaneous.Rdata : ../scripts/analysis/analyze-instantaneous.R \
	progress/CPMskin-tracks settings/paramsskin.txt ../scripts/analysis/trackAnalysisFunctions.R
	Rscript $< CPMskin $(NSIM) settings/paramsskin.txt "mact lact tissue" "2 1 3" 2 "150 150" $@


# Make the plot:
plots/SF4panel.pdf : ../scripts/plotting/plot-instantaneous-speed-tissue-facet.R \
	data/CPMskin-instantaneous.Rdata | plots
	Rscript $^ $@



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
	rm -f figure*.pdf && rm -rf data && rm -rf plots && rm -rf progress
