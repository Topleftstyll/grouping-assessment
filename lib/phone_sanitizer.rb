class PhoneSanitizer
  def self.sanitize(phone)
    phone = phone.to_s.gsub(/[^0-9]/, '')
    return "1#{phone}" if phone.length == 10

    phone
  end
end
