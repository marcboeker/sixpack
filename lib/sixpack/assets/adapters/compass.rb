module Sixpack
  module Assets
    module Adapters
      module Compass
        
        def self.compile(src, dest, opts)
          compass = File.join(@opts['base'], @opts['compass'])

          system("compass compile #{compass} --css-dir #{dest} -q")
        end

      end
    end
  end
end
