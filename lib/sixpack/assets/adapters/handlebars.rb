module Sixpack
  module Assets
    module Adapters
      module Handlebars

        def self.compile(src, dest, opts = nil)
          io = IO.popen("handlebars #{src}")
          data = io.readlines.join('').gsub('.hbs', '')

          File.open(dest, 'w+') { |fh| fh.write(data) }
        end

      end
    end
  end
end
