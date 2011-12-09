module Sixpack
  module Assets

    class Javascript < Asset
        
      def package
        build(coffee: ->(file) { compile_coffeescript(file) })
        join
      end

      def prepare_deploy
        if @opts['obfuscate']
          obfuscate   
        elsif @opts['minify']
          minify
        end
        
        gzip if @opts['gzip']
      end

      private

      def compile_coffeescript(file)
        hash = make_hash(file, 'js')
        dest = File.join(Dir.tmpdir, hash)
        
        unless File.exists?(dest)
          system("coffee -cbp #{file} > #{dest}")
        end

        dest
      end
  
      def minify
        run_yui_compressor(false)
      end

      def obfuscate
        run_yui_compressor
      end
      
    end
  
  end
end
