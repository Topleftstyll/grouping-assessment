require 'minitest/autorun'

require_relative '../lib/phone_sanitizer'

class PhoneSanitizerTest < Minitest::Test
  def test_sanitize_returns_phone_number_digits_only
    phone_number = "(123) 456-7890"
    expected = "11234567890"

    assert_equal expected, PhoneSanitizer.sanitize(phone_number)
  end


  def test_sanitize_returns_phone_number_with_assumed_country_code_if_length_is_ten
    phone_number = "1234567890"
    expected = "11234567890"

    assert_equal expected, PhoneSanitizer.sanitize(phone_number)
  end

  def test_sanitize_returns_phone_number
    phone_number = "11234567890"
    expected = "11234567890"
    
    assert_equal expected, PhoneSanitizer.sanitize(phone_number)
  end

  def test_sanitize_returns_empty_string_if_value_is_nil
    assert_equal '', PhoneSanitizer.sanitize(nil)
  end
end
