module Sixpack
  module Assets

    class Item < Asset
        
      def save
        filename = File.basename(@files.first)
        @opts['file'] = @files.first
        @opts['production'] = File.join(@opts['production'], filename)
        
        FileUtils.cp(@opts['file'], @opts['tmpfile'])       
      end

      def prepare_deploy
        gzip if @opts['gzip']
      end

    end

  end
end
