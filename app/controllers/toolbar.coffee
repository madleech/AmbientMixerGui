Config = require 'models/config'
Backbone = require 'backbone'

class ToolbarController extends Backbone.View
	bus: require 'models/comms-bus'
	className: 'app__toolbar'
	attributes:
		'data-id': 'toolbar'
	events:
		'click [data-id=add]': ->
			switch @bus.get 'active-tab'
				when 'sounds' then @bus.trigger 'request-new-sound'
				when 'backgroundSounds' then @bus.trigger 'request-new-background-sound'
				when 'mappings' then @bus.trigger 'request-new-mapping'
		'click [data-id=show-tab-sounds]': -> @bus.set 'active-tab', 'sounds'
		'click [data-id=show-tab-backgroundSounds]': -> @bus.set 'active-tab', 'backgroundSounds'
		'click [data-id=show-tab-mappings]': -> @bus.set 'active-tab', 'mappings'
		'change [data-id=config-name]': (e) -> @model.save name: e.target.value
		'click [data-id=mute]': (e) ->
			$e = $ e.currentTarget
			if $e.hasClass 'topcoat-button--active'
				@model.trigger 'mute', false
				$e.removeClass 'topcoat-button--active'
			else
				@model.trigger 'mute', true
				$e.addClass 'topcoat-button--active'
		# new
		'click [data-id=new-config]': ->
			@model.clear() if confirm "Are you sure?"
		# get config
		'click [data-id=get-config]': -> @model.fetch()
		# set config
		'click [data-id=set-config]': -> @model.save null, fullconfig: true
		# save
		'click [data-id=save-data]': (e) ->
			# http://paxcel.net/blog/savedownload-file-using-html5-javascript-the-download-attribute-2/
			$ e.target
				.attr
					href: "data:application/json;charset=utf-8,#{encodeURIComponent(JSON.stringify @model)}"
					target: '_blank'
		# load
		'click [data-id=load-data]': (e) ->
			# http://www.richardkotze.com/top-tips/how-to-open-file-dialogue-just-using-javascript
			file = $ "<input type=file>"
			file.click()
			# http://www.html5rocks.com/en/tutorials/file/dndfiles/
			file.on 'change', (e) =>
				if e.target.files.length > 0
					file = e.target.files[0]
					reader = new FileReader
					reader.onload = (file) =>
						@model.load JSON.parse(file.target.result), true
					reader.readAsText file
	
	initialize: ->
		@model.on 'change', => @render()
		@bus.on 'active-tab:change', => @setActiveTab()
	
	render: ->
		@$el.html require('views/toolbar')
			model: @model
		@setActiveTab()
		@$el
	
	setActiveTab: ->
		# make button active
		tab = @bus.get 'active-tab'
		buttons = @$ '[data-id=tab-buttons] .topcoat-button-bar__button'
		buttons
			.removeClass 'tab-button-active'
		buttons
			.filter "[data-id=show-tab-#{tab}]"
			.addClass 'tab-button-active'


module.exports = ToolbarController
