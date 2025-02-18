require 'securerandom'
require "csv"

require_relative 'phone_sanitizer'
require_relative 'email_sanitizer'
require_relative 'union_find'

class MatchUsers
  attr_reader :csv_data, :matching_headers, :union_find, :groups

  def initialize(path, match_type)
    @csv_data = CSV.parse(File.read(path), headers: true)
    @matching_headers = headers_by_match_type(match_type)
    @union_find = UnionFind.new
    @groups = {}
  end

  def call
    value_to_indices.each_value do |indices|
      first = indices.first
      indices.each { |index| union_find.union(first, index) }
    end

    csv_data.each_with_index do |row, index|
      # Finalize path compression and grab finalized root parent
      root_parent = union_find.find(index)

      # Grab UUID from groups hash if the root_parent is the same if not, generate a new UUID
      groups[root_parent] ||= SecureRandom.uuid
      row['ID'] = groups[root_parent]
    end

    output_to_csv
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

  # Returns a hash where the key is a row value from the csv
  # and the value is an array of indeces that match that row value
  # ex: { '14165555555' => [2, 6] }
  def value_to_indices
    hash = Hash.new { |hash, key| hash[key] = [] }

    csv_data.each_with_index do |row, index|
      matching_headers.each do |header|
        value = row[header]
        next if value.nil? || value.empty?

        value = PhoneSanitizer.sanitize(value) if header.downcase.include?('phone')
        value = EmailSanitizer.sanitize(value) if header.downcase.include?('email')

        hash[value] << index
      end
    end

    hash
  end

  def output_to_csv
    # TODO: make a folder to store outputs and use timestamp + filename to generate output file name
    CSV.open('output.csv', 'w') do |csv|
      # Prepend ID to the headers
      new_headers = ['ID'] + (csv_data.headers - ['ID'])
      csv << new_headers

      csv_data.each do |row|
        new_row = new_headers.map { |header| row[header] }
        csv << new_row
      end
    end
  end
end
