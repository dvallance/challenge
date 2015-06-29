require_relative 'minitest_helper'

class TestCSVProcessor < Minitest::Test

  # Helping method to read the generated csv as a string.
  def read_tmp_file
    file = File.open("./test/data/tmp.csv", "r")
    file.read
  end

  # A nil value for matcher should result in a default.
  def test_determine_matcher_default
    assert_instance_of Matchers::RowEquality, CSVProcessor.determine_matcher(nil)
  end

  # A nil value for output should result in a default.
  def test_determine_output_default
    processor = CSVProcessor.determine_output(nil)
    assert_respond_to processor, :<<
    assert_respond_to processor, :close
  end

  #TODO testing agaist STDOUT (the default) is problematic as minitest itself
  # does STDOUT manipulation. So I'm testing against a tmp output file until I
  # know what the exact issue is.
  #
  # Test that a the process indeed completes, and works with the default matcher.
  def test_run
    CSVProcessor.run(input: './test/data/duplicates.csv', output: './test/data/tmp.csv')

    expected = <<-EOS
Identifier,Header1,Header2,Header3
1,a,a,a
2,b,b,b
1,a,a,a
2,b,b,b
3,c,c,c
1,a,a,a
2,b,b,b
3,c,c,c
4,d,d,d
EOS
    assert_equal expected, read_tmp_file
  end

  # Quick output of the memory and speed for the different matchers over a big
  # csv file.
  def test_lets_see_memory_and_speed_stats_for_a_big_csv_row_equality
    Utils.display_speed_and_memory_usage("input3.csv", "RowEquality")  do
      CSVProcessor.run(input: './test/data/input3.csv', output: './test/data/tmp.csv')
    end
  end

  def test_lets_see_memory_and_speed_stats_for_a_big_csv_email_any_position
    Utils.display_speed_and_memory_usage("input3.csv","EmailAnyPosition") do
      CSVProcessor.run(input: './test/data/input3.csv', output: './test/data/tmp.csv', matcher: "EmailAnyPosition")
    end
  end

  def test_lets_see_memory_and_speed_stats_for_a_big_csv_email_same_position
    Utils.display_speed_and_memory_usage("input3.csv","EmailSamePosition") do
      CSVProcessor.run(input: './test/data/input3.csv', output: './test/data/tmp.csv', matcher: "EmailSamePosition")
    end
  end
end
