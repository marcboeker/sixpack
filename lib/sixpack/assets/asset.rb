module Sixpack

  class Asset
    
    def initialize(opts)
      @opts = opts
      @tmpfile = File.join(Dir.tmpdir, Time.now.to_i.to_s + opts['name'])
      @opts.merge!('tmpfile' => @tmpfile)

      @files = resolve_files

      Sixpack.log("\n# #{opts['type']}: #{opts['name']}", :red)
    end

    def package

    end

    def save
      @file = unless @opts['development'].match(/^\//)
        File.join(@opts['base'], @opts['development'])
      else
        @opts['development']
      end

      @opts.merge!('file' => @file)

      FileUtils.cp(@tmpfile, @file)
      Sixpack.log("=> #{@file}", :blue)

      @file
    end

    def prepare_deploy

    end

    def deploy
      handler = Deploy::Handler.new(@opts)
      handler.deploy
    end

    def cleanup
      File.unlink(@tmpfile)
    end

    private

    def build(mapping)
      files = []
      @files.map do |file|
        Sixpack.log("+ #{file}", :yellow)

        out = file
        mapping.each do |k,v|
          if file.match(/\.#{k}$/)
            out = v.call(file)
          end
        end
          
        files << out
      end

      @files = files
    end

    def resolve_files
      files = []
      @opts['files'].each do |pattern|
        path = if pattern.match(/^\//)
          pattern
        else
          File.join(@opts['base'], pattern)
        end

        files += Dir.glob(path)
      end

      files
    end

    def run_yui_compressor(type, munge = false)
      munge = munge ? '' : '--nomunge'
      path = File.expand_path(File.dirname(__FILE__))
      path = File.expand_path(path + '/../../../ext/yuicompressor-2.4.7.jar')

      system("java -jar #{path} #{munge} --type #{type} #{@tmpfile} -o #{@tmpfile}")
    end

    def make_hash(file, ext)
      hash = "#{file}:#{File.mtime(file)}"
      
      "#{Digest::SHA1.hexdigest(hash)}.#{ext}"
    end

    def gzip
      data = File.read(@tmpfile)
      File.unlink(@tmpfile)

      Zlib::GzipWriter.open(@tmpfile) do |gz|
        gz.write(data)
      end
    end
    
    def join
      File.open(@tmpfile, 'w+') do |fh|
        @files.each { |file| fh.write(File.read(file) + "\n") }
        fh.flush
      end
    end
    
  end

end