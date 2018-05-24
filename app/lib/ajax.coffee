url = "/api"
bus = require 'models/comms-bus'

post = (target, method, name, args...) ->
	raw_post
		target: target
		method: method
		name: name
		args: args

upload = (files, target, method, name, args...) ->
	form = new FormData
	form.append('file', file) for file in files
	# json data
	form.append 'json', JSON.stringify
		target: target
		method: method
		name: name
		args: args
	# submit
	raw_upload form

raw_post = (args) ->
	# remove callback
	if args?.args[0]?.cb
		cb = args.args[0].cb
		delete args.args[0].cb
		_ = require 'underscore'
		if _.keys(args.args[0]).length == 0
			args.args = args.args.splice(1)
	$.ajax
		type: 'POST'
		url: url
		data: JSON.stringify args
		dataType: 'json'
		contentType: 'application/json'
		success: (data) ->
			if data?.error
				bus.trigger 'ajax:error', data.error
			else
				cb? data
		error: (data, error) ->
			console.log data, error
			if data?.error and typeof(data.error) == "string"
				bus.trigger 'ajax:error', data.error
			else if error
				bus.trigger 'ajax:error', error
			else
				bus.trigger 'ajax:error', 'unknown error'

raw_upload = (data) ->
	$.ajax
		type: 'POST'
		url: url
		data: data
		dataType: 'json'
		contentType: false
		processData: false
		success: (data) ->
			if data?.error
				bus.trigger 'ajax:error', data.error
		error: (data) ->
			if data?.error
				bus.trigger 'ajax:error', data.error
			else
				bus.trigger 'ajax:error', 'unknown error'

module.exports = 
	url: url
	post: post
	upload: upload