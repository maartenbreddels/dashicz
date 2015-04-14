class Dashing.ThermostateRoom extends Dashing.Widget

	#@accessor 'idx', Dashing.AnimatedValue

	@accessor 'Name', Dashing.AnimatedValue
	@accessor 'temperature'
	@accessor 'setpoint_low'
	@accessor 'setpoint_high'
	@accessor 'setpoint',
		get: ->
			if @get('warm')
				console.log "get high setpoint"
				console.log @get('setpoint_high')
				@get('setpoint_high')
			else
				console.log "get low setpoint"
				console.log @get('setpoint_low')
				@get('setpoint_low')
		set: (_, value) ->
			if @get('warm')
				console.log "set high setpoint"
				console.log @get('setpoint_high')
				@set('setpoint_high', value)
			else
				console.log "set low setpoint"
				console.log @get('setpoint_low')
				@set('setpoint_low', value)
		
	send_setpoint: ->
		value = @get('setpoint')
		data = 
			type: "command"
			param: "udevice"
			idx: if @get('warm') then @get('idx_setpoint_high') else @get('idx_setpoint_low')  
			nvalue: 0
			svalue: value
		console.log "setting setpoint_#{@get('setpoint')} = #{value}"
		$.ajax
			url: '/json.htm'
			context: @
			method: 'GET'
			data: data
			success: (data, textStatus, jqXHR) ->
				console.log "ajx ok, set setpoint setpoint_#{@get('setpoint')} = #{value}"
				@set("setpoint_#{@get('mode')}", value)
			error: (data, textStatus, jqXHR) ->
					console.log("error "+data)
			
			
	@accessor 'warm'
	
	send_warm: ->
			console.log("LAAAAAAAAAAAAAAAAAAAAAAAAAAA")
			value = @get('warm')
			console.log("sending warm to: " +value)
			data = 
				type: "command"
				param: "udevice"
				idx: @get('idx_warm')  
				nvalue: if value then 1 else 0
				svalue: if value then "On" else "Off"
			$.ajax
				url: '/json.htm'
				context: @
				method: 'GET'
				data: data
				success: (data, textStatus, jqXHR) ->
					console.log "ajx ok, set mode setpoint_#{@get('mode')} = #{value}"
					#@set("setpoint_#{@get('mode')}", value)
				error: (data, textStatus, jqXHR) ->
						console.log("error "+data)
	@accessor 'heating'
	@accessor 'mode',
		get: () ->
			if @get('warm')
				"high"
			else
				"low"
				
		
	
	
	#@accessor 'value', ->

	constructor: ->
		super
		console.log("id = " + @id)
		Dashing.add_composite(@id, (id, devices) -> 
			data = 
				id: id
			room = id
			name = "#{room} Temperatuur"
			if devices[name]
				data["temperature"] = devices[name]?.Temp
				data["idx_temperature"] = devices[name]?.idx
			name = "#{room} Instelpunt"
			if devices[name]
				data["setpoint_high"] = devices[name]?.Data
				data["idx_setpoint_high"] = devices[name]?.idx
			name = "#{room} Instelpunt laag"
			if devices[name]
				data["setpoint_low"] = devices[name]?.Data
				data["idx_setpoint_low"] = devices[name]?.idx
			name = "#{room} warm"
			if devices[name]
				data["warm"] = devices[name]?.Data == "On"
				data["idx_warm"] = devices[name].idx
			name = "#{room} Klep"
			if devices[name]
				data["heating"] = devices[name]?.Data == "On"
				data["idx_heating"] = devices[name]?.idx
			return data
		)
						
	@::observe 'setpoint_low', (value) ->
		console.log("change knob")
		value = @get('setpoint')
		console.log("SETPOINT low " +value)
		$(@node).find(".setpoint-value").html(Number(@get('setpoint')).toFixed(1).toString())
		$(@node).find(".setpoint").slider("option", "value", @get('setpoint'))

	@::observe 'setpoint_high', (value) ->
		console.log("change knob")
		value = @get('setpoint')
		console.log("SETPOINT high " +value)
		#$(@node).find(".temperature").val(Number(value).toFixed(1).toString()).trigger('change')
		$(@node).find(".setpoint-value").html(Number(@get('setpoint')).toFixed(1).toString())
		$(@node).find(".setpoint").slider("option", "value", @get('setpoint'))

	@::observe 'temperature', (value) ->
		console.log("CHANGE temperature")
		$(@node).find(".temperature-value").html(Number(value).toFixed(1).toString())

	@::observe 'heating', (value) ->
		console.log("CHANGE heating: " +value)
		$(@node).find(".heating-icon").css("opacity", if value then 1 else 0 )

	@::observe 'warm', (value) ->
		mode = @get('mode')
		check = @get('warm')
		console.log("CHANGE!! warm: " +value + " mode" +mode + "> >> " +check)
		console.log(check)
		console.log("setpoint " +@get('setpoint'))
		console.log($(@node).find("[id='#{@id}_low']"))
		console.log($(@node).find("[id='#{@id}_high']"))
		$(@node).find("[id='#{@id}_low']").removeAttr("checked") #, mode == "low")
		$(@node).find("[id='#{@id}_high']").removeAttr("checked") #, mode == "high")
		$(@node).find("[id='#{@id}_#{mode}']").prop("checked", true)
		$(@node).find(".thermostate_state").buttonset('refresh')
		$(@node).find(".setpoint-value").html(Number(@get('setpoint')).toFixed(1).toString())
		$(@node).find(".setpoint").slider("option", "value", @get('setpoint'))


	ready: ->
		widget = @
		setpoint = $(@node).find(".setpoint")
		setpoint.empty().slider
			orientation: "horizontal"
			value: @.get('setpoint')
			min: -10
			max: 40
			step: 0.2
			slide: (event, ui ) ->
				#event.preventDefault()
				$(widget.node).find(".setpoint-value").html(Number(ui.value).toFixed(1).toString())
			stop: (event, ui ) ->
				console.log("event from slider")
				widget.set('setpoint', ui.value)
				widget.send_setpoint()
		.height(5)
		$(@node).find(".setpoint-value").html(Number(@get('setpoint')).toFixed(1).toString())
		$(@node).find(".temperature-value").html(Number(@get('temperature')).toFixed(1).toString())
			

		mode = @get('mode')
		$(widget.node).find("[id='#{widget.id}_#{mode}']").attr("checked", true)
		$(@node).find(".thermostate_state").buttonset()

		$(@node).find(".thermostate_state input").on "click", (event) ->
			event.preventDefault();
			#console.log(event.target)
			#console.log($(event.target).attr("id"))
			#console.log(widget.id+'_low')
			#value = widget.get("Setpoint")
			#console.log "setpoint: " +value
			if $(event.target).attr("id") == (widget.id+'_low')
				widget.set("warm", false)
			else
				widget.set("warm", true)
			value = widget.get("setpoint")
			$(widget.node).find(".setpoint-value").html(Number(value).toFixed(1).toString())
			setpoint.slider("option", "value", value)
			widget.send_warm()

		$(@node).find(".heating-icon").css("opacity", if @.get('heating') then 1 else 0 )

