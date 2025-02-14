class PhoneSanitizer
  def self.sanitize(phone)
    return phone if phone.nil? || phone == ''

    phone = phone.gsub!(/[^0-9]/, '')
    ensure_country_code_present(phone)
  end

  private

  # assuming phone country code is always +1
  def ensure_country_code_present(phone)
    return "1#{phone}" if phone.length == 10
    phone
  end
end
