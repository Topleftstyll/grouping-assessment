require 'minitest/autorun'

require_relative '../lib/search'

class SearchTest < Minitest::Test
  def setup
    @valid_file = "valid.csv"
    @invalid_file = "nonexistent.csv"
    @valid_match_type = "SaMe_EmAiL"
    @invalid_match_type = "invalid_type"
  end

  def test_call_exits_when_file_not_found
    File.stub(:exist?, false) do
      search = Search.new(@valid_match_type, @invalid_file)

      assert_raises(SystemExit) { search.call }
    end
  end

  def test_call_exits_when_invalid_match_type
    File.stub(:exist?, true) do
      search = Search.new(@invalid_match_type, @valid_file)
      
      assert_raises(SystemExit) { search.call }
    end
  end

  def test_call_with_valid_params
    match_users_mock = Minitest::Mock.new
    match_users_mock.expect(:call, true)

    MatchUsers.stub(:new, ->(match_type, file_name) { match_users_mock }) do
      File.stub(:exist?, true) do
        search = Search.new(@valid_match_type, @valid_file)
        search.call
      end
    end

    match_users_mock.verify
  end
end
