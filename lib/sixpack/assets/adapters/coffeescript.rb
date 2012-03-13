module Sixpack
  module Assets
    module Adapters
      module Coffeescript

        def self.compile(src, dest, opts = nil)
          system("coffee -cbp #{src} > #{dest}")
        end

      end
    end
  end
end
