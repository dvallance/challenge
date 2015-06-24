require_relative 'minitest_helper'

class TestChallenge < Minitest::Test

  # This is the process that would add the identifier column.
  #
  # By default the identifier would be the values of all the columns supplied as
  # the identify_by option, joined with the identifier_join opition.
  #
  # I assume that there would be a csv processing pipline and this is just one
  # part of it?
  #
  # 1. Any indentify_by columns would have had their data standardized. (i.e all
  # phone numbers would be in (xxx-xxx-xxxx)
  # 2. This method would identify rows by there "identity"
  # 3. Further processing where the identity key could be put to good use.
  #
  def csv_processor(cvs_table:, identify_by:, identifier_join: ":", &proc)
    cvs_table.each do |row|
      identifier = nil
      unless row.fields(*Array(identify_by)).any?{|value| value.nil? || value.empty?}
        identifier_value_array = row.fields(*Array(identify_by))
        identifier = proc ? proc.yield(identifier_value_array) : identifier_value_array.join(identifier_join)
       end
      row << ["Identifier", identifier]
    end
    cvs_table.to_csv
  end

  # Here I test that the correct default identifier would be added to a csv
  # The identify_by supplied is Email so its value should be appended to all
  # rows as the Identifier
  #
  def test_csv_processor_with_one_identifier
    csv = <<-STR
FirstName,LastName,Phone,Email,Zip
,,,dave@mymail.com,
,,,rachel@mymail.com,
    STR

    expected = <<-STR
FirstName,LastName,Phone,Email,Zip,Identifier
,,,dave@mymail.com,,dave@mymail.com
,,,rachel@mymail.com,,rachel@mymail.com
    STR

    table = CSV.parse(csv, headers: true)
    result = csv_processor(cvs_table: table, identify_by: "Email")
    assert_equal expected, result
  end

  # Here I test that the correct default identifier would be added to a csv
  # The identify_by supplied is Phone and FirstName so these values should be appended to all
  # rows as the Identifier using the deault join ":"
  #
  def test_csv_processor_with_muiltible_identifiers
    csv = <<-STR
FirstName,LastName,Phone,Email,Zip
David,,111-111-1111,,
Rachel,,222-222-2222,,
    STR

    expected = <<-STR
FirstName,LastName,Phone,Email,Zip,Identifier
David,,111-111-1111,,,111-111-1111:David
Rachel,,222-222-2222,,,222-222-2222:Rachel
    STR

    table = CSV.parse(csv, headers: true)
    result = csv_processor(cvs_table: table, identify_by: ["Phone", "FirstName"])
    assert_equal expected, result
  end

  # Here I test suppling a proc to manipulate the generated Identifier
  # The identify_by supplied is Email and our block simply reverses its value and sets that as the Identifier.
  #
  def test_csv_processor_with_one_identifier_and_provided_proc
    csv = <<-STR
FirstName,LastName,Phone,Email,Zip
,,,dave@mymail.com,
,,,rachel@mymail.com,
    STR

    expected = <<-STR
FirstName,LastName,Phone,Email,Zip,Identifier
,,,dave@mymail.com,,moc.liamym@evad
,,,rachel@mymail.com,,moc.liamym@lehcar
    STR

    table = CSV.parse(csv, headers: true)
    result = csv_processor(cvs_table: table, identify_by: ["Email"]) do |email_value|
      email_value.first.reverse
    end
    assert_equal expected, result
  end

  # Here I test that when values are not provided for identify_by columns then
  # the Identifier cannot be determined and therefore a nil value is used.
  #
  def test_csv_processor_handles_unprocessable_identifiers
    csv = <<-STR
FirstName,LastName,Phone,Email,Zip
Dave,,,dave@mymail.com,
,,,rachel@mymail.com,
    STR

    expected = <<-STR
FirstName,LastName,Phone,Email,Zip,Identifier
Dave,,,dave@mymail.com,,Dave
,,,rachel@mymail.com,,
    STR

    table = CSV.parse(csv, headers: true)
    result = csv_processor(cvs_table: table, identify_by: ["FirstName"])
    assert_equal expected, result
  end
end
