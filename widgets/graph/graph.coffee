class Dashing.Graph extends Dashing.Widget
	@accessor 'points'
	@accessor 'type'
	@accessor 'units'
	@accessor 'sensor'
	
	
	@accessor 'idx', 
		set: (key, value) ->
			console.log "setting idx for #{@id}"
			data = 
				type: "graph"
				sensor: @get("sensor")
				idx: value  
				range: "day"
			dataname = @get("type")
			$.ajax
				url: '/json.htm'
				context: @
				method: 'GET'
				data: data
				dataType: "json"
				success: (data, textStatus, jqXHR) ->
					console.log "ajx ok, got data"
					#@@set("data", data["result")
					dataxy = []
					#x: new Date(Date.parse(value["d"]))
					for value in data["result"]
						dataxy.push
							x: Date.parse(value["d"]) / 1000 
							y: value[dataname]
					console.log("Setting points")
					console.log(dataxy)
					@set('points', dataxy)
					#@set('points', dataxy)
					if @graph
						@graph.series[0].data = dataxy
						@graph.render()
				error: (data, textStatus, jqXHR) ->
						console.log("error "+data)
		

	@accessor 'current', ->
		return @get('displayedValue') if @get('displayedValue')
		points = @get('points')
		if points
			points[points.length - 1].y

	ready: ->
		container = $(@node).parent()
		# Gross hacks. Let's fix this.
		width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
		height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))
		console.log("graph made!!!!!!!")
		@graph = new Rickshaw.Graph(
			element: @node
			width: width
			height: height
			renderer: 'line',
			series: [
				{
				color: "#fff",
				data: [{x:0, y:0}]
				}
			]
			padding: {top: 0.02, left: 0.02, right: 0.02, bottom: 0.02}
		)

		@graph.series[0].data = @get('points') if @get('points')

		x_axis = new Rickshaw.Graph.Axis.Time(graph: @graph)
		y_axis = new Rickshaw.Graph.Axis.Y(graph: @graph, tickFormat: Rickshaw.Fixtures.Number.formatKMBT)
		@graph.render()

	onData_: (data) ->
		if @graph
			@graph.series[0].data = data.points
			@graph.render()
