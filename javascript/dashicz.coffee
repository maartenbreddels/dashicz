#= require jquery
#= require es5-shim
#= require batman
#= require batman.jquery


Batman.config.viewPrefix = 'dashicz/widgets'
	
Batman.ViewStore.prototype.fetchView = (path) ->
  _this = this
  new (Batman.Request)(
    url: Batman.Navigator.normalizePath(Batman.config.viewPrefix, '' + path + '/' + path + '.html')
    type: 'html'
    success: (response) ->
      _this.set path, response
    error: (response) ->
      throw new Error('Could not load view from ' + path)
      return
)



Batman.Filters.prettyNumber = (num) ->
  num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") unless isNaN(num)

Batman.Filters.dashize = (str) ->
  dashes_rx1 = /([A-Z]+)([A-Z][a-z])/g;
  dashes_rx2 = /([a-z\d])([A-Z])/g;

  return str.replace(dashes_rx1, '$1_$2').replace(dashes_rx2, '$1_$2').replace(/_/g, '-').toLowerCase()

Batman.Filters.shortenedNumber = (num) ->
  return num if isNaN(num)
  if num >= 1000000000
    (num / 1000000000).toFixed(1) + 'B'
  else if num >= 1000000
    (num / 1000000).toFixed(1) + 'M'
  else if num >= 1000
    (num / 1000).toFixed(1) + 'K'
  else
    num

class window.Dashing extends Batman.App
  @on 'reload', (data) ->
    window.location.reload(true)

  @root ->
Dashing.params = Batman.URI.paramsFromQuery(window.location.search.slice(1));

class Dashing.Widget extends Batman.View
  constructor:  ->
    # Set the view path
    @constructor::source = Batman.Filters.underscore(@constructor.name)
    super

    @mixin($(@node).data())
    @addComposite()
    Dashing.widgets[@id] ||= []
    Dashing.widgets[@id].push(@)
    @mixin(Dashing.lastEvents[@id]) # in case the events from the server came before the widget was rendered
    type = Batman.Filters.dashize(@view)
    $(@node).addClass("widget widget-#{type} #{@id}")

  @accessor 'updatedAtMessage', ->
    if updatedAt = @get('updatedAt')
      timestamp = new Date(updatedAt * 1000)
      hours = timestamp.getHours()
      minutes = ("0" + timestamp.getMinutes()).slice(-2)
      "Last updated at #{hours}:#{minutes}"

  @::on 'ready', ->
    Dashing.Widget.fire 'ready'

  receiveData: (data) =>
    @mixin(data)
    @onData(data)

  onData: (data) =>
    # Widgets override this to handle incoming data
  addComposite: =>

Dashing.AnimatedValue =
  get: Batman.Property.defaultAccessor.get
  set: (k, to) ->
    if !to? || isNaN(to)
      @[k] = to
    else
      timer = "interval_#{k}"
      num = if (!isNaN(@[k]) && @[k]?) then @[k] else 0
      unless @[timer] || num == to
        to = parseFloat(to)
        num = parseFloat(num)
        up = to > num
        num_interval = Math.abs(num - to) / 90
        @[timer] =
          setInterval =>
            num = if up then Math.ceil(num+num_interval) else Math.floor(num-num_interval)
            if (up && num > to) || (!up && num < to)
              num = to
              clearInterval(@[timer])
              @[timer] = null
              delete @[timer]
            @[k] = num
            @set k, to
          , 10
      @[k] = num

Dashing.widgets = widgets = {}
Dashing.lastEvents = lastEvents = {}
Dashing.debugMode = false

if 0
	source = new EventSource('events')
	source.addEventListener 'open', (e) ->
	console.log("Connection opened", e)

	source.addEventListener 'error', (e)->
	console.log("Connection error", e)
	if (e.currentTarget.readyState == EventSource.CLOSED)
		console.log("Connection closed")
		setTimeout (->
		window.location.reload()
		), 5*60*1000

	source.addEventListener 'message', (e) ->
	data = JSON.parse(e.data)
	if lastEvents[data.id]?.updatedAt != data.updatedAt
		if Dashing.debugMode
			console.log("Received data for #{data.id}", data)
		if widgets[data.id]?.length > 0
			lastEvents[data.id] = data
			for widget in widgets[data.id]
				widget.receiveData(data)

	source.addEventListener 'dashboards', (e) ->
	data = JSON.parse(e.data)
	if Dashing.debugMode
		console.log("Received data for dashboards", data)
	if data.dashboard is '*' or window.location.pathname is "/#{data.dashboard}"
		Dashing.fire data.event, data

	$(document).ready ->
		Dashing.run()

Dashing.composites = {}
Dashing.add_composite = (id, merge_function)->
	console.log("adding composite for " +id)
	Dashing.composites[id] ||= []
	Dashing.composites[id].push(merge_function)
	
Dashing.update_composites = (devices) ->
	#devices = {}
	#for device in devices_list
	#	devices[device.Name] = device
	for id, merge_functions of Dashing.composites
		console.log("merging for " +id)
		for merge_function in merge_functions
			data = merge_function(id, devices)
			data["id"] = id
			if widgets[id]
				console.log("update " +id)
				for widget in widgets[id]
					widget.receiveData(data)
			
bla = ->
	rooms = ["Slaapkamer groot"]
	devices = {}
	for device in devices_list
		#console.log device.Name
		devices[device.Name] = device
	#console.log devices
	for room in rooms
		data = 
			id: room
		name = "#{room} Temperatuur"
		if devices[name]
			data["temperature"] = devices[name].Temp
			data["idx_temperature"] = devices[name].idx
		name = "#{room} Instelpunt"
		if devices[name]
			data["setpoint_high"] = devices[name].Data
			data["idx_setpoint_high"] = devices[name].idx
		name = "#{room} Instelpunt laag"
		if devices[name]
			data["setpoint_low"] = devices[name].Data
			data["idx_setpoint_low"] = devices[name].idx
		name = "#{room} warm"
		if devices[name]
			data["warm"] = devices[name].Data == "On"
			data["idx_warm"] = devices[name].idx
		name = "#{room} Klep"
		data["heating"] = devices[name]?.Data == "On"
		data["idx_heating"] = devices[name]?.idx
		
		if widgets[data.id]
			console.log("update " +data.id)
			for widget in widgets[data.id]
				console.log(data)
				widget.receiveData(data)
		
domoticz_last_update = undefined

domoticz_update = ->
	data =
		type: "devices"
	if domoticz_last_update != undefined
		data["lastupdate"] = domoticz_last_update
	console.log("json update")
	$.ajax
		url: "/json.htm"
		data: data
		dataType: "json"
		success: (data, textStatus, jqXHR) ->
				#console.log(widgets)
				domoticz_last_update = data["ActTime"]
				setTimeout domoticz_update, 4000
				Dashing.data = data
				if data.result
					for device in data.result
						Dashing.lastEvents[device.Name] = device
						#console.log(device.Name)
						if widgets[device.Name]
							#console.log("update " +device.Name)
							for widget in widgets[device.Name]
								widget.receiveData(device)
				Dashing.update_composites(Dashing.lastEvents)
				console.log("timeago")
				$("p.updated-at").timeago();
				#console.log(Dashing.widgets["Slaapkamer groot Temperatuur"])
		error: (data, textStatus, jqXHR) ->
				console.log("error "+data)
				setTimeout domoticz_update, 10

$(document).ready ->
	Dashing.run()
	domoticz_update()
	
Dashing.on 'ready__', ->
	console.log("test")
	Dashing.widget_margins = [5, 5]
	Dashing.widget_base_dimensions = [300, 360]
	Dashing.numColumns = 4

	contentWidth = (Dashing.widget_base_dimensions[0] + Dashing.widget_margins[0] * 2) * Dashing.numColumns

	Batman.setImmediate ->
		$('.gridster').width(contentWidth)
		$('.gridster ul:first').gridster
		widget_margins: Dashing.widget_margins
		widget_base_dimensions: Dashing.widget_base_dimensions
		avoid_overlapped_widgets: !Dashing.customGridsterLayout
		draggable:
			stop: Dashing.showGridsterInstructions
			start: -> Dashing.currentWidgetPositions = Dashing.getWidgetPositions()
	$(".gridster ul").gridster().data('gridster').disable();
	
	
	