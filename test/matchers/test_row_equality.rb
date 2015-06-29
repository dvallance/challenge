require_relative '../minitest_helper'

class TestRowEquality < Minitest::Test

  include Matchers

  # test that various identifiers are properly assigned using #identify
  def test_identify
    matcher = Matchers::RowEquality.new
    rows = [
      ["a@a.com"],
      ["b@b.com"],
      ["c@c.com", "d@d.com"],
      ["e@e.com", "f@f.com", "g@g.com"],
      ["h@h.com", "i@i.com"],
      [nil]
    ]

    rows.each{|row| matcher.identify(row) }

    assert_equal 1, matcher.identify(["a@a.com"])
    assert_equal 2, matcher.identify(["b@b.com"])
    assert_equal 4, matcher.identify(["e@e.com", "f@f.com", "g@g.com"])
    assert_equal 6, matcher.identify([nil])
    assert_equal 7, matcher.identify([])
  end
end
