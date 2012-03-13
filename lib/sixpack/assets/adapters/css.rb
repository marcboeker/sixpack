module Sixpack
  module Assets
    module Adapters
      module Css

        def self.compile(src, dest, opts = nil)
          FileUtils.cp(src, dest)
        end

      end
    end
  end
end
