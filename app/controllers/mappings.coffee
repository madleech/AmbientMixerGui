Mappings = require 'models/mappings'
Backbone = require 'backbone'

array_to_hash = (input) ->
	output = {}
	for val in input
		output[val] = val
	output


class MappingController extends Backbone.View
	bus: require 'models/comms-bus'
	className: 'mappings__mapping'
	template: require 'views/_mapping'
	events:
		'click [data-id=save]': 'doSave'
		'change [data-id=type]': 'doChangeType'
		'click [data-id=remove]': 'doRemove'
	
	constructor: (attrs) ->
		@sounds = attrs.sounds
		# @collection = attrs.collection
		super
	
	initialize: ->
		@model.on 'change', => @render()
	
	render: ->
		@$el.html @template
			model: @model
			sounds: @sounds
		@doChangeType()
		@el
	
	doSave: =>
		switch @getType()
			when 'dcc'
				attrs =
					match:
						function: Number @$('[data-id=function]').val()
						state: @$('[data-id=state]').val() == "true"
					sound: @$('[data-id=sound]').val()
					action: @$('[data-id=action]').val()
				# allow wildcard loco
				attrs.match.loco = @$('[data-id=loco]').val() if @$('[data-id=loco]').val().length > 0
				replacement = new Mappings.DccMapping attrs
			when 'event'
				attrs =
					match:
						id: @$('[data-id=id]').val()
						state: @$('[data-id=state]').val() == "true"
					sound: @$('[data-id=sound]').val()
					action: @$('[data-id=action]').val()
				replacement = new Mappings.EventMapping attrs
		
		if replacement.isValid()
			@collection.replace @model, replacement
			@collection.sync()
	
	getType: ->
		@$('[data-id=type]').val()
	
	doChangeType: (e) =>
		type = @getType()
		types = @$el.find '[data-type]'
		types.filter("[data-type=#{type}]").css display: 'inline-block'
		types.not("[data-type=#{type}]").hide()
	
	doRemove: =>
		@model.collection.remove @model


class MappingsController extends Backbone.View
	bus: require 'models/comms-bus'
	className: 'app__mappings'
	attributes:
		'data-id': 'mappings'
	
	initialize: ->
		@bus.on 'request-new-mapping', => @model.attributes.mappings.add new Mappings.EventMapping
		@model.attributes.mappings.on 'add remove reset', => @render()
		@model.attributes.sounds.on 'add remove reset change', => @render()
	
	render: ->
		# render view
		@$el.html require('views/mappings')
			model: @model
		
		# render components
		for mapping in @model.attributes.mappings.models
			controller = new MappingController
				model: mapping
				collection: @model.attributes.mappings
				sounds: array_to_hash(sound.attributes.name for sound in @model.attributes.sounds.models)
			@$el.append controller.render()
		
		@$el

module.exports = MappingsController
