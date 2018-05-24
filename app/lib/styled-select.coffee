refresh = (el) ->
	el
		.find '.styled-select select'
		.each ->
			doChange $ this

doChange = (el) ->
	el
		.parent '.styled-select'
		.find '.styled-select__value'
		.text el.find('option:selected').text()

$(document).on 'change blur close select', '.styled-select select', (e) ->
	doChange $ e.target

$(document).on 'refresh-styled-select', (e) ->
	refresh $ e.target

module.exports = refresh
