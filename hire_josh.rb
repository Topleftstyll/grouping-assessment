require 'benchmark'
require_relative 'lib/match_users'

class Search
  attr_reader :file_name, :match_type

  MATCH_TYPES = %w[same_email same_phone same_email_or_phone].freeze
  BASE_FILE_PATH = 'files/'.freeze

  def initialize(match_type, file_name)
    @file_name = file_name
    @match_type = match_type.downcase
  end

  def call
    path = validate_file
    match_type = validate_match_type

    MatchUsers.new(path, match_type).call
  end

  private

  def validate_file
    path = BASE_FILE_PATH + file_name
    return path if File.exist?(path)

    puts "File not found: #{file_name}"
    exit 1
  end

  def validate_match_type
    return match_type if MATCH_TYPES.include?(match_type)

    puts "Invalid Match Type: Available match types are #{MATCH_TYPES.join(', ')}"
    puts "Example: ruby hire_josh.rb same_email input1.csv"
    exit 1
  end
end

puts Benchmark.measure {
  Search.new(ARGV[0], ARGV[1]).call
}
