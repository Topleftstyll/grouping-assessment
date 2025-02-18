class EmailSanitizer
  def self.sanitize(email)
    email.to_s.strip.downcase
  end
end
