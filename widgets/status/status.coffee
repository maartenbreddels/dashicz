class Dashing.Status extends Dashing.Widget
	@accessor 'items'
	constructor: ->
		super
		console.log("id = " + @id)
	
	addComposite: ->
		device_names = @get('devices')
		console.log("devices = " + device_names)
		widget = this

		Dashing.add_composite(@id, (id, devices) -> 
			data = 
				id: id
			room = id
			data["items"] = []
			for device_name in device_names.split(",")
					data["items"].push
						label: device_name
						on: devices[device_name].Data == "On"
						off: devices[device_name].Data == "Off"
						
			console.log(data)
			return data
		)
		#Dashing.update_composites(Dashing.lastEvents)
	ready: ->
		if 0
			if @get('unordered')
				$(@node).find('ol').remove()
			else
				$(@node).find('ul').remove()
      
      