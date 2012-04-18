module Sixpack
  module Assets

    class Javascript < Asset

      def package
        build({
          coffee: ->(src, dest, opts) { Adapters::Coffeescript.compile(src, dest, opts) },
          js: ->(src, dest, opts) { Adapters::Js.compile(src, dest, opts) },
          hbs: ->(src, dest, opts) { Adapters::Handlebars.compile(src, dest, opts) }
        })

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

      def minify
        run_yui_compressor('js', false)
      end

      def obfuscate
        run_yui_compressor('js')
      end

    end

  end
end
