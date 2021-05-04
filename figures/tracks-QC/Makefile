.SECONDARY:
.DELETE_ON_ERROR:

all : QC.pdf



# ================================ FIGURE =======================================

check-plots : plots/checks1D-pact.pdf plots/checks1D-mconn.pdf plots/checks1D-pconn.pdf \
	plots/checks1D-conn.pdf plots/checks2D-pact.pdf plots/checks2D-mconn.pdf \
	plots/checks2D-pconn.pdf plots/checks2D-conn.pdf plots/checksskin-pact.pdf \
	plots/checksskin-mconn.pdf plots/checksskin-pconn.pdf plots/checksskin-conn.pdf \
	plots/checks3D-pact.pdf plots/checks3D-mconn.pdf plots/checks3D-pconn.pdf \
	plots/checks3D-conn.pdf


QC.pdf : latex/QC.pdf
	cp $< $@
	

latex/QC.pdf : latex/QC.tex check-plots
	cd latex && latexmk -pdf QC.tex && cp QC.pdf ../ ;\
	latexmk -c



# =============================== CHECKS 1D =====================================
# Get the tracks and settings from figure 2
progress/CPM1D-tracks : | progress data/tracks
	cd ../figure2 && $(MAKE) progress/CPM1D-tracks && \
	cp data/tracks/CPM1D-*sim1.txt ../tracks-QC/data/tracks/ && \
	touch $@

settings/params1D.txt : | settings
	cp ../figure2/settings/params1D.txt settings/

# Make the plot with checks.
plots/checks1D-pact.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params1D.txt progress/CPM1D-tracks | plots
	Rscript $< CPM1D settings/params1D.txt pact 1D $@
	
plots/checks1D-mconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params1D.txt progress/CPM1D-tracks | plots
	Rscript $< CPM1D settings/params1D.txt mconn 1D $@
	
plots/checks1D-conn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params1D.txt progress/CPM1D-tracks | plots
	Rscript $< CPM1D settings/params1D.txt conn 1D $@
	
plots/checks1D-pconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params1D.txt progress/CPM1D-tracks | plots
	Rscript $< CPM1D settings/params1D.txt pconn 1D $@
	

# =============================== CHECKS 2D =====================================
# Get the tracks and settings from figure 2
progress/CPM2D-tracks : | progress data/tracks
	cd ../figure2 && $(MAKE) progress/CPM2D-tracks && \
	cp data/tracks/CPM2D-*sim1.txt ../tracks-QC/data/tracks/ && \
	touch $@

settings/params2D.txt : | settings
	cp ../figure2/settings/params2D.txt settings/

# Make the plot with checks.
plots/checks2D-pact.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params2D.txt progress/CPM2D-tracks | plots
	Rscript $< CPM2D settings/params2D.txt pact 2D $@
	
plots/checks2D-mconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params2D.txt progress/CPM2D-tracks | plots
	Rscript $< CPM2D settings/params2D.txt mconn 2D $@
	
plots/checks2D-conn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params2D.txt progress/CPM2D-tracks | plots
	Rscript $< CPM2D settings/params2D.txt conn 2D $@
	
plots/checks2D-pconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params2D.txt progress/CPM2D-tracks | plots
	Rscript $< CPM2D settings/params2D.txt pconn 2D $@


# =============================== CHECKS 3D =====================================

# Get the tracks and settings from figure 2
progress/CPM3D-tracks : | progress data/tracks
	cd ../figure2 && $(MAKE) progress/CPM3D-tracks && \
	cp data/tracks/CPM3D-*sim1.txt ../tracks-QC/data/tracks/ && \
	touch $@

settings/params3D.txt : | settings
	cp ../figure2/settings/params3D.txt settings/

# Make the plot with checks.
plots/checks3D-pact.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params3D.txt progress/CPM3D-tracks | plots
	Rscript $< CPM3D settings/params3D.txt pact 3D $@
	
plots/checks3D-mconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params3D.txt progress/CPM3D-tracks | plots
	Rscript $< CPM3D settings/params3D.txt mconn 3D $@
	
plots/checks3D-conn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params3D.txt progress/CPM3D-tracks | plots
	Rscript $< CPM3D settings/params3D.txt conn 3D $@
	
plots/checks3D-pconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params3D.txt progress/CPM3D-tracks | plots
	Rscript $< CPM3D settings/params3D.txt pconn 3D $@


# ============================== CHECKS skin ====================================
# Get the tracks and settings from figure 5
progress/CPMskin-tracks : | progress data/tracks
	cd ../figure5 && $(MAKE) progress/CPMskin-tracks && \
	cp data/tracks/CPMskin-*sim1.txt ../tracks-QC/data/tracks/ && \
	touch $@

settings/paramsskin.txt : | settings
	cp ../figure5/settings/paramsskin.txt settings/

# Make the plot with checks.
plots/checksskin-pact.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/paramsskin.txt progress/CPMskin-tracks | plots
	Rscript $< CPMskin settings/paramsskin.txt pact 2D $@
	
plots/checksskin-mconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/paramsskin.txt progress/CPMskin-tracks | plots
	Rscript $< CPMskin settings/paramsskin.txt mconn 2D $@
	
plots/checksskin-conn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/paramsskin.txt progress/CPMskin-tracks | plots
	Rscript $< CPMskin settings/paramsskin.txt conn 2D $@
	
plots/checksskin-pconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/paramsskin.txt progress/CPMskin-tracks | plots
	Rscript $< CPMskin settings/paramsskin.txt pconn 2D $@





# ============================ FOLDERS/OTHER ====================================
# Automatically generate the directory structure.

data :
	@mkdir -p $@
	
data/tracks :
	@mkdir -p $@
	
settings :
	@mkdir -p $@

plots : 
	@mkdir -p $@
	
progress :
	@mkdir -p $@
	
latex-clean : 
	rm -f latex/*.pdf
	
clean : latex-clean
	rm -f figure*.pdf && rm -rf data && rm -rf plots && rm -rf progress
