require 'zlib'
require 'tmpdir'
require 'tempfile'
require 'fileutils'
require 'digest/sha1'

module Sixpack
  module Assets

    class Stylesheet < Asset
    
      def package
        if @opts['compass']
          compile_compass
        else
          build(scss: ->(file) { compile_scss(file) })
        end
               
        join
      end

      def prepare_deploy
        minify if @opts['minify']
        gzip if @opts['gzip']
      end

      private
      
      def compile_scss(file)
        hash = make_hash(file, 'css')
        dest = File.join(Dir.tmpdir, hash)
        
        unless File.exists?(dest)
          system("scss #{file}:#{dest}")
        end
        
        dest
      end

      def compile_compass
        compass = File.join(@opts['base'], @opts['compass'])
        hash = make_hash(compass, 'compass')
        dest = File.join(Dir.tmpdir, hash)        
        
        system("compass compile #{compass} --css-dir #{dest} -q")
        
        @files = Dir.glob("#{dest}/*")
      end

      def minify
        run_yui_compressor
      end
      
    end

  end
end
