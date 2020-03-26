/* Get command line arguments:
 *	-s [settingsfile] : 	file with the config object for the simulation;
 *	-m [max_act] :			max_act value (must be integer)
 *	-l [lambda_act] :		lambda_act value (must be integer)
 *	-d [draw="none"] (opt):	if specified, images are saved under 
 *								data/img/[value]/[value]-t[time].png.
 *	-n [simulation no]:		used as the seed of the random number generator used
 *							for this simulation.
 *	-c [channel=false]:		with flag -c, a microchannel will be drawn on the grid.
 */

const args = require('minimist')(process.argv.slice(2));

const settingsfile = args.s
const mact = parseInt( args.m )
const lact = parseInt( args.l )
const imgsave = args.d || "none"
const simnum = parseInt( args.n )
const channel = args.c || false


let CPM = require("../cpmjs/build/cpm-cjs.js")
let config = require( settingsfile )


// update parameters in config
config.conf["MAX_ACT"][1] = mact
config.conf["LAMBDA_ACT"][1] = lact
config.conf.seed = simnum

if( imgsave === "none" ){
	config.simsettings.SAVEIMG = false
} else {
	config.simsettings.SAVEIMG = true
	config.simsettings.SAVEPATH = "data/img/" + imgsave
	config.simsettings.EXPNAME = imgsave
}


// Stat to compute percentage active pixels
class PercentageActive extends CPM.Stat {

	computePercentageOfCell( cellid, cellpixels  ){
	
		// get pixels of this cell
		const pixels = cellpixels[ cellid ]
		
		// loop over the pixels and count activities > 0
		let activecount = 0
		for( let i = 0; i < pixels.length; i++ ){
			const pos = this.M.grid.p2i( pixels[i] )
			if( this.M.getConstraint( "ActivityConstraint" ).pxact( pos ) > 0 ){
				activecount++
			}
		}
		
		// divide by total number of pixels and multiply with 100 to get percentage
		return ( 100 * activecount / pixels.length )
		
	}

	compute(){
		// Get object with arrays of pixels for each cell on the grid, and get
		// the array for the current cell.
		let cellpixels = this.M.getStat( CPM.PixelsByCell ) 
		
		// Create an object for the centroids. Add the centroid array for each cell.
		let percentages = {}
		for( let cid of this.M.cellIDs() ){
			percentages[cid] = this.computePercentageOfCell( cid, cellpixels )
		}
		
		return percentages
		
	}
}

// Custom method to log stats; this overwrites the default logStats()
// method of the CPM.Simulation class (which only computes centroids).
function logStats(){
		
	// compute centroids for all cells
	let centroids = this.C.getStat( CPM.CentroidsWithTorusCorrection )
	
	// compute connectedness for all cells
	let conn = this.C.getStat( CPM.Connectedness )
	
	// compute percentage of active pixels
	let pact = this.C.getStat( PercentageActive )
	
		
	for( let cid of this.C.cellIDs() ){
		console.log( 
			this.time + "\t" + 
			cid + "\t" + 
			this.C.cellKind(cid) + "\t" + 
			centroids[cid].join("\t") + "\t" +
			conn[cid] + "\t" +
			pact[cid] )
	}

}


// Build and run simulation
let sim = new CPM.Simulation( config, { logStats : logStats } )
sim.run()

