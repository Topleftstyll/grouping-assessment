require 'minitest/autorun'
require 'csv'
require 'securerandom'

require_relative '../lib/match_users'
require_relative '../lib/phone_sanitizer'
require_relative '../lib/email_sanitizer'
require_relative '../lib/union_find'

class MatchUsersTest < Minitest::Test
  CSV_DATA = <<~CSV
    FirstName,LastName,Phone1,Phone2,Email1,Email2,Zip
    John,Doe,(555) 123-4567,(555) 987-6543,johnd@home.com,,94105
    Jane,Doe,(555) 123-4567,(555) 654-9873,janed@home.com,johnd@home.com,94105
    Jack,Doe,(444) 123-4567,(555) 654-9873,jackd@home.com,,94109
    John,Doe,(555) 123-4567,(555) 987-6543,jackd@home.com,,94105
    Josh,Doe,(456) 789-0123,,joshd@home.com,jackd@home.com,94109
    Jill,Doe,(654) 987-1234,,jill@home.com,,94129
  CSV

  def setup
    @temp_file = "temp_test.csv"
    File.write(@temp_file, CSV_DATA)
  end

  def teardown
    output_file = "output/#{Time.now.to_i}_#{@temp_file}"
    File.delete(output_file) if File.exist?(output_file)
    File.delete(@temp_file) if File.exist?(@temp_file)
  end

  def test_output_file_has_new_ID_header
    match_users = MatchUsers.new(@temp_file, "same_email_or_phone")
    match_users.call

    output_file = "output/#{Time.now.to_i}_#{@temp_file}"
    output_csv = CSV.read(output_file, headers: true)
    expected_headers = ['ID'] + (match_users.csv_data.headers - ['ID'])

    assert_equal expected_headers, output_csv.headers
  end

  def test_output_file_matches_csv_data
    match_users = MatchUsers.new(@temp_file, "same_email")
    match_users.call

    output_file = "output/#{Time.now.to_i}_#{@temp_file}"
    output_csv = CSV.read(output_file, headers: true)
    expected_headers = ['ID'] + (match_users.csv_data.headers - ['ID'])

    match_users.csv_data.each_with_index do |row, index|
      expected_row = expected_headers.map { |header| row[header] }
      actual_row = expected_headers.map { |header| output_csv[index][header] }
      assert_equal expected_row, actual_row
    end
  end

  def test_output_file_matches_csv_data
    match_users = MatchUsers.new(@temp_file, "same_phone")
    match_users.call

    output_file = "output/#{Time.now.to_i}_#{@temp_file}"
    output_csv = CSV.read(output_file, headers: true)
    expected_headers = ['ID'] + (match_users.csv_data.headers - ['ID'])

    match_users.csv_data.each_with_index do |row, index|
      expected_row = expected_headers.map { |header| row[header] }
      actual_row = expected_headers.map { |header| output_csv[index][header] }
      assert_equal expected_row, actual_row
    end
  end

  def test_output_file_matches_csv_data
    match_users = MatchUsers.new(@temp_file, "same_email_or_phone")
    match_users.call

    output_file = "output/#{Time.now.to_i}_#{@temp_file}"
    output_csv = CSV.read(output_file, headers: true)
    expected_headers = ['ID'] + (match_users.csv_data.headers - ['ID'])

    match_users.csv_data.each_with_index do |row, index|
      expected_row = expected_headers.map { |header| row[header] }
      actual_row = expected_headers.map { |header| output_csv[index][header] }
      assert_equal expected_row, actual_row
    end
  end
end
