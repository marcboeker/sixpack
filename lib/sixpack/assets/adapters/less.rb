module Sixpack
  module Assets
    module Adapters
      module Less

        def self.compile(src, dest, opts = nil)
          system("lessc #{src} > #{dest}")
        end

      end
    end
  end
end
