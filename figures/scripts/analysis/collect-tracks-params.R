library( celltrackR )
source( "../scripts/analysis/trackAnalysisFunctions.R" )

argv <- commandArgs( trailingOnly = TRUE )


parmfile <- argv[1]
num <- as.numeric( argv[2] )
expname <- argv[3]
nsim <- as.numeric( argv[4] )
outtracks <- argv[5]
outbroken <- argv[6]

# Get the filename of a given track
trackFileName <- function( mact, lact, sim ){
	tname <- paste0( "data/tracks/CPM1D-lact", lact, "-mact", mact, "-sim", sim, ".txt" )
	return(tname)
}

# Function to read all tracks at a given param combo
readAllTracks <- function( mact, lact, nsim ){

	simnums <- seq(1,nsim)
	t <- lapply( simnums, function(x){
		return( readTracks( trackFileName( mact, lact, x ), 2, c(150,150) )[[1]] )
	})
	names(t) <- seq(1,length(t))
	return( as.tracks(t) )
}




parms <- read.table( parmfile, stringsAsFactors = FALSE )
parms <- parms[ num, ]

parms$ID <- paste0( parms$V1, "-", parms$V2 )


all.tracks <- lapply( 1:nrow(parms), function(x){
	readAllTracks( parms$V1[x], parms$V2[x], nsim )
})
names( all.tracks ) <- parms$ID 




readAllBroken <- function( mact, lact, nsim ){

	simnums <- seq(1,nsim)
	conn <- lapply( simnums, function(x){
		return( read.table( trackFileName( mact, lact, x ) )[,6] )
	})
	broken <- sapply( conn, function(x){
		( sum( x < 0.95 )/length(x) ) > 0.05
		#any( x < 0.8 )
		#min( x )
	})
	return( broken )

}

broken <- lapply( 1:nrow(parms),function(x){ readAllBroken( parms$V1[x], parms$V2[x], nsim ) })
saveRDS( broken, outbroken )


all.tracks2 <- lapply( 1:length(all.tracks), function(x){
	t <- all.tracks[[x]]
	b <- !broken[[x]]
	t <- t[b]
	return(t)
})
names( all.tracks2 ) <- parms$ID 


saveRDS( all.tracks2, outtracks )



readAllBroken <- function( mact, lact, nsim ){

	simnums <- seq(1,nsim)
	conn <- lapply( simnums, function(x){
		return( read.table( trackFileName( mact, lact, x ) )[,6] )
	})
	broken <- sapply( conn, function(x){
		any( x < 0.9 )
	})
	return( broken )

}

broken <- lapply( 1:nrow(parms),function(x){ readAllBroken( parms$V1[x], parms$V2[x], nsim ) })
saveRDS( broken, outbroken )
