class Dashing.Dimmer extends Dashing.Widget

	@accessor 'idx'
	@accessor 'Level'

	constructor: ->
		super
	@::observe 'Level', (value) ->
		console.log("LEVEL " +value)
		$(@node).find(".meter").val(value).trigger('change')

	ready: ->
		meter = $(@node).find(".meter")
		meter.attr("data-bgcolor", meter.css("background-color"))
		meter.attr("data-fgcolor", meter.css("color"))
		widget = this
		meter.knob(
			release: (value) ->
				data = 
					type: "command"
					param: "switchlight"
					idx: widget.get('idx') 
					switchcmd: "Set Level"
					level: (value / 100 * 16).toFixed(0)
				console.log("ajax knob")
				$.ajax
					url: '/json.htm'
					context: this
					method: 'GET'
					data: data
					success: (data, textStatus, jqXHR) ->
						console.log "ok value send"
						#@set("setpoint_#{@get('mode')}", value)
					error: (data, textStatus, jqXHR) ->
						console.log("error "+data)
				
		)
		console.log("LEVEL 2) " +@get('Level'))
		$(@node).find(".meter").val(@get('Level')).trigger('change')
