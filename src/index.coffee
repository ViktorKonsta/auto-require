fs = require 'fs'
path = require 'path'
valid = require './valid'
color = require 'chalk'
Require = require './require.class'
zipObject = require 'lodash.zipobject'

Array::drop = require './deleteFromArray'

module.exports = (options) ->

	folders = []
	only = null
	without = null
	search = ['./node_modules/']

	if options
		if valid options.search
			{search} = options

		if valid options.only
			{only} = options
		else
			if valid options.without
				{without} = options

	for onePath in search
		try
			content = fs.readdirSync path.resolve onePath
		catch e
			if e.code is 'ENOENT'
				console.log color.yellow.bold """
					| WARN! No such file or directory.
					| #{e.path}
					| So this path will be empty."""
				content = []
		if only
			arr = []
			for one in content
				for onlyModule in only when one is onlyModule
					arr.push one
			folders.push arr
		else
			folders.push content

	for moduleGroups in folders
		if without
			for one in without
				moduleGroups.drop one
		for oneModule in moduleGroups
			if oneModule is '.bin' or oneModule is 'auto-require'
				moduleGroups.drop oneModule

	modulesMap = zipObject search, folders
	that = new Require modulesMap
	return that.collection