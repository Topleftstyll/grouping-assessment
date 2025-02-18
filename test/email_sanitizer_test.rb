require 'minitest/autorun'

require_relative '../lib/email_sanitizer'

class PhoneSanitizerTest < Minitest::Test
  def test_sanitize_returns_email_without_extra_spaces
    email = "   hire_josh@test.com   "
    expected = "hire_josh@test.com"

    assert_equal expected, EmailSanitizer.sanitize(email)
  end

  def test_sanitize_returns_email_in_all_lowercase_case
    email = "HiRe_JoSh@test.com"
    expected = "hire_josh@test.com"
    
    assert_equal expected, EmailSanitizer.sanitize(email)
  end

  def test_sanitize_returns_empty_string_if_value_is_nil
    assert_equal '', EmailSanitizer.sanitize(nil)
  end
end
