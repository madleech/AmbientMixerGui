Ajax = require 'lib/ajax'
Sounds = require 'models/sounds'
Mappings = require 'models/mappings'
Backbone = require 'backbone'

class Config extends Backbone.Model
	bus: require 'models/comms-bus'
	defaults: ->
		name: 'New config'
		sounds: new Sounds.Sounds
		background_sounds: new Sounds.BackgroundSounds
		mappings: new Mappings.Mappings
	
	initialize: ->
		@on 'invalid', (model, error) -> @bus.trigger 'invalid', model, error
		@on 'mute', (state) -> Ajax.post 'sequencer', 'mute', null, state
	
	load: (data, updateServer = false) ->
		# load into model
		@set @parse data
		# update server
		@save {}, fullconfig: true if updateServer
	
	fetch: ->
		post = Ajax.post 'config', 'get' #, null, cb: (data) => @load data, false
		post.success (data) => @load data, false
	
	parse: (data) ->
		for key in ['sounds', 'background_sounds', 'mappings'] when data[key]
			@attributes[key].reset data[key]
			# manually set each child as not-new
			child.new = false for child in @attributes[key].models
			data[key] = @attributes[key]
		data
	
	save: (attrs, options) ->
		@set attrs, options if attrs
		if options?.fullconfig
			Ajax.post 'config', 'set', null, JSON.stringify @
		else if @hasChanged()
			Ajax.post 'config', 'set', null, JSON.stringify @changedAttributes()
	
	clear: ->
		@set
			name: @defaults().name
		for collection in ['sounds', 'background_sounds', 'mappings']
			@attributes[collection].reset()
		@save {}, fullconfig: true


module.exports = Config
