
/* A simple d3 line chart */

class Linechart { 
	constructor( conf ){
		let el = conf.el
		if( !el ){
			el = document.createElement("div")
			el.setAttribute("class","plot")
			document.body.appendChild(el)
		} else {
			el = document.getElementById(el)
		}
		let x, y

		this.margin = {top: 20, right: 30, bottom: 30, left: 40}
		this.width = el.offsetWidth
		this.height = el.offsetHeight

		let data = conf.data || [[0,0],[1,1]]

		let ylim
		if( conf.ylim ){
			ylim = conf.ylim
			this.ylim = ylim
		} else {
			ylim = [0, d3.max(data, d => d[1])]
		}


		let xlim
		if( conf.xlim ){
			xlim = conf.xlim
			this.xlim = xlim
		} else {
			xlim = [0, d3.max(data, d => d[0])]
		}
		

		this.x = d3.scaleLinear()
 			.domain(xlim).nice()
    		.range([this.margin.left, this.width - this.margin.right])

		this.y = d3.scaleLinear()
   			.domain(ylim).nice()
			.range([this.height - this.margin.bottom, this.margin.top])

		this.xAxis = g => g
			.attr("class","xaxis")
   			.attr("transform", `translate(0,${this.height - this.margin.bottom})`)
 			.call(d3.axisBottom(this.x).ticks(this.width / 100).tickSizeOuter(0))

		this.yAxis = g => g
    		.attr("transform", `translate(${this.margin.left},0)`)
    		.call(d3.axisLeft(this.y).ticks(this.height / 50))
    		//.call(g => g.select(".domain").remove())

		let line = d3.line()
			.defined(d=>!isNaN(d[1]))
			.x(d => this.x(d[0]))
 			.y(d => this.y(d[1]))

		let svg = d3.select(el).append("svg")

		svg.attr("viewBox", [0, 0, this.width, this.height]);
		
		svg.append("g").call(this.xAxis);

		svg.append("g").attr("class","yaxis").call(this.yAxis);

		svg.append("path")
			.attr("class", "line")
			.datum(data)
			.attr("fill", "none")
			.attr("stroke", "steelblue")
			.attr("stroke-width", 1.5)
			.attr("stroke-linejoin", "round")
			.attr("stroke-linecap", "round")
			.attr("d", line)

		//if( conf.title ){
			svg.append("text")
        		.attr("x", this.width / 2)            
		        .attr("y", this.margin.top)
		        .attr("text-anchor", "middle")  
		        .style("font-size", "16px") 
        		.text(conf.title);
		//}

		this.svg = svg
		this.line = line
	}


	update( data ){
		if( data.length > 0 && !Array.isArray(data[0]) ){
			data = data.slice(0)
			for( let i = 0 ; i < data.length ; i ++ ){
				data[i] = [i,data[i]]
			}
		}
		//console.log( data )
		if(!this.xlim){
			this.x = d3.scaleLinear()
 				.domain([0, d3.max(data, d => d[0])]).nice()
	   	 		.range([this.margin.left, this.width - this.margin.right])
			this.svg.select(".xaxis").call(this.xAxis)
		}
		if(!this.ylim){
			this.y = d3.scaleLinear()
   				.domain([d3.min(data, d => d[1]), d3.max(data, d => d[1])]).nice()
				.range([this.height - this.margin.bottom, this.margin.top])
			this.svg.select(".yaxis").call(this.yAxis)
		}

		this.svg.select(".line").datum(data).attr("d",this.line)
	}
}

