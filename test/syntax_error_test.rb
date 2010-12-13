require 'helper'

class SyntaxErrorTest < Test::Unit::TestCase
  def test_string_error
    parser = Parser.define { root 'foo' }

    assert_syntax_error('"foo"') { parser.parse('bar') }
  end

  def test_range_error
    parser = Parser.define { root 'a' .. 'f' }

    assert_syntax_error('"a" .. "f"') { parser.parse('g') }
  end

  def test_none_of_error
    parser = Parser.define { root none_of('a', 'b', 'c') }

    assert_syntax_error('none of ["a", "b", "c"]') { parser.parse('b') }
  end

  def test_one_of_error
    parser = Parser.define { root one_of('a', 'b', 'c') }

    assert_syntax_error('one of ["a", "b", "c"]') { parser.parse('d') }
  end

  def test_sequence_error
    parser = Parser.define { root 'foo' >> 'bar' >> 'baz' }

    assert_syntax_error('"foo"', 0) { parser.parse('qux') }
    assert_syntax_error('"bar"', 3) { parser.parse('fooqux') }
    assert_syntax_error('"baz"', 6) { parser.parse('foobarqux') }
  end

  def test_choice_error
    parser = Parser.define { root 'foo' / 'bar' / 'baz' }

    assert_syntax_error('"foo" or "bar" or "baz"') { parser.parse('qux') }
  end

  def test_skip_error
    parser = Parser.define { root skip('foo') }

    assert_syntax_error('"foo"') { parser.parse('bar') }
  end

  def test_eof_error
    parser = Parser.define { root 'foo' >> eof }

    assert_syntax_error('end of file', 3) { parser.parse('foobar') }
  end

  def test_transform_error
    parser = Parser.define { root 'foo', &:upcase }

    assert_syntax_error('"foo"') { parser.parse('bar') }
  end

  def test_sequence_in_choice_error
    parser = Parser.define do
      root :array / :hash
      rule :array, '[' >> ']'
      rule :hash,  '{' >> '}'
    end

    assert_syntax_error('"[" or "{"', 0) { parser.parse('<') }
    assert_syntax_error('"]"',        1) { parser.parse('[>') }
    assert_syntax_error('"}"',        1) { parser.parse('{>') }
  end

  def test_choice_in_sequence_error
    parser = Parser.define do
      root :name >> :operator
      rule :name,     'foo' / 'bar'
      rule :operator, '!' / '?'
    end

    assert_syntax_error('"foo" or "bar"', 0) { parser.parse('baz') }
    assert_syntax_error('"!" or "?"',     3) { parser.parse('foo-') }
  end

  def test_recursion_error
    parser = Parser.define do
      root :list
      rule :list,  "(" >> (:list / none) >> ")"
    end

    assert_syntax_error('")"', 1) { parser.parse('(]') }
    assert_syntax_error('")"', 2) { parser.parse('((])') }
  end

  private

  def assert_syntax_error(expectation, position = nil, &block)
    exception = assert_raise(SyntaxError, &block)

    assert_equal expectation, exception.expectation
    assert_equal position,    exception.position if position
  end
end
