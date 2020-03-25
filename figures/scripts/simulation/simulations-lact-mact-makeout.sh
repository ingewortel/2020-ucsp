#!/bin/bash

# This script loops over values of LACT and MACT and creates a makefile to run 
# simulations and output tracks.
#
# INPUT:
# 1) scriptDir			path to directory where scripts are located
# 2) settingsFile		path to the file where the config object is defined.
# 3) paramFile 			containing parameter combinations for lact and mact
# 4) nsim				number of simulations per parameter combination
# 5) expName			identifier of the type of simulation (eg CPM1D), will be
#						used to name the files where tracks are saved.
# 6) pathToHere 		path to the current folder from the location of the node
#						script simple-track.js (figures/scripts/simulation/)
# 
# 
# OUTPUT: Makefile that generates tracks data/tracks/[expname]-lact[LACT]-mact[MACT]-sim[SIM].txt.

# Arguments
scriptDir=$1
settingsFile=$2
paramFile=$3
nsim=$4
expName=$5
pathToHere=$6


# ---------------------------------------------------------------------
# CODE:
# ---------------------------------------------------------------------

# Count the number of parameter combinations in the parameter file, and compute the
# number of tracks to generate by multiplying that with the number of simulations per
# parameter combination. 
np=$( cat $paramFile | wc -l )
tracknum=$( echo "$np *$nsim" | bc )


# Print the header of the Makefile to generate:
echo ".DELETE_ON_ERROR :"
echo "all : all-tracks"
echo ""


# Store all tracks to generate in this variable, which gets filled in the following loop.
allTracks=""

# Loop over the simulations and parameter combis
for p in $(seq 1 $np) ; do

	MACT=$( cat $paramFile | awk -v line=$p 'NR==line{print $1}')
	LACT=$( cat $paramFile | awk -v line=$p 'NR==line{print $2}')
		
		NAME=$expName-lact$LACT-mact$MACT

		# Now the recipes for the individual simulation tracks
		for sim in $(seq 1 $nsim) ; do

			# Ensure the loop can be easily stopped
			trap "exit 1" SIGINT SIGTERM

			# Name of the track file to generate
			TRACK=data/tracks/$NAME-sim$sim.txt
			
			# Write the target, dependencies, and recipe for this particular track
			# to the Makefile.
			echo "$TRACK : $scriptDir/simple-track.js $settingsFile | data/tracks"
			echo -e "\t@"node \$\< $pathToHere/$settingsFile $MACT $LACT "none" $sim "> \$@"
			echo ""

			# Add this track to the list of all tracks to generate
			allTracks="$allTracks $TRACK"
		
		done

done

echo ""
# Ensure that all the listed tracks are actually generated; 'all-tracks' target is 
# required by 'all'.
echo "all-tracks : $allTracks"
echo ""

# A message to print when simulations are being generated.
echo "message : "
echo -e "\t@"echo "Generating $tracknum tracks in $pathToHere/data/tracks," \
	"using $np parameter combinations in $paramFile, $nsim simulations." \
	"Recipe: node $scriptDir/simple-track.js $pathToHere/$settingsFile [MAXACT] [LAMBDAACT] 'none' [SIMNUMBER]" 








