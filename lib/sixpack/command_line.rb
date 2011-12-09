require 'optparse'
require File.expand_path(File.dirname(__FILE__) + '/../sixpack')

module Sixpack

  class CommandLine

    BANNER = <<-EOS

Usage: sixpack OPTIONS

TODO: Sixpack is your right hand in asset compiling, bundling and deployment.

Options:
    EOS

    def initialize
      parse_options
      
      ensure_configuration_file
      ensure_only_one_mode
      
      if @options[:watch]
        Sixpack.watch(@options)
      elsif @options[:deploy]
        Sixpack.deploy(@options)
      elsif @options[:compile]
        Sixpack.compile(@options)
      end
    end

    private

    def ensure_configuration_file
      config = @options[:config_path]
      return true if File.exists?(config) && File.readable?(config)
      puts "Could not find the asset configuration file \"#{config}\""
      exit(1)
    end

    def ensure_only_one_mode
      modes = [@options[:watch], @options[:deploy], @options[:compile]]

      unless modes.select { |i| i }.count == 1
        puts 'Please specify one mode at a time (watch, deploy or compile).'
        exit(1)
      end
    end

    def parse_options
      @options = {
        config_path: '',
        watch: false,
        deploy: false,
        compile: false,
        package: nil,
        type: 'all'
      }
      
      @option_parser = OptionParser.new do |opts|
        opts.on('-a', '--asset PATH', 'path to assets.yml') do |config_path|
          @options[:config_path] = config_path
        end

        opts.on('-p', '--package NAME', 'only compile given package') do |package|
          @options[:package] = package
        end

        opts.on('-t', '--type TYPE', 'only compile packages of type {javascripts,stylesheets,images,files,all}') do |type|
          @options[:type] = type
        end        
        
        opts.on('-w', '--watch', 'watch for changes') do |watch|
          @options[:watch] = true
        end

        opts.on('-c', '--compile', 'compile package') do |watch|
          @options[:compile] = true
        end
        
        opts.on('-d', '--deploy', 'deploy to specified target') do |deploy|
          @options[:deploy] = true
        end
        
        opts.on_tail('-v', '--version', 'display Sixpack version') do
          puts "Sixpack version #{Sixpack::VERSION}"
          exit
        end
      end

      @option_parser.banner = BANNER
      @option_parser.parse!(ARGV)
    end

  end

end