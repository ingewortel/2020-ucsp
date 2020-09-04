let CPM = require( "./artistoo-cjs.js" )


const args = require('minimist')(process.argv.slice(2));

const imgvalue = parseInt( args.i ) // the value of lambda act to output images for
const lact = parseInt( args.l )

let img = false
if( lact == imgvalue ){
	img = true
}


let config = {

	// Grid settings
	field_size : [100,1],
	
	// CPM parameters and configuration
	conf : {
		// Basic CPM parameters
		torus : [true,false],				// Should the grid have linked borders?
		seed : 1,							// Seed for random number generation.
		// Basic CPM parameters
		T : 20,								// CPM temperature

		// Adhesion parameters:
		//J: [[0,0], [0,0]] , // 0 20 20 100
		
		// VolumeConstraint parameters
		LAMBDA_V : [0,50],				// VolumeConstraint importance per cellkind
		V : [0,25],					// Target volume of each cellkind
		
		LAMBDA_ACT : [0,lact],
		MAX_ACT : [0,25],
		ACT_MEAN : "geometric"

	},
	
	// Simulation setup and configuration
	simsettings : {
	
		// Cells on the grid
		NRCELLS : [1],						// Number of cells to seed for all
											// non-background cellkinds.
		// Runtime etc
		BURNIN : 100,
		RUNTIME : 10000,
		RUNTIME_BROWSER : "Inf",
		
		// Visualization
		CANVASCOLOR : "eaecef",
		CELLCOLOR : ["000000"],
		ACTCOLOR : [true],					// Should pixel activity values be displayed?
		SHOWBORDERS : [false],				// Should cellborders be displayed?
		zoom : 4,							// zoom in on canvas with this factor.
		
		// Output images
		SAVEIMG : img,					// Should a png image of the grid be saved
											// during the simulation?
		IMGFRAMERATE : 1,					// If so, do this every <IMGFRAMERATE> MCS.
		SAVEPATH : "output",	// ... And save the image in this folder.
		EXPNAME : "stopgo",					// Used for the filename of output images.
		
		// Output stats etc
		STATSOUT : { browser: false, node: true }, // Should stats be computed?
		LOGRATE : 1								// Output stats every <LOGRATE> MCS.

	}
}

let sim = new CPM.Simulation( config, {
	logStats : logStats
} )

function logStats( ){
	
	// compute volume energy of the cell
	const currentVolume = this.C.cellvolume[1] //getStat( CPM.PixelsByCell )[1].length
	const volConstraint = this.C.getConstraint( "VolumeConstraint" )
	const targetVolume = volConstraint.conf.V[1]
	const lambdaVolume = volConstraint.conf.LAMBDA_V[1]
	const currentHvol = lambdaVolume * ( currentVolume - targetVolume )*( currentVolume - targetVolume )
	//this.Hvol.push( currentHvol)
	//console.log(Hvol)
	
	
	// compute potential act energy of the cell:
	const bpi = this.C.getStat( CPM.BorderPixelsByCell )[1]
	const actConstraint = this.C.getConstraint( "ActivityConstraint" )
	const lambdaAct = actConstraint.conf.LAMBDA_ACT[1]
	let currentHact = 0
	for( let i = 0; i < bpi.length; i++ ){
		currentHact += -lambdaAct * actConstraint.activityAtGeom( this.C.grid.p2i( bpi[i] ) )
	}
	//this.Hact.push( currentHact )
	
	// total energy
	//this.Htot.push( currentHvol + currentHact )
	
	console.log( sim.time + '\t' + currentHvol + '\t' + currentHact )
	
	
}

sim.run()