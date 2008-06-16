require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class ImanipTest < Test::Unit::TestCase
  attachment_model ImanipAttachment

  if Object.const_defined?(:Imanip)
    def test_should_resize_image
      attachment = upload_file :filename => '/files/rails.png'
      assert_valid attachment
      assert attachment.image?
      assert_equal 50, attachment.width
      assert_equal 64, attachment.height
      
      assert_equal 2, attachment.thumbnails.count
    end
  else
    def test_flunk
      puts "Imanip not loaded, tests not running"
    end
  end

end