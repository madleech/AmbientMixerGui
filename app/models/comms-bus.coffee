_ = require 'underscore'
Backbone = require 'backbone'

class CommsBus
	_.extend @prototype, Backbone.Events
	
	set: (key, value) ->
		@[key] = value
		@trigger "#{key}:change", value
	
	get: (key) ->
		@[key]

module.exports = new CommsBus