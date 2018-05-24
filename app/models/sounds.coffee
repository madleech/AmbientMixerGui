Ajax = require 'lib/ajax'
Backbone = require 'backbone'


class Sound extends Backbone.Model
	bus: require 'models/comms-bus'
	new: true
	defaults:
		name: ''
		filenames: []
		loop: false
		frequency: 0
		period: 0
		volume: 100
		playing: false
	
	initialize: ->
		# custom same events
		@on 'play', (index) ->
			if index?
				Ajax.post 'sound', 'play_sound_at_index', @attributes.name, index
			else
				Ajax.post 'sound', 'play', @attributes.name
		@on 'stop', (index) ->
			if index?
				Ajax.post 'sound', 'stop_sound_at_index', @attributes.name, index
			else
				Ajax.post 'sound', 'stop', @attributes.name
		@on 'mute', (state) -> Ajax.post 'sound', 'mute', @attributes.name, state
		@on 'invalid', (model, error) -> @bus.trigger 'invalid', model, error
	
	set: (attributes, options) ->
		if attributes.loop?
			attributes.loop = false if attributes.loop != true # force bool
			attributes.frequency = 0 if attributes.loop == true
		if attributes.frequency?
			attributes.frequency = Number(attributes.frequency) || 0 # force numeric
		if attributes.period?
			attributes.period = Number(attributes.period) || 0 # force numeric
		if attributes.volume?
			attributes.volume = Number(attributes.volume) || 0 # force numeric
		super attributes, options
	
	validate: (attributes) ->
		if attributes.name.length == 0
			"Must enter a name"
		else if attributes.filenames.length == 0
			"Must select some files"
		else if (match = @collection?.where(name: attributes.name)) and match?.length > 0 and match[0].cid isnt @.cid
			"Name already in use; please select a unique name"
	
	isNew: -> @new
	
	sync: (method, model, options) ->
		if @isNew()
			files = (file for file in @attributes.filenames)
			post = Ajax.upload files, 'sequencer', 'setup_sounds', null, [@attributesForUpload()], false
			post.success (data) =>
				for sound in data when sound.name == @attributes.name
					@set sound
			@new = false
		else if @hasChanged()
			Ajax.post 'sequencer', 'update_sound_config', null, @previous('name'), @changedAttributes()
	
	attributesForUpload: ->
		out = {}
		for key, value of @attributes
			out[key] = switch key
				when 'filenames' then (file.name for file in value)
				else value
		out


class BackgroundSound extends Backbone.Model
	bus: require 'models/comms-bus'
	new: true
	defaults:
		name: ''
		filename: null
		volume: 100
		playing: false
	
	initialize: ->
		# custom same events
		@on 'mute', (state) -> Ajax.post 'background_sound', 'mute', @attributes.name, state
		@on 'play', -> Ajax.post 'background_sound', 'play', @attributes.name
		@on 'stop', -> Ajax.post 'background_sound', 'stop', @attributes.name
		@on 'invalid', (model, error) -> @bus.trigger 'invalid', model, error
	
	set: (attributes, options) ->
		attributes.volume = Number(attributes.volume) || 0 # force numeric
		super attributes, options
	
	validate: (attributes) ->
		console.log 'validate', attributes
		if attributes.name.length == 0
			"Must enter a name"
		else if attributes.filename == null or (typeof(attributes.filename) == 'object' and attributes.filename.name == '')
			"Must select some files"
		else if (match = @collection?.where(name: attributes.name)) and match?.length > 0 and match[0].cid isnt @.cid
			"Name already in use; please select a unique name"
	
	isNew: -> @new
	
	sync: (method, model, options) ->
		if @isNew()
			post = Ajax.upload [@attributes.filename], 'sequencer', 'setup_background_sounds', null, [@attributesForUpload()], false
			post.success (data) =>
				for sound in data when sound.name == @attributes.name
					@set sound
			@new = false
		else if @hasChanged()
			Ajax.post 'sequencer', 'update_background_sound_config', null, @previous('name'), @changedAttributes()
	
	attributesForUpload: ->
		out = {}
		for key, value of @attributes
			out[key] = switch key
				when 'filename' then value.name
				else value
		out


class Sounds extends Backbone.Collection
	model: (attributes, options) ->
		attributes.filenames = attributes.filename unless attributes.filenames
		new Sound attributes, options


class BackgroundSounds extends Backbone.Collection
	model: BackgroundSound


module.exports =
	Sound: Sound
	Sounds: Sounds
	BackgroundSound: BackgroundSound
	BackgroundSounds: BackgroundSounds