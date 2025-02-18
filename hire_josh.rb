#!/usr/bin/env ruby
require 'optparse'
require 'benchmark'

require_relative './lib/search'

class HireJoshCLI
  def initialize(argv)
    @argv = argv
    @options = {}
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: ruby hire_josh.rb -f FILE -m MATCH_TYPE"

      opts.on("-m MATCH", "--match MATCH_TYPE", "Specify the match type (same_email, same_phone, same_email_or_phone)") do |match|
        @options[:match] = match
      end

      opts.on("-f FILE", "--file FILE", "Specify the CSV input file") do |file|
        @options[:file] = file
      end

      opts.on("-h", "--help", "Prints this help message") do
        puts opts
        exit
      end
    end.parse!(@argv)
  end

  def validate_options_are_present
    if @options[:file].nil? || @options[:match].nil?
      puts "Error: Both -f (file) and -m (match type) are required. Add -h for more information."
      exit
    end
  end

  def run
    parse_options
    validate_options_are_present

    puts Benchmark.measure {
      Search.new(@options[:match], @options[:file]).call
    }

    puts "Matching process completed. Output saved to output.csv."
  end
end

HireJoshCLI.new(ARGV).run
