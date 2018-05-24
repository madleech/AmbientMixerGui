jQuery = window.$
Backbone = require 'backbone'

class AlertController extends Backbone.View
	className: 'app__alert modal__background'
	events:
		'click [data-class=dismiss]': -> @$el.remove()
	
	constructor: (@opts) ->
		super
	
	initialize: ->
		@render()
	
	render: ->
		$ document.body
			.append @el
		@$el.html require('views/alert')
			title: @opts.title
			message: @opts.message
		@delegateEvents()
		@$ '[data-class=dismiss]'
			.focus()


module.exports =
	Alert: AlertController