# INPUT ARGUMENTS:
#	1	expname			identifier for the experiment, which assumes that tracks are 
#						saved under 'data/tracks/[expname]-[paraminfo]-sim[simnumber].txt'
#							e.g. 'CPM1D', 'CPM2D', 'CPM3D', 'CPMskin'.
#	2	paramfile		the file with parameter combinations used in the simulations, 
#							e.g. settings/params1D.txt.
#	3	feature			the QC feature to plot. Choose from:
#							- conn : 	check mean and SD of connectedness, where
#										connectedness is the number between 0 and 1.
#							- pconn :	check the percentage of measurements where 
#										connectedness was below 0.95 during the simulation.
#										No SD for this metric.
#							- mconn :	check the 5% quantile of connectedness, so the
#										number above which 95% of the measured 
#										connectedness values lie.
#							- pact :	check the mean and SD percentage of active pixels
#										during the simulation.
#	4	dim				number of dimensions of the simulation; must be one of:
#							- 1D
#							- 2D
#							- 3D
#	5	outplot			the name of the file where the plot should be saved.
argv <- commandArgs( trailingOnly = TRUE )
expname <- argv[1]		# identifier for the experiment, ie 'CPM1D','CPM2D','CPM3D', or 'CPMskin'
paramfile <- argv[2]	# file with the parameter combinations used
feature <- argv[3]		# the QC feature to plot, i.e. 'conn', 'pconn', 'mconn', or 'pact'.
dim <- argv[4]		
outplot <- argv[5]


# PACKAGES LOADED:
source("../scripts/plotting/mytheme.R")
library( dplyr, warn.conflicts = FALSE )
library( ggplot2, warn.conflicts = FALSE )
library( data.table, warn.conflicts = FALSE )


# HANDLE INPUT:
# Determine the column where the [feature] is in the data.
# First determine the column where the features start, which depends on the dimensionality
# of the simulation (since 3D sims have an extra coordinate)
if( dim == "1D" || dim == "2D" ){
	firstFeatureCol <- 6
} else if ( dim == "3D" ) {
	firstFeatureCol <- 7
} else {
	stop( "Unknown dimension! Please select '1D', '2D', or '3D'. " )
}

# Then determine the relevant column for the feature of interest. Connectedness is stored
# in the first feature column, percentage active pixels in the second.
# Also determine the yLimit value depending on the feature to plot, and the yLabel for the
# axis.
if( feature == "conn" ){
	featureCol <- firstFeatureCol
	yLabel <- "Connectedness"
	yLimit <- 1	# connectedness is a number between 0 and 1 so plot on this scale.
} else if( feature == "pact" ){
	featureCol <- firstFeatureCol + 1
	yLabel <- "% Active pixels"
	yLimit <- 100 # plot on a percentage scale
} else if( feature == "pconn" ){
	featureCol <- firstFeatureCol
	yLabel <- "% connectedness < 95"
	yLimit <- NA # no fixed ylimit, plot range depending on outcome
} else if ( feature == "mconn" ){
	featureCol <- firstFeatureCol
	yLabel <- "5% quantile connectedness"
	yLimit <- 1	# connectedness is a number between 0 and 1 so plot on this scale.
}  else {
	stop("Unknown feature. Please select 'conn', 'pconn', 'mconn', or 'pact'.")
}

# Now read the parameter combinations to make the QC plots for. They are stored in 
# paramfile, which can either have 2 columns (max_act and lambda_act), or 3 columns
# (for skin simulatons: max_act, lambda_act, and tissue_type).
params <- read.table( paramfile )
if( ncol(params) == 2 ){
	colnames( params ) <- c("mact", "lact" )
	params <- params[,c("lact","mact")]
} else {
	colnames( params ) <- c("mact", "lact", "tissue")
	params <- params[,c("lact","mact","tissue")]
}


# READ TRACKS AND COMPUTE STATISTICS
# For each parameter simulation, we perform the QC on the first simulation.
# Since simulations are very long, 50 000 MCS, this should be sufficient to get an
# accurate estimate of the metrics of interest.
data <- data.frame()
for( i in 1:nrow(params) ){

	# Get the parameter combination per row of the params table
	currentParams <- params[i,]
	fileID <- paste0( colnames(params), params[i,], collapse = "-" )

	# Get the name of the file with tracks from the first simulation 
	# for this parameter combination. Read this file.
	trackname <- paste0( "data/tracks/",expname,"-",fileID,"-sim1.txt" )
	d <- fread( trackname, data.table = FALSE )
	
	# Compute relevant features: fmu for the estimate, and fsd for the SD in cases
	# where this is relevant.
	# Just compute mean and SD for 'conn' and 'pact':
	fmu <- mean( d[,featureCol] )
	fsd <- sd( d[,featureCol] )
	
	# For 'pconn' and 'mconn', we compute percentages and quantiles and have no
	# measure of spread.
	if( feature == "pconn" ){
		fmu <- sum( d[,featureCol] < 0.95 )/nrow(d) 
		fsd <- 0
	} else if( feature == "mconn" ){
		fmu <- quantile( d[,featureCol], 0.05 )
		fsd <- 0
	}
	
	# Add this to the output data.
	dtmp <- cbind( currentParams, data.frame( mu = fmu, sd = fsd ) )
	data <- rbind( data, dtmp )
	
}


# For the percentage connectedness below threshold, the yLimit is not fixed.
# Now set it to 1.1 times the max observed value. 
if( feature == "pconn" ){
	yLimit <- 1.1 * max( data$mu )
}

# Rename the mact value for a prettier label in the plot
data$mact2 <- factor(data$mact, labels = paste0("Max[Act] : ", levels(factor(data$mact)) ) )

# If params does not have a 'tissue' column, add it now to the 'data' with a single value.
if( ncol(params) == 2 ){
	data$tissue <- "none"
}

data$tissue2 <- factor(data$tissue, labels = paste0("Tissue : ", levels(factor(data$tissue)) ) )

# Generate the plot.
p <- ggplot( data, aes( x = lact, 
				y = mu, 
				group=mact ) ) +
	# shaded +/- SD
	geom_ribbon( aes( ymin=mu-sd, ymax=mu+sd ), alpha=0.3, color=NA ) + 
	geom_point() +
	geom_path() +
	labs( x = expression( lambda["Act"] ), y = yLabel ) + 
	geom_text( aes( label = lact ) , size=2, hjust=-0.5,vjust=1) +
	scale_y_continuous( expand=c(0,0)) +
	scale_x_continuous( expand=c(0.2,0) ) +
	coord_cartesian( ylim=c(0, yLimit) )+
	facet_grid( tissue2~mact2, scales="free_x" ) + #, labeller=label_parsed )+
	mytheme + theme(
		legend.position = "right",
		plot.title = element_text(size = 9),
		legend.title = element_text( size = 9 ),
		strip.background =element_rect(fill=NA,color=NA)
	)

plotHeight = length(unique(data$tissue)) * 4 + 1


ggsave( outplot, width = 25, height = plotHeight, units="cm")


