module Sixpack
  module Assets
    module Adapters
      module Js

        def self.compile(src, dest, opts = nil)
          FileUtils.cp(src, dest)
        end

      end
    end
  end
end
