require 'lib/styled-select'
jQuery = window.$
Alerts = require 'controllers/alerts'
Config = require 'models/config'
Backbone = require 'backbone'
Uploader = require 'controllers/uploader'
SoundsController = require 'controllers/sounds'
ToolbarController = require 'controllers/toolbar'
MappingsController = require 'controllers/mappings'
BackgroundSoundsController = require 'controllers/background-sounds'

# manually export jquery, backbone doesn't seem to detect it automatically
Backbone.$ = jQuery

class App extends Backbone.View
	className: 'app'
	bus: require 'models/comms-bus'
	
	initialize: ->
		# create global setup
		@model = new Config
		# get current set up
		@model.fetch()
		
		# load view
		@$el.html require "views/app"
		
		# create controllers
		@controllers =
			toolbar: new ToolbarController
				model: @model
			sounds: new SoundsController
				model: @model
			backgroundSounds: new BackgroundSoundsController
				model: @model
			mappings: new MappingsController
				model: @model
		
		new Uploader.NewSoundController model: @model
		new Uploader.NewBackgroundSoundController model: @model
		
		# and add them to the view
		for name, controller of @controllers
			@$el.append controller.render()
		
		# tab change events
		@bus.on 'active-tab:change', (tab) => @showTab tab
		@bus.set 'active-tab', 'sounds'
		
		# application errors
		@bus.on 'ajax:error', (error) ->
			new Alerts.Alert title: 'AJAX error', message: error
		@bus.on 'invalid', (model, error) ->
			new Alerts.Alert title: "Error with #{model.constructor.name}", message: error
	
	showTab: (tab) ->
		for name, controller of @controllers when name isnt 'toolbar'
			if name is tab
				controller.$el.show()
			else
				controller.$el.hide()


module.exports = App