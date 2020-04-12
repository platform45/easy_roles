# frozen_string_literal: true

module EasyRoles
  # Helper module for file generators
  module InstallGeneratorHelpers
    class << self
      def included(mod)
        mod.class_eval do
          source_root File.expand_path('templates', __dir__)

          private

          def parse_file_for_line(filename, str)
            match = false

            File.open(File.join(destination_root, filename)) do |f|
              f.each_line do |line|
                match = line if line =~ /(#{Regexp.escape(str)})/mi
              end
            end
            match
          end
        end
      end
    end
  end
end
