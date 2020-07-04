require File.expand_path('../../lib/memcached/request_parser', __FILE__)
require 'test/unit'

class RequestParserTest < Test::Unit::TestCase
  def test_set_parse
    petition = "set key 1 100\r\nvalue"
    args = RequestParser.parse(petition)
    assert_equal('set', args[:command])
    assert_equal('key', args[:key])
    assert_equal('1', args[:flags])
    assert_equal(100, args[:ttl])
    assert_equal('value', args[:value])
  end

  def test_add_parse
    petition = "add new_key 1 100\r\nnew_value"
    args = RequestParser.parse(petition)
    assert_equal('add', args[:command])
    assert_equal('new_key', args[:key])
    assert_equal('1', args[:flags])
    assert_equal(100, args[:ttl])
    assert_equal('new_value', args[:value])
  end

  def test_append_parse
    petition = "append greeting 1 100\r\nWorld"
    args = RequestParser.parse(petition)
    assert_equal('append', args[:command])
    assert_equal('greeting', args[:key])
    assert_equal('1', args[:flags])
    assert_equal(100, args[:ttl])
    assert_equal('World', args[:value])
  end

  def test_prepend_parse
    petition = "prepend greeting 1 100\r\nHello"
    args = RequestParser.parse(petition)
    assert_equal('prepend', args[:command])
    assert_equal('greeting', args[:key])
    assert_equal('1', args[:flags])
    assert_equal(100, args[:ttl])
    assert_equal('Hello', args[:value])
  end

  def test_replace_parse
    petition = "replace product 1 300\r\nlaptop"
    args = RequestParser.parse(petition)
    assert_equal('replace', args[:command])
    assert_equal('product', args[:key])
    assert_equal('1', args[:flags])
    assert_equal(300, args[:ttl])
    assert_equal('laptop', args[:value])
  end

  def test_cas_parse
    petition = "cas name 1 200 9876\r\nvalue"
    args = RequestParser.parse(petition)
    assert_equal('cas', args[:command])
    assert_equal('name', args[:key])
    assert_equal('1', args[:flags])
    assert_equal(200, args[:ttl])
    assert_equal(9876, args[:unique_cas_token])
    assert_equal('value', args[:value])
  end

  def test_get_one_key_parse
    petition = 'get lastname'
    args = RequestParser.parse(petition)
    assert_equal('get', args[:command])
    assert_equal(['lastname'], args[:keys])
  end

  def test_get_multiple_keys_parse
    petition = 'get id address profession'
    args = RequestParser.parse(petition)
    assert_equal('get', args[:command])
    assert_equal(['id', 'address', 'profession'], args[:keys])
  end

  def test_gets_one_key_parse
    petition = 'gets name'
    args = RequestParser.parse(petition)
    assert_equal('gets', args[:command])
    assert_equal(['name'], args[:keys])
  end

  def test_gets_multiple_keys_parse
    petition = 'gets country city neighboor'
    args = RequestParser.parse(petition)
    assert_equal('gets', args[:command])
    assert_equal(['country', 'city', 'neighboor'], args[:keys])
  end
end
