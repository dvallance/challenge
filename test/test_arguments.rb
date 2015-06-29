require_relative 'minitest_helper'

class TestArguments < Minitest::Test

  def test_input_accessor
    expected = "/test_path"
    Arguments.instance.input = expected
    assert_equal expected, Arguments.instance.input
  end

  def test_output_accessor
    expected = "/test_path"
    Arguments.instance.output = expected
    assert_equal expected, Arguments.instance.output
  end

  def test_output_matcher
    expected = Class.new #assign a new anonymous class
    Arguments.instance.matcher = expected
    assert_equal expected, Arguments.instance.matcher
  end

  def test_verify_with_nil_input
    Arguments.instance.input = nil
    assert_raises(ArgumentError) do
      Arguments.instance.verify!
    end
  end

  def test_verify_with_non_existing_file
    Arguments.instance.input = "./test/data/NOT_THERE.csv"
    assert_raises(ArgumentError) do
      Arguments.instance.verify!
    end
  end

  def test_verify_with_existing_file
    Arguments.instance.input = "./test/data/input1.csv"
    assert_nil Arguments.instance.verify!
  end

  def test_parse_minimum_valid_arguments
    expected = "./test/data/input1.csv"
    Arguments.parse [expected]
    assert_equal expected, Arguments.instance.input
  end

end
