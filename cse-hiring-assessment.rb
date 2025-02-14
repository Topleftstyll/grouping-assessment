# This was the original assessment i took for CSE 2 and a half years ago.

require "csv"
require 'securerandom'
require 'benchmark'

arguements = ARGV
if arguements.empty?
    puts "No file name specified"
    exit 1
end

file_name = arguements.last
arguements.pop()

begin
    csv_file = CSV.parse(File.read(file_name), headers: true)
rescue Errno::ENOENT
    puts "#{file_name} could either not be found or not be read."
    exit 1
end

header_values = []
arguements.each do |arg|
    header_values << csv_file.headers.filter { |header| header.downcase.include?(arg.downcase) }
end
header_values = header_values.flatten

header_values.each do |header|
    if (!csv_file.headers.include?(header))
        puts "Header '#{header}' does not exist."
        puts "Available headers are: #{csv_file.headers}"
        exit 1
    end
end


def sanitize_phone(phone)
    return phone if phone.nil? || phone == ''

    strip_non_numerics(phone)
    ensure_country_code_present(phone)
end

def strip_non_numerics(phone)
    phone.gsub!(/[^0-9]/, '')
end

def ensure_country_code_present(phone)
    return "1#{phone}" if phone.length == 10
    phone
end

puts Benchmark.measure {
    # keeps track of the original rows in the original order
    original_records = []
    # array of hashes of each value found by each header
    converted_records = []
    csv_file.each_with_index do |row, i|
        original_record = {
            "row": row.to_h,
            "is_matched": false,
            "uuid": SecureRandom.uuid
        }

        # array of record objects with each value from header
        header_values.each do |header|
            # add converted row
            row_value = row[header]
            if(row_value)
                # remove characters and add country code +1 if header is phone number
                if(header.downcase.include? 'phone')
                    row_value = sanitize_phone(row_value)
                    # update original_record value with sanitized value
                    # comment this out to keep original un-sanitized phone number
                    original_record[:row][header] = row_value
                end

                converted_records << {
                    "value": row_value,
                    "index": i,
                }
            end
        end
        original_records << original_record
    end

    #group converted_records by their value
    grouped_by_headers = converted_records.group_by { |k, v|
        k[:value]
    }

    # loop through each group
    grouped_by_headers.each { |k, v|
        uuid = SecureRandom.uuid

        # sort each group by original_records is matched so that matched values are first in array
        sorted_groups = v.map { |record|
            record_index = record[:index]
            original_records[record_index]
        }.sort_by { |record| record[:is_matched] ? 0 : 1}

        # loop through each sorted record
        sorted_groups.each do |record|
            # if record is matched update uuid to the matched record uuid to use for the rest of the records
            if record[:is_matched]
                uuid = record[:uuid]
                next
            end

            record[:uuid] = uuid

            # if sorted_groups has matches then set is_matched true
            if(sorted_groups.count > 1)
                record[:is_matched] = true
            end
        end
    }

    # add UserId to CSV headers
    csv_headers = csv_file.headers.to_a
    csv_headers.unshift('UserId')

    def merge_record_to_csv(uuid, row)
        new_record = {"UserId": uuid}.merge(row)
        return CSV::Row.new(new_record.keys, new_record.values || "")
    end

    CSV.open("updated_#{file_name}", "w") do |csv|
        csv << csv_headers

        original_records.each do |record|
            csv << merge_record_to_csv(record[:uuid], record[:row])
        end
    end
}

