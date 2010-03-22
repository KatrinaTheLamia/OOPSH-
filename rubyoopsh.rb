#!/bin/env/ruby
#= RubyShell.rb
# File: ${OOPSH_root}/rubyshell.rb
# Creater: Katrina "The Lamia" Payne
# Maintainer: Katrina "The Lamia" Payne
# Contributors: ???
# Project: The Ruby Shell Project
# Groups: NIMHLabs
# Purpose:
# A general purpose load driver for running RubyOOPSH in irb.
# Files:
# ~/OOPSH/RubyOOPSH/Startup.conf.rb

require "env"
require "directory"

Module OOPSH <<

	config = nil

	default_conf_location = "${env(home)}/OOPSH/RubyOOPSH/Startup.conf.rb"
	default_lib_location = "${env(home)}/OOPSH/lib/RubyOOPSH"


	def config_load(file = default_conf_location, library = default_lib_location) do
		check_directory(file,true)
		check_directory(library)
		$:.push(library)
		if not exists(file) and not readable(path) and writable(path)
			then config_setup(file)
		else require "file"
		end
	end

	def check_directory(path,trailing = false) do
		path = file.split("/");
		if trailing then path.pop end
		compiled_path = ""
		path.each do |directory|
			compiled_path += directory
			if not exists(directory) then mkdir(compiled_path) end
		end

	end

	def config_setup(file) do
		file.open(file, "r").write do
			file.write("#default config file nothing loaded here so far");
		end
	end

end

method_missing(name, *args)
	command = Command::new(name)
	args.each do |argument|
		command.argument_add(argument);
	end
	command.run()
end
