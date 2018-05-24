Sounds = require 'models/sounds'
Backbone = require 'backbone'

class BackgroundSoundController extends Backbone.View
	bus: require 'models/comms-bus'
	className: 'sounds__sound'
	template: require 'views/_background_sound'
	events:
		'click [data-id=save]': 'doSave'
		'click [data-id=play]': -> @model.trigger 'play'
		'click [data-id=stop]': -> @model.trigger 'stop'
		'input [data-id=volume]': (e) -> @$('[data-id=volume-value]').text e.target.value
	
	initialize: ->
		@model.on 'change', => @render()
	
	render: ->
		@$el.html @template
			model: @model
	
	doSave: =>
		@model.save
			name: @$el.find('[data-id=name]').val()
			volume: parseInt @$el.find('[data-id=volume]').val()


class BackgroundSoundsController extends Backbone.View
	bus: require 'models/comms-bus'
	className: 'app__background-sounds'
	attributes:
		'data-id': 'background-sounds'
	
	initialize: ->
		@model.attributes.background_sounds.on 'add remove reset', => @render()
	
	render: ->
		# render view
		@$el.html require('views/background-sounds')
			model: @model
		
		# render components
		for sound in @model.attributes.background_sounds.models
			controller = new BackgroundSoundController
				model: sound
			@$el.append controller.render()
		
		@$el

module.exports = BackgroundSoundsController