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
    File.delete(@temp_file) if File.exist?(@temp_file)

    output_file = "output/#{Time.now.to_i}_#{@temp_file}"
    File.delete(output_file) if File.exist?(output_file)
  end

  # Override output_to_csv so that we don't write a file during tests
  def override_output_to_csv(match_users)
    def match_users.output_to_csv
    end
  end

  def test_call_with_same_phone_match_type_assigns_the_same_ids
    match_users = MatchUsers.new(@temp_file, "same_phone")
    override_output_to_csv(match_users)
    match_users.call

    # All rows should now have an 'ID' column.
    data = match_users.csv_data

    # Rows 0 and 1 share the same sanitized phone ("11234567890")
    id1 = data[0]['ID']
    id2 = data[1]['ID']

    assert_equal id1, id2
  end

  def test_call_with_different_phone_match_type_assigns_the_same_ids
    match_users = MatchUsers.new(@temp_file, "same_phone")
    override_output_to_csv(match_users)
    match_users.call

    # All rows should now have an 'ID' column.
    data = match_users.csv_data

    # Rows 0 and 5 have different sanitized phone numbers
    id1 = data[0]['ID']
    id2 = data[5]['ID']

    refute_equal id1, id2
  end

  def test_call_with_same_email_match_type_assigns_the_same_ids
    match_users = MatchUsers.new(@temp_file, "same_email")
    override_output_to_csv(match_users)
    match_users.call

    # All rows should now have an 'ID' column.
    data = match_users.csv_data

    # Rows 0 and 1 share the same sanitized email ("johnd@home.com")
    id1 = data[2]['ID']
    id2 = data[3]['ID']

    assert_equal id1, id2
  end

  def test_call_with_different_email_match_type_assigns_the_same_ids
    match_users = MatchUsers.new(@temp_file, "same_email")
    override_output_to_csv(match_users)
    match_users.call

    # All rows should now have an 'ID' column.
    data = match_users.csv_data

    # Rows 0 and 5 have different sanitized emails
    id1 = data[0]['ID']
    id2 = data[5]['ID']

    refute_equal id1, id2
  end

  def test_call_with_same_email_or_phone_match_type_assigns_the_same_ids
    match_users = MatchUsers.new(@temp_file, "same_email_or_phone")
    override_output_to_csv(match_users)
    match_users.call

    data = match_users.csv_data

    # For this test data:
    # - Rows 0, 1 and 4 share the same sanitized phone number ("15551234567")
    # - Rows 0 and 3 share the same sanitized phone number ("15559876543")"
    # - Rows 0 and 1 share the same sanitized email ("johnd@home.com")
    # - rows 2, 3 and 4 share the same sanitized email ("jackd@home.com")
    # Because of the above, 0-4 should all have the same ID and 5 should be unique
    id1 = data[0]['ID']
    id2 = data[1]['ID']
    id3 = data[2]['ID']
    id4 = data[3]['ID']
    id5 = data[4]['ID']
    id5 = data[5]['ID']

    assert_equal id1, id2
    assert_equal id1, id3
    assert_equal id1, id4
    refute_equal id1, id5
  end

  def test_output_file_matches_csv_data
    match_users = MatchUsers.new(@temp_file, "same_email_or_phone")
    match_users.call

    output_file = "output/#{Time.now.to_i}_#{@temp_file}"
    output_csv = CSV.read(output_file, headers: true)
    expected_headers = ['ID'] + (match_users.csv_data.headers - ['ID'])

    assert_equal expected_headers, output_csv.headers
    match_users.csv_data.each_with_index do |row, index|
      expected_row = expected_headers.map { |header| row[header] }
      actual_row   = expected_headers.map { |header| output_csv[index][header] }
      assert_equal expected_row, actual_row
    end
  end
end
