require 'Rmagick'

module Sixpack
  module Assets

    class Image < Asset
        
      def package
        FileUtils.cp(@files.first, @tmpfile)

        convert if @opts['convert']
      end

      def prepare_deploy

      end

      private

      def convert
        img = Magick::Image.read(@files.first).first
        opts = @opts
        
        img.write(@tmpfile) do
          self.quality = opts['compress'].to_i
          self.format = opts['convert']
        end
      end

    end
  
  end
end
