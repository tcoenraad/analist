# frozen_string_literal: true

module Analist
  module FileFinder
    RUBY_EXTENSIONS = %w[.rb].freeze

    module_function

    def find(args)
      return target_files_in_dir if args.empty?

      files = []

      args.uniq.each do |arg|
        if File.directory?(arg)
          files += target_files_in_dir(arg.chomp(File::SEPARATOR))
        elsif ruby_file?(arg)
          files << arg
        end
      end

      files.map { |f| File.expand_path(f) }.uniq
    end

    def target_files_in_dir(base_dir = Dir.pwd)
      pattern = ["#{base_dir}/**/*"]
      Dir.glob(pattern).select { |file| ruby_file?(file) }
    end

    def ruby_extension?(file)
      RUBY_EXTENSIONS.include?(File.extname(file))
    end

    def ruby_file?(file)
      ruby_extension?(file)
    end

    # Taken from https://github.com/bbatsov/rubocop/blob/e9aab79b6f0abe16bfd8fff2a097d8a017717aa7/lib/rubocop/path_util.rb#L8
    def relative_path(path)
      base_dir = Dir.pwd

      return path[(base_dir.length + 1)..-1] if path.start_with?(base_dir)

      path_name = Pathname.new(File.expand_path(path))
      path_name.relative_path_from(Pathname.new(base_dir)).to_s
    end
  end
end
