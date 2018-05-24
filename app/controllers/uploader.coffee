jQuery = window.$
Sounds = require 'models/sounds'
Backbone = require 'backbone'

class GenericUploadController extends Backbone.View
	events:
		'dragover': 'onDragOver'
		'dragover .sound__files': 'onDragOver'
		'dragleave': 'onDragLeave'
		'dragleave .sound__files': 'onDragLeave'
		'click [data-id=save]': 'doSave'
		'click [data-id=cancel]': 'doCancel'
		'click [data-id=remove-file]': 'doRemoveFile'
		'click [data-id=play-file]': 'doPlayFile'
		'input [data-id=volume]': (e) -> @$('[data-id=volume-value]').text e.target.value
	files: []
	
	initialize: ->
		@bus = require 'models/comms-bus'
		@bus.on @event, =>
			@files = []
			@render()
	
	render: ->
		$ document.body
			.append @el
		@$el.html @template
		@$('[data-id=name]').focus()
		@dropzone = @$ '.sound__files'
		# need to bind event manually
		@el.ondrop = @doDrop
		@renderFiles()
		@delegateEvents()
	
	onDragOver: =>
		@dropzone.addClass 'files__hover'
		false
	
	onDragLeave: =>
		@dropzone.removeClass 'files__hover'
		false
	
	renderFiles: ->
		@dropzone.html require('views/_uploads')
			files: @files
	
	doDrop: (e) =>
		e.preventDefault()
		for file in e.dataTransfer.files
			@addFile file
		@renderFiles()
		@onDragLeave() # catch any stray hover effects
		false
	
	doRemoveFile: (e) =>
		index = @findFile e
		@files.splice index, 1
		@renderFiles()
		@player?.pause()
		delete @player
	
	findFile: (el) ->
		filename = $ el.target
			.closest '[data-filename]'
			.data 'filename'
		for file, index in @files when file?.name == filename
			return index
	
	doPlayFile: (e) =>
		$e = $ e.target
		
		if @player?
			@player.pause()
			delete @player
		
		if $e.hasClass 'topcoat-button-active'
			$e.removeClass 'topcoat-button-active'
		
		else
			$e.addClass 'topcoat-button-active'
			index = @findFile e
			@player = document.createElement 'audio'
			@player.src = URL.createObjectURL @files[index]
			@player.play()
	
	doCancel: =>
		@$el.remove()


# drag and drop uploading
class NewSoundController extends GenericUploadController
	className: 'app__new-sound modal__background'
	template: require 'views/new-sound'
	event: 'request-new-sound'
	
	doSave: =>
		sound = new @model.attributes.sounds.model
			name: @$('[data-id=name]').val()
			loop: @$('[data-id=loop]:checked').length > 0
			frequency: @$('[data-id=frequency]').val()
			period: @$('[data-id=period]').val()
			volume: @$('[data-id=volume]').val()
			filenames: @files
		if sound.isValid()
			@model.attributes.sounds.add sound
			sound.save()
			@$el.remove()
	
	addFile: (file) ->
		@files.push file


# drag and drop uploading
class NewBackgroundSoundController extends GenericUploadController
	className: 'app__new-background-sound modal__background'
	template: require 'views/new-background-sound'
	event: 'request-new-background-sound'
		
	doSave: =>
		sound = new @model.attributes.background_sounds.model
			name: @$('[data-id=name]').val()
			volume: parseInt @$('[data-id=volume]').val()
			filename: @files[0]
		if sound.isValid()
			@model.attributes.background_sounds.add sound
			sound.save()
			@$el.remove()
	
	addFile: (file) ->
		@files = [file]


module.exports =
	NewSoundController: NewSoundController
	NewBackgroundSoundController: NewBackgroundSoundController
