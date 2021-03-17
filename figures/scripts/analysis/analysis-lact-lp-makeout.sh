#!/bin/bash

# This script loops over values of LACT and LP and creates a makefile to analyze speed
# and persistence in the corresponding tracks.
#
# INPUT:
# 1) trackDir		directory where track files are located
# 2) paramFile 		containing parameter combinations
# 3) nSim			number of simulations per parameter combination
# 4) expName		identifier of the type of simulation (eg CPM1D), used to name tracks.
# 5) nDim			number of dimensions of the simulation: 2, or 3.
# 6) torusFieldsize	space-delimited vector of grid dimensions to correct torus for. If
#					a dimension does no thave a torus, enter NA for that dimension.
# 7) groupSize		the size of the analysis groups used for robust analysis.
# 
# 
# OUTPUT: Makefile that generates analysis files.

# Arguments
trackDir=$1
paramFile=$2
nSim=$3
expName=$4
nDim=$5
torusFieldsize=$6
groupSize=$7


# ---------------------------------------------------------------------
# CODE:
# ---------------------------------------------------------------------

# Count the number of parameter combinations in the parameter file, and compute the
# number of tracks by multiplying that with the number of simulations per
# parameter combination. 
np=$( cat $paramFile | wc -l )
trackNum=$( echo "$np * $nSim" | bc )

# Print the header of the Makefile to generate:
echo ".DELETE_ON_ERROR :"
echo "all : data/$expName-speedpersistence-all.txt"
echo ""

# This variable will be filled with a list of all files to generate in the loop below.
fileList=""

# Loop over the different parameter combinations.
# Create recipe to analyze each; the multiple simulations of each parameter combination
# are analyzed together.
for p in $(seq 1 $np) ; do

	# Get current values of the parameters
	LP=$( cat $paramFile | awk -v line=$p 'NR==line{print $1}')
	LACT=$( cat $paramFile | awk -v line=$p 'NR==line{print $2}')
		
		# Identifier based on current parameter values
		NAME=$expName-lact$LACT-lp$LP

		# Now the recipes for the individual parameter combinations
		# trackfiles & corresponding analysis. Ensure that the folders data/analysis/tmp
		# and data/analysis/acorplots are generated first. 
		TRACK=data/tracks/$NAME-sim
		SIMOUT=data/analysis-$expName/tmp/analysis-$NAME.txt
		echo "$SIMOUT : ../scripts/analysis/analyze-speed-persistence-perim.R ../scripts/analysis/trackAnalysisFunctions.R $TRACK$nSim.txt | data/analysis-$expName/tmp data/analysis-$expName/acorplots"
		echo -e "\t@"Rscript \$\< $TRACK $nDim \"$LACT $LP\" \"lact lp\" $nSim $groupSize \"$torusFieldsize\" $expName " | awk 'NR>1{print \$0}' > \$@"
		fileList=$fileList" "$SIMOUT		


done

# This recipe concatenates all the outputs together, with a header of column names first.
echo "data/$expName-speedpersistence-all.txt : $fileList"
echo -e "\t@"printf "'"'%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n'"'" " lact lp group speed pexp phalf pintmean pintmedian pconn > \$@ && \\"
echo -e "\t"cat $fileList ">> \$@"


# These folders are generated automatically. The intermediate files with the analyses
# of individual parameter combinations are stored in data/analysis/tmp, and autocovariance
# plots are stored in data/analysis/acorplots to check. 
echo "data/analysis-$expName/tmp :"
echo -e "\tmkdir -p \$@"
echo "data/analysis-$expName/acorplots :"
echo -e "\tmkdir -p \$@"

# A message to print when the analysis starts.
echo "message : "
echo -e "\t@"echo "Analyzing $trackNum tracks in data/tracks. $nSim simulations." \
	"Recipe: Rscript ../scripts/analysis/analyze-speed-persistence-perim.R data/tracks/$expName-lact[LACT]-lp[LP] $nDim [LACT] [LP] [NSIM] 5 [torus fieldsize] [expname]" 
