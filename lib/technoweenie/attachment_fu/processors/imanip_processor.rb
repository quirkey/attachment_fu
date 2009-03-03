require 'imanip'

module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Processors
      module ImanipProcessor
        def self.included(base)
          base.send :extend, ClassMethods
          base.alias_method_chain :process_attachment, :processing
        end
        
        module ClassMethods
          # Yields a block containing an RMagick Image for the given binary data.
          def with_image(file, &block)
            begin
              binary_data = file.is_a?(Imanip::Image) ? file : Imanip::Image.new(file) #unless !Object.const_defined?(:Imanip)
            rescue Imanip::NotAnImageError => e
              errors.add_to_base("#{e.message}")
              binary_data = nil
            rescue
              # Log the failure to load the image.  This should match ::Magick::ImageMagickError
              # but that would cause acts_as_attachment to require rmagick.
              logger.debug("Exception working with image: #{$!}")
              binary_data = nil
            end
            block.call binary_data if block && binary_data
          ensure
            !binary_data.nil?
          end
        end

      protected
        def empty_temp_path
           Tempfile.new(random_tempfile_filename, Technoweenie::AttachmentFu.tempfile_path) do |tmp|
             tmp.close
           end.path
         end
      
        def process_attachment_with_processing
          return unless process_attachment_without_processing
          with_image do |img|
            resize_image_or_thumbnail! img
            self.width  = img.width if respond_to?(:width)
            self.height = img.height if respond_to?(:height)
            callback_with_args :after_resize, img
          end if image?
        end
      
        # Performs the actual resizing operation for a thumbnail
        def resize_image(img, size)
          if size.is_a?(Array) && size.length == 1 && !size.first.is_a?(Fixnum)
            size = size.first 
            width, height = size.split('x').collect { |d| d.to_i }
            dimensions = {:width => width, :height => height}
          else
            dimensions = {:dimensions => size}
          end
          new_path = empty_temp_path
          img.crop_resized(new_path, dimensions)
          temp_paths.unshift new_path
        end
      end
    end
  end
end