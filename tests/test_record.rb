require File.expand_path('../../lib/memcached/record', __FILE__)
require 'minitest/autorun'


class TestRecord < Minitest::Test
  def setup
    # Create an instance to use in test cases
    @record = Record.new(value: 'value', flags: '1', ttl: 1)
  end

  def test_append_registry
    @record.append_value('example')
    assert_equal('valueexample', @record.value)
  end

  def test_prepend_registry
    @record.prepend_value('example')
    assert_equal('examplevalue', @record.value)
  end

  def test_replace_registry
    @record.replace_value(value: 'newvalue', flags: '3', ttl: 0)
    assert_equal('newvalue', @record.value)
    assert_equal('3', @record.flags)
  end

  def test_expired_registry
    assert !@record.expired?
    sleep 1
    assert @record.expired?
  end

  def test_not_expired_registry
    record = Record.new(value: 'value', flags: '1', ttl: 0)
    sleep 1
    assert !record.expired?
  end
end
