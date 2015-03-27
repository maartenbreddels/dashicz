update_domoticz = (idx, nvalue, svalue) ->
	data = 
		type: "command"
		param: "udevice"
		idx: idx  
		nvalue: nvalue
		svalue: svalue
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


class Dashing.Switch extends Dashing.Widget

	@accessor 'idx'
	
	@accessor 'lastUpdate', ->
		(new Date(Date.parse( @get('LastUpdate') ))).toISOString()
	
	@accessor 'difference', ->
		if @get('last')
			last = parseInt(@get('last'))
			current = parseInt(@get('current'))
			if last != 0
				diff = Math.abs(Math.round((current - last) / last * 100))
				"#{diff}%"
		else
			""
	@accessor 'Data', Dashing.AnimatedValue
	@accessor 'Name', Dashing.AnimatedValue

	@accessor 'image', ->
		data = @get('Data')
		"images/Light48_#{data}.png"

	#@accessor 'arrow', ->
	#  if @get('last')
	#   if parseInt(@get('current')) > parseInt(@get('last')) then '+' else '-'
	#   #if parseInt(@get('current')) > parseInt(@get('last')) then 'icon-arrow-up' else 'icon-arrow-down'

	o_nData: (data) ->
		if data.status
			$(@get('node')).addClass("status-#{data.status}")
		
		
	ready: ->
	# This is fired when the widget is done being rendered

	onData: (data) ->
		# Handle incoming data
		# You can access the html node of this widget with `@node`
		# Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.
		#$(@node).fadeOut(100).fadeIn(100)
	constructor: ->
		super
		widget = this
		$(@node).on('click touchstart', ->
			ison = widget.get('Data') == "On" ? true : false
			console.log("click: " +ison)
			nvalue = if ison then 0 else 1
			svalue = if ison then "Off" else "On"
			update_domoticz(widget.get('idx'), nvalue, svalue) 
			#if ison
			#	$.post("/dz/off/", data={id : widget.id})
			#else
			#	$.post("/dz/on/", data={id : widget.id})
		)
		console.log("bind")
		
		
	
	