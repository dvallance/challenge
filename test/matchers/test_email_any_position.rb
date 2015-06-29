require_relative '../minitest_helper'

class TestEmailAnyPosition < Minitest::Test
  include Matchers

  def setup
  end

  def test_regex_email
    assert_match EmailAnyPosition::REGEXP_EMAIL, "a@a.com"
  end

  def test_select_all_emails
    matcher = EmailAnyPosition.new
    expected = ["a@a.com", "b@b.com" ]
    result = matcher.select_all_emails ["@.com", "a@a.com", "t@t", "b@b.com"]
    assert_equal expected, result
  end

  def test_identify
    matcher = EmailAnyPosition.new
    rows = [
      ["a@a.com"],
      ["b@b.com"],
      ["c@c.com", "d@d.com"],
      ["e@e.com", "f@f.com", "g@g.com"],
      ["h@h.com", "i@i.com"],
      ["invalid"]
    ]
    rows.each{|row| matcher.identify(row) }

    assert_equal 1, matcher.identify([nil, "a@a.com", nil])
    assert_equal 2, matcher.identify([nil, "b@b.com", nil])
    assert_equal 1, matcher.identify(["h@h.com", "a@a.com"])
    assert_equal 5, matcher.identify(["h@h.com", "i@i.com"])

    # no match will have a new identifier
    assert_equal 7, matcher.identify([nil, nil])
    assert_equal 4, matcher.identify(["f@f.com"])

    # again, no match will have a new identifier
    assert_equal 8, matcher.identify([nil])
  end
end
