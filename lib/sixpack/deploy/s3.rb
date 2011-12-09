require 'aws-sdk'
require 'mime/types'

module Sixpack
  module Deploy

    class S3

      def initialize(opts)
        @opts = opts
        @uri = URI.parse(@opts['production'])
      end

      def deploy
        connect
        upload
      end

      private

      def connect
        @con = AWS::S3.new({
          access_key_id: @opts['s3_access_key_id'], 
          secret_access_key: @opts['s3_secret_access_key']
        })
      end

      def key
        @uri.path[1..-1]
      end

      def bucket
        @uri.hostname
      end

      def content_type
        MIME::Types.type_for(@opts['file']).first.content_type
      end

      def content_encoding
        @opts['gzip'] ? 'gzip' : nil
      end

      def upload
        @con.buckets[bucket].objects[key].write({
          data: File.read(@opts['tmpfile']),
          content_type: content_type,
          content_encoding: content_encoding,
          acl: :public_read
        })
      end

    end

  end
end