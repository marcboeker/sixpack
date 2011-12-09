module Sixpack

  module Deploy

    class Handler

      def initialize(opts)
        @opts = opts.dup
      end

      def deploy
        handler = case @opts['production']
        when /^s3:\/\// then S3
        else File
        end

        handler = handler.new(@opts)
        handler.deploy

        Sixpack.log("Deployed to #{@opts['production']}", :green)
      end

    end
  
  end

end