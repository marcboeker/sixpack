$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))

require 'uri'
require 'set'
require 'yaml'
require 'fssm'
require 'awesome_print'

require 'sixpack/assets/asset.rb'
require 'sixpack/assets/item.rb'
require 'sixpack/assets/image.rb'
require 'sixpack/assets/javascript.rb'
require 'sixpack/assets/stylesheet.rb'

require 'sixpack/deploy/handler.rb'
require 'sixpack/deploy/s3.rb'
require 'sixpack/deploy/file_system.rb'

module Sixpack
  VERSION = '0.0.1'
  @ignore = Set.new

  class << self

    def compile(config)
      @config = parse_config(config[:config_path])
      process(:development, config[:type], config[:package])
    end

    def watch(config)
      Signal.trap('INT') { puts "\nStop tracking changes."; exit }
      
      @config = parse_config(config[:config_path])
      watcher(config[:type], config[:package])
    end

    def deploy(config)
      @config = parse_config(config[:config_path])
      process(:production, config[:type], config[:package])
    end

  end

  private

  def self.log(msg, color=:normal)
    color = case color
    when :normal then 0
    when :red then 31
    when :green then 32
    when :yellow then 33
    when :blue then 34
    end

    puts "\033[#{color}m#{msg}\033[0m"
  end

  def self.parse_config(path)
    YAML.load_file(path)
  end

  def self.config
    @config['defaults'].dup
  end

  def self.watcher(type, package)
    compile = ->(base, relative) do
      file = File.join(base, relative)
      
      unless @ignore.include?(file)
        Sixpack.process(:development, type, package)
      end
    end

    FSSM.monitor(@config['defaults']['base'], '**/*') do
      update { |base, relative| compile.call(base, relative) }
    end
  end

  def self.process(mode, type, package)
    types = if type == 'all'
      %w(javascripts stylesheets images)
    else
      [type]
    end

    types.each do |type|
      @config[type].each do |name, data|
        next if package && package != name

        data['files'] = [data['file']] if type == 'images'

        opts = config.merge('mode' => mode, 'type' => type, 'name' => name)
        opts = opts.merge(data)

        execute(opts)
      end if @config.has_key?(type)
    end

    if ['all', 'items'].include?(type) && @config.has_key?('items')
      # FIXME: This is way too ugly.
      @config['items'].each do |name, data|
        next if package && package != name
        
        data['files'].each do |pattern|
          Dir.glob(File.join(config['base'], pattern)).each do |file|
            opts = config.merge(
              'mode' => mode, 'type' => 'items', 'name' => name
            )
            opts.merge!(data)
            opts['files'] = [file]

            execute(opts)
          end
        end
      end
    end
  end

  def self.execute(opts)
    handler = case opts['type'].to_sym
    when :javascripts then Assets::Javascript
    when :stylesheets then Assets::Stylesheet
    when :images then Assets::Image
    else Assets::Item
    end

    handler = handler.new(opts)
    handler.package
    @ignore << handler.save

    if opts['mode'] == :production
      handler.prepare_deploy
      handler.deploy
    end

    handler.cleanup
  end

end
