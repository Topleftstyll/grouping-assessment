require 'securerandom'
require "csv"
require_relative 'phone_sanitizer'
require_relative 'union_find'

class MatchUsers
  attr_reader :csv_data, :matching_headers, :union_find
  attr_accessor :groups

  def initialize(path, match_type)
    @csv_data = CSV.parse(File.read(path), headers: true)
    @matching_headers = headers_by_match_type(match_type)
    @union_find = UnionFind.new
    @groups = {}
  end

  def call
    header_to_indices.each_value do |indices|
      first = indices.first
      indices.each { |idx| union_find.union(first, idx) }
    end

    csv_data.each_with_index do |row, i|
      group_id = union_find.find(i)
      groups[group_id] ||= SecureRandom.uuid
      row['ID'] = groups[group_id]
    end

    output_to_csv
  end

  private

  def output_to_csv
    CSV.open('output.csv', 'w') do |csv|
      new_headers = ['ID'] + (csv_data.headers - ['ID'])
      csv << new_headers

      csv_data.each do |row|
        new_row = new_headers.map { |header| row[header] }
        csv << new_row
      end
    end
  end

  def header_to_indices
    hash = Hash.new { |hash, key| hash[key] = [] }

    csv_data.each_with_index do |row, index|
      matching_headers.each do |header|
        value = row[header]
        next if value.nil? || value.empty?

        if header.downcase.include?('phone')
          value = PhoneSanitizer.sanitize(value)
        end

        hash[value] << index
      end
    end

    hash
  end

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
