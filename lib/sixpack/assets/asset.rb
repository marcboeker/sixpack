module Sixpack

  class Asset

    def initialize(opts)
      @opts = opts
      @tmpfile = File.join(Dir.tmpdir, Time.now.to_i.to_s + opts['name'])
      @opts.merge!('tmpfile' => @tmpfile)

      @files = resolve_files

      Sixpack.log("\n# #{opts['type']}: #{opts['name']}", :red)
    end

    def process_placeholders(placeholders)
      data = File.read(@tmpfile)

      data.gsub!(/\{\{\s*(\w+)\s*(.*)?\}\}/) do |token|
        if variable_name = token.match(/(\w+)/)
          if placeholders.has_key?(variable_name[1])
            placeholders[variable_name[1]]
          end
        end
      end

      File.open(@tmpfile, 'w+') { |f| f.write(data) }
    end

    def package

    end

    def save
      @file = unless @opts['development'].match(/^\//)
        File.join(@opts['base'], @opts['development'])
      else
        @opts['development']
      end

      @file = File.expand_path(@file)

      @opts.merge!('file' => @file)

      FileUtils.cp(@tmpfile, @file)
      Sixpack.log("=> #{@file}", :blue)

      File.realpath(@file)
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
      @files.map do |src|
        Sixpack.log("+ #{src}", :yellow)

        out = src
        mapping.each do |k,v|
          if src.match(/\.#{k}$/)
            hash = make_hash(src, extension_from_type(@opts['type']))
            dest = File.join(Dir.tmpdir, hash)

            if @opts[:force_compile] || !File.exists?(dest)
              v.call(src, dest, @opts)
            end
            out = dest
          end
        end

        files << out
      end

      @files = files
    end

    def extension_from_type(type)
      case(type)
      when 'stylesheets' then 'css'
      when 'javascripts' then 'js'
      end
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
