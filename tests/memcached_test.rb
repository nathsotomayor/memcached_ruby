require File.expand_path('../../lib/memcached', __FILE__)
require 'test/unit'

class MemcachedTest < Test::Unit::TestCase
  def setup
    @memcached = Memcached.new
    @set_example = { command: 'set', key: 'key', flags: '0', ttl: 10, value: 'value' }
    @other_set_example = { command: 'set', key: 'otherkey', flags: '1', ttl: 10, value: 'othervalue' }
    @get_example = { command: 'get', keys: ['key'] }
  end

  def test_setting_record_returns_stored
    res = @memcached.process(@set_example)
    assert_equal("STORED\r\n\n", res)
    res = @memcached.process(@get_example)
    assert_equal("VALUE key 0 \r\nvalue\r\nEND\r\n\n", res)
  end

  def test_adding_existing_record_returns_not_stored
    @memcached.process(@set_example)
    add_args = { command: 'add', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(add_args)
    assert_equal("NOT_STORED\r\n\n", res)
  end

  def test_adding_unexisting_record_returns_stored
    add_args = { command: 'add', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(add_args)
    assert_equal("STORED\r\n\n", res)
  end

  def test_appending_existing_record_returns_stored
    @memcached.process(@set_example)
    append_args = { command: 'append', key: 'key', flags: '0', ttl: 1, value: 'other' }
    res = @memcached.process(append_args)
    assert_equal("STORED\r\n\n", res)
    res = @memcached.process(@get_example)
    assert_equal("VALUE key 0 \r\nvalueother\r\nEND\r\n\n", res)
  end

  def test_appending_unexisting_record_returns_not_stored
    append_args = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(append_args)
    assert_equal("NOT_STORED\r\n\n", res)
  end

  def test_replacing_existing_record_returns_stored
    @memcached.process(@set_example)
    replace_args = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(replace_args)
    assert_equal("STORED\r\n\n", res)
  end

  def test_replacing_unexisting_record_returns_not_stored
    replace_args = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(replace_args)
    assert_equal("NOT_STORED\r\n\n", res)
  end


  def test_prepending_existing_record_returns_stored
    @memcached.process(@set_example)
    prepend_args = { command: 'prepend', key: 'key', flags: '0', ttl: 1, value: 'other' }
    res = @memcached.process(prepend_args)
    assert_equal("STORED\r\n\n", res)
    res = @memcached.process(@get_example)
    assert_equal("VALUE key 0 \r\nothervalue\r\nEND\r\n\n", res)
  end

  def test_prepending_unexisting_record_returns_not_stored
    prepend_args = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(prepend_args)
    assert_equal("NOT_STORED\r\n\n", res)
  end

  def test_casing_unmodified_record_returns_stored
    @memcached.process(@set_example)
    object_id = @memcached.storage[@set_example[:key]].object_id
    cas_args = {
      command: 'cas',
      key: 'key',
      flags: '0',
      ttl: 1,
      value: 'other',
      unique_cas_token: object_id,
      fetched_records_time: { key: Time.now }
    }
    res = @memcached.process(cas_args)
    assert_equal("STORED\r\n\n", res)
  end

  def test_casing_modified_record_returns_exists
    @memcached.process(@set_example)

    time_before_updating = Time.now
    append_args = { command: 'append', key: 'key', flags: '0', ttl: 1, value: 'other' }
    @memcached.process(append_args)

    object_id = @memcached.storage[@set_example[:key]].object_id
    cas_args = {
      command: 'cas',
      key: 'key',
      flags: '0',
      ttl: 1,
      value: 'other',
      unique_cas_token: object_id,
      fetched_records_time: { key: time_before_updating }
    }
    res = @memcached.process(cas_args)
    assert_equal("EXISTS\r\n\n", res)
  end

  def test_casing_record_without_unique_token_returns_error
    cas_args = {
      command: 'cas',
      key: 'key',
      flags: '0',
      ttl: 1,
      value: 'other',
      fetched_records_time: { key: Time.now }
    }
    res = @memcached.process(cas_args)
    assert_equal("ERROR\r\n\n", res)
  end

  def test_sending_wrong_parameters_returns_error
    wrong_args = {
      command: 'wrong_command',
      key: 'errorkey',
      flags: '',
      ttl: 1,
      value: 'errorvalue'
    }
    res = @memcached.process(wrong_args)
    assert_equal("ERROR\r\n\n", res)
  end

  def test_getting_existing_record_returns_value
    @memcached.process(@set_example)
    res = @memcached.process(@get_example)
    assert_equal("VALUE key 0 \r\nvalue\r\nEND\r\n\n", res)
  end

  def test_getting_unexisting_record_returns_not_found
    res = @memcached.process(@get_example)
    assert_equal("NOT_FOUND\r\n\n", res)
  end

  def test_getting_multiple_keys_returns_values
    @memcached.process(@set_example)
    @memcached.process(@other_set_example)
    gets_args = { command: 'get', keys: ['key', 'otherkey'] }
    res = @memcached.process(gets_args)
    assert_equal("VALUE key 0 \r\nvalue\r\nVALUE otherkey 1 \r\nothervalue\r\nEND\r\n\n", res)
  end

  def test_getting_cas_record_returns_values_with_unique_token
    @memcached.process(@set_example)
    object_id = @memcached.storage[@set_example[:key]].object_id
    gets_args = { command: 'gets', keys: ['key'] }
    res = @memcached.process(gets_args)
    assert_equal("VALUE key 0 #{object_id}\r\nvalue\r\nEND\r\n\n", res)
  end
end
