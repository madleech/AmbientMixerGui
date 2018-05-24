Ajax = require 'lib/ajax'
Backbone = require 'backbone'

# {"opcode":["ACON", "ACOF"], "node":1, "event":1, "sound":"crow"},
# {"opcode":["ACON"], "node":1, "event":2, "sound":"morepork"},
# {"opcode":["ACON"], "node":2, "event":1, "sound":"crested hawk"},
# {"opcode":["ACON"], "node":0, "event":"F3", "sound":"horn"},
# {"opcode":["DFON"], "loco":1234, "function":3, "sound":"horn"},
# {"opcode":["DFON", "DFOF"], "loco":"*", "function":1, "sound":"crossing"}

# {"match":{"id":["block-power-upper-rear"], "state":true}, "sound":"horn", "action":"play"},
class EventMapping extends Backbone.Model
	type: 'event'
	bus: require 'models/comms-bus'
	defaults:
		match:
			id: []
			state: true
		sound: null
		action: "play"
	
	initialize: ->
		@on 'invalid', (model, error) -> @bus.trigger 'invalid', model, error
	
	validate: (attrs, options) ->
		if attrs.match.id.length == 0
			"Please select an event id"
		else if attrs.sound == null
			"Please select a sound"
		else if attrs.match.state isnt true and attrs.match.state isnt false
			"Please select a state"
		else if attrs.action isnt "play" and atts.action isnt "stop"
			"Please select an action"

# {"match":{"loco":["NS1113"], "function":2, "state":false}, "sound":"ats_loop", "action":"stop"},
class DccMapping extends EventMapping
	type: 'dcc'
	defaults:
		match:
			loco: null
			function: 0
			state: true
		sound: null
		action: "play"
	
	validate: (attrs, options) ->
		if isNaN attrs.match.function
			"Please select a function"
		else if attrs.match.state isnt true and attrs.match.state isnt false
			"Please select a state"
		else if attrs.sound == null
			"Please select a sound"
		else if attrs.action isnt "play" and attrs.action isnt "stop"
			"Please select an action"

class Mappings extends Backbone.Collection
	model: (attributes, options) ->
		if attributes.match.id?
			new EventMapping attributes, options
		else
			new DccMapping attributes, options
	
	mappingsFor: (sound) ->
		mapping for mapping in @models when mapping.attributes.sound == sound.attributes.name
	
	replace: (model, replacement) ->
		# find model
		for value, key in @models
			if value == model
				@models[key] = replacement
	
	sync: ->
		Ajax.post 'sequencer', 'setup_mappings', null, @


module.exports =
	EventMapping: EventMapping
	DccMapping: DccMapping
	Mappings: Mappings
