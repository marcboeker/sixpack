require 'zlib'
require 'tmpdir'
require 'tempfile'
require 'fileutils'
require 'digest/sha1'

module Sixpack
  module Assets

    class Stylesheet < Asset
    
      def package
        build({
          compass: ->(src, dest, opts) { Adapters::Compass.compile(src, dest, opts) },
          scss: ->(src, dest, opts) { Sixpack::Assets::Adapters::Sass.compile(src, dest, opts) },
          less: ->(src, dest, opts) { Sixpack::Assets::Adapters::Less.compile(src, dest, opts) }
        })
               
        join
      end

      def prepare_deploy
        minify if @opts['minify']
        gzip if @opts['gzip']
      end

      private
      
      def minify
        run_yui_compressor('css')
      end

      def wrap
        data = File.read(@tmpfile)
        File.open(@tmpfile, 'w') do |fh|
          fh.write("#{@opts['wrap']}{#{data}}")
        end
      end
      
    end

  end
end
