require 'securerandom'
require_relative 'phone_sanitizer'
require "csv"

class MatchUsers
  attr_reader :csv_data, :matching_headers

  def initialize(path, match_type)
    @csv_data = CSV.parse(File.read(path), headers: true)
    @matching_headers = headers_by_match_type(match_type)
  end

  def call
    csv_data.each_with_index do |row, index|

    end
  end

  private

  def headers_by_match_type(match_type)
    case match_type
    when 'same_email'
      same_email
    when 'same_phone'
      same_phone
    when 'same_email_or_phone'
      same_email_or_phone
    end
  end

  def same_email
    csv_data.headers.filter { _1.downcase.include?('email') }
  end

  def same_phone
    csv_data.headers.filter { _1.downcase.include?('phone') }
  end

  def same_email_or_phone
    same_email + same_phone
  end
end
