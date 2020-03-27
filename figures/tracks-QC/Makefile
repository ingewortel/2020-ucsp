.SECONDARY:
.DELETE_ON_ERROR:

all : check-plots


# =============================== SETTINGS =====================================


# ================================ FIGURE =======================================

check-plots : plots/checks1D-pact.pdf plots/checks1D-mconn.pdf plots/checks1D-pconn.pdf plots/checks1D-conn.pdf



# =============================== CHECKS 1D =====================================
# Get the tracks and settings from figure 2
progress/CPM1D-tracks : | progress data/tracks
	cd ../figure2 && cp data/tracks/CPM1D-*sim1.txt ../tracks-QC/data/tracks/ && \
	touch $@

settings/params1D.txt : | settings
	cp ../figure2/settings/params1D.txt settings/

plots/checks1D-pact.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params1D.txt progress/CPM1D-tracks | plots
	Rscript $< checks1D settings/params1D.txt pact 1D $@
	
plots/checks1D-mconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params1D.txt progress/CPM1D-tracks | plots
	Rscript $< checks1D settings/params1D.txt mconn 1D $@
	
plots/checks1D-conn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params1D.txt progress/checks1D-tracks | plots
	Rscript $< checks1D settings/params1D.txt conn 1D $@
	
plots/checks1D-pconn.pdf : ../scripts/plotting/plot-cellchecks.R \
	settings/params1D.txt progress/CPM1D-tracks | plots
	Rscript $< checks1D settings/params1D.txt pconn 1D $@
	

# =============================== CHECKS 2D =====================================



# =============================== CHECKS 3D =====================================



# ============================== CHECKS skin ====================================





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
