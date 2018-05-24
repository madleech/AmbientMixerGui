Sounds = require 'models/sounds'
Backbone = require 'backbone'

class SoundFilesController extends Backbone.View
	className: 'app__files modal__background'
	events:
		'click [data-class=dismiss]': -> @$el.remove()
		'click [data-id=play-file]': (e) ->
			$e = $ e.currentTarget
			index = $e
				.closest '[data-index]'
				.data 'index'
			if $e.hasClass 'topcoat-button--active'
				@model.trigger 'stop', index
				$e.removeClass 'topcoat-button--active'
			else
				@model.trigger 'play', index
				$e.addClass 'topcoat-button--active'
		'click [data-id=remove-file]': (e) ->
			index = $ e.currentTarget
				.closest '[data-index]'
				.data 'index'
			@model.save
				filenames: (filename for filename, i in @model.attributes.filenames when i isnt index)
			@render()
	
	constructor: (@opts) ->
		super
	
	initialize: ->
		@render()
	
	render: ->
		$ document.body
			.append @el
		@$el.html require('views/sound-files')
			model: @model
		@delegateEvents()
		@$ '[data-class=dismiss]'
			.focus()


class SoundController extends Backbone.View
	bus: require 'models/comms-bus'
	className: 'sounds__sound'
	template: require 'views/_sound'
	events:
		'click [data-id=save]': 'doSave'
		'click [data-id=remove]': 'doRemove'
		'click [data-id=files]': 'doFiles'
		'click [data-id=play]': -> @model.trigger 'play'
		'click [data-id=mute]': (e) ->
			$e = $ e.currentTarget
			if $e.hasClass 'topcoat-button--active'
				$e.removeClass 'topcoat-button--active'
				@model.trigger 'mute', false
			else
				$e.addClass 'topcoat-button--active'
				@model.trigger 'mute', true
		'click [data-id=loop]': (e) ->
			$e = $ e.currentTarget
			if $e.hasClass 'topcoat-button--active'
				$e.removeClass 'topcoat-button--active'
				@model.set 'loop': false
			else
				$e.addClass 'topcoat-button--active'
				@model.set 'loop': true
		'click [data-id=stop]': -> @model.trigger 'stop'
		'input [data-id=volume]': (e) -> @$('[data-id=volume-value]').text e.target.value
	
	initialize: ->
		@model.on 'change', => @render()
	
	render: ->
		@$el.html @template
			model: @model
		$(document).trigger 'refresh-styled-select'
		@$el
	
	doSave: =>
		@model.save
			name: @$el.find('[data-id=name]').val()
			# loop: @$el.find('[data-id=loop]:checked').length > 0
			frequency: parseInt @$el.find('[data-id=frequency]').val()
			period: parseInt @$el.find('[data-id=period]').val()
			volume: parseInt @$el.find('[data-id=volume]').val()
	
	doRemove: =>
		@model.destroy()
	
	doFiles: =>
		new SoundFilesController
			model: @model


class SoundsController extends Backbone.View
	bus: require 'models/comms-bus'
	className: 'app__sounds'
	attributes:
		'data-id': 'sounds'
	
	initialize: ->
		@model.attributes.sounds.on 'add remove reset', => @render()
	
	render: ->
		# render view
		@$el.html require('views/sounds')
			model: @model
		
		# render components
		for sound in @model.attributes.sounds.models
			controller = new SoundController
				model: sound
			@$el.append controller.render()
		
		@$el

module.exports = SoundsController
