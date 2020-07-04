require File.expand_path('../../lib/memcached/record', __FILE__)
require 'test/unit'

class RecordTest < Test::Unit::TestCase
  def setup
    @record = Record.new(value: 'value', flags: '1', ttl: 1)
  end

  def test_record_append
    @record.append_value('example')
    assert_equal('valueexample', @record.value)
  end

  def test_record_prepend
    @record.prepend_value('example')
    assert_equal('examplevalue', @record.value)
  end

  def test_record_replace
    @record.replace_value(value: 'newvalue', flags: '3', ttl: 0)
    assert_equal('newvalue', @record.value)
    assert_equal('3', @record.flags)
  end

  def test_record_expired
    assert !@record.expired?
    sleep 1
    assert @record.expired?
  end

  def test_record_not_expired
    record = Record.new(value: 'value', flags: '1', ttl: 0)
    sleep 1
    assert !record.expired?
  end
end
