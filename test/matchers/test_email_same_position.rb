require_relative '../minitest_helper'

class TestEmailSamePosition < Minitest::Test
  include Matchers

  def setup
  end

  def test_regex_email
    assert_match EmailSamePosition::REGEXP_EMAIL, "a@a.com"
  end

  def test_select_nils_or_emails
    matcher = EmailSamePosition.new
    expected = [nil, "a@a.com", nil, "b@b.com" ]
    result = matcher.select_nils_or_emails ["@.com", "a@a.com", "t@t", "b@b.com"]
    assert_equal expected, result
  end

  def test_identify
    matcher = EmailSamePosition.new
    rows = [
      ["","a@a.com",""],
      ["b@b.com", nil]
    ]
    rows.each{|row| matcher.identify(row) }

    assert_equal 3, matcher.identify(["z@z.com"])
    assert_equal 4, matcher.identify(["a@a.com"])
    assert_equal 1, matcher.identify([nil, "a@a.com", nil])
    assert_equal 1, matcher.identify(["b@b.com", "a@a.com", nil])
    assert_equal 2, matcher.identify(["b@b.com", "c@c.com", nil])
  end
end
