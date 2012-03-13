module Sixpack
  module Assets
    module Adapters
      module Sass

        def self.compile(src, dest, opts = nil)
          system("scss #{src}:#{dest}")
        end

      end
    end
  end
end
