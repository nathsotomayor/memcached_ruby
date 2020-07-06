require File.expand_path('../../lib/memcached', __FILE__)
require 'minitest/autorun'

class TestMemcached < Minitest::Test
  def setup
    # Create instances to use in test cases
    @memcached = Memcached.new
    @set_example = { command: 'set', key: 'key', flags: '0', ttl: 10, value: 'value' }
    @other_set_example = { command: 'set', key: 'otherkey', flags: '1', ttl: 10, value: 'othervalue' }
    @get_example = { command: 'get', keys: ['key'] }
  end

  def test_set_registry
    # Successful case (STORED)
    res = @memcached.process(@set_example)
    assert_equal("STORED\r\n\n", res)
    res = @memcached.process(@get_example)
    assert_equal("VALUE key 0 \r\nvalue\r\nEND\r\n\n", res)
  end

  def test_add_existing_registry
    # Not successful case (NOT STORED)
    @memcached.process(@set_example)
    add_args = { command: 'add', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(add_args)
    assert_equal("NOT_STORED\r\n\n", res)
  end

  def test_add_unexisting_registry
    # Successful case (STORED)
    add_args = { command: 'add', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(add_args)
    assert_equal("STORED\r\n\n", res)
  end

  def test_append_existing_registry
    # Successful case (STORED)
    @memcached.process(@set_example)
    append_args = { command: 'append', key: 'key', flags: '0', ttl: 1, value: 'other' }
    res = @memcached.process(append_args)
    assert_equal("STORED\r\n\n", res)
    res = @memcached.process(@get_example)
    assert_equal("VALUE key 0 \r\nvalueother\r\nEND\r\n\n", res)
  end

  def test_append_unexisting_registry
    # Not successful case (NOT STORED)
    append_args = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(append_args)
    assert_equal("NOT_STORED\r\n\n", res)
  end

  def test_prepend_existing_registry
    # Successful case (STORED)
    @memcached.process(@set_example)
    prepend_args = { command: 'prepend', key: 'key', flags: '0', ttl: 1, value: 'other' }
    res = @memcached.process(prepend_args)
    assert_equal("STORED\r\n\n", res)
    res = @memcached.process(@get_example)
    assert_equal("VALUE key 0 \r\nothervalue\r\nEND\r\n\n", res)
  end

  def test_prepend_unexisting_registry
    # Not successful case (NOT STORED)
    prepend_args = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(prepend_args)
    assert_equal("NOT_STORED\r\n\n", res)
  end

  def test_replace_existing_registry
    # Successful case (STORED)
    @memcached.process(@set_example)
    replace_args = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(replace_args)
    assert_equal("STORED\r\n\n", res)
  end

  def test_replace_unexisting_registry
    # Not successful case (NOT STORED)
    replace_args = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    res = @memcached.process(replace_args)
    assert_equal("NOT_STORED\r\n\n", res)
  end

  def test_cas_unmodified_registry
    # Successful case (STORED)
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

  def test_cas_modified_registry
    # Not successful case (EXISTS)
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

  def test_cas_registry_without_unique_token
    # Error case (ERROR)
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

  def test_send_wrong_parameters
    # Error case (ERROR)
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

  def test_get_existing_registry
    # Retrieval successful case
    @memcached.process(@set_example)
    res = @memcached.process(@get_example)
    assert_equal("VALUE key 0 \r\nvalue\r\nEND\r\n\n", res)
  end

  def test_get_unexisting_registry
    # Retrieval unsuccessful case (not found - unexisting key)
    res = @memcached.process(@get_example)
    assert_equal("NOT_FOUND\r\n\n", res)
  end

  def test_get_multiple_keys
    # Retrieval successful case
    @memcached.process(@set_example)
    @memcached.process(@other_set_example)
    gets_args = { command: 'get', keys: ['key', 'otherkey'] }
    res = @memcached.process(gets_args)
    assert_equal("VALUE key 0 \r\nvalue\r\nVALUE otherkey 1 \r\nothervalue\r\nEND\r\n\n", res)
  end

  def test_get_cas_registry
    # Case that etrieve values with unique token
    @memcached.process(@set_example)
    object_id = @memcached.storage[@set_example[:key]].object_id
    gets_args = { command: 'gets', keys: ['key'] }
    res = @memcached.process(gets_args)
    assert_equal("VALUE key 0 #{object_id}\r\nvalue\r\nEND\r\n\n", res)
  end
end
