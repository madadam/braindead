require 'helper'

class ParserTest < Test::Unit::TestCase
  def test_string
    parser = Parser.define { root 'foobar' }

    assert_equal 'foobar', parser.parse('foobar')

    assert_raise(SyntaxError) { parser.parse('') }
    assert_raise(SyntaxError) { parser.parse('foo') }
    assert_raise(SyntaxError) { parser.parse('bazqux') }
  end

  def test_range
    range = 'a' .. 'f'
    parser = Parser.define { root range }

    range.each do |char|
      assert_equal char, parser.parse(char)
    end

    assert_raise(SyntaxError) { parser.parse('') }
    assert_raise(SyntaxError) { parser.parse('g') }
  end

  def test_none_of
    parser = Parser.define { root none_of('a', 'b', 'c') }

    assert_equal 'd', parser.parse('d')

    assert_raise(SyntaxError) { parser.parse('a') }
    assert_raise(SyntaxError) { parser.parse('b') }
    assert_raise(SyntaxError) { parser.parse('c') }
  end

  def test_one_of
    parser = Parser.define { root one_of('a', 'c', 'e') }

    assert_equal 'a', parser.parse('a')
    assert_equal 'c', parser.parse('c')
    assert_equal 'e', parser.parse('e')

    assert_raise(SyntaxError) { parser.parse('b') }
  end

  def test_none
    parser = Parser.define { root none }

    assert_equal nil, parser.parse('')
    assert_equal nil, parser.parse('foo')
    assert_equal nil, parser.parse('foobar')
  end

  def test_sequence_of_two
    parser = Parser.define { root 'foo' >> 'bar' }

    assert_equal ['foo', 'bar'], parser.parse('foobar')

    assert_raise(SyntaxError) { parser.parse('') }
    assert_raise(SyntaxError) { parser.parse('foo') }
    assert_raise(SyntaxError) { parser.parse('bar') }
    assert_raise(SyntaxError) { parser.parse('bazqux') }
  end

  def test_sequence_of_more_than_two
    parser = Parser.define { root 'foo' >> 'bar' >> 'baz' }
    assert_equal ['foo', 'bar', 'baz'], parser.parse('foobarbaz')

    parser = Parser.define { root 'foo' >> ('bar' >> 'baz') }
    assert_equal ['foo', 'bar', 'baz'], parser.parse('foobarbaz')

    parser = Parser.define { root 'foo' >> 'bar' >> ('baz' >> 'qux') }
    assert_equal ['foo', 'bar', 'baz', 'qux'], parser.parse('foobarbazqux')
  end

  def test_choice_of_two
    parser = Parser.define { root 'foo' / 'bar' }

    assert_equal 'foo', parser.parse('foo')
    assert_equal 'bar', parser.parse('bar')

    assert_raise(SyntaxError) { parser.parse('') }
    assert_raise(SyntaxError) { parser.parse('baz') }
  end

  def test_choice_of_more_than_two
    parser = Parser.define { root 'foo' / 'bar' / 'baz' }

    assert_equal 'foo', parser.parse('foo')
    assert_equal 'bar', parser.parse('bar')
    assert_equal 'baz', parser.parse('baz')
  end

  def test_zero_or_more
    parser = Parser.define { root zero_or_more('foo') }

    assert_equal nil,            parser.parse('')
    assert_equal 'foo',          parser.parse('foo')
    assert_equal ['foo', 'foo'], parser.parse('foofoo')
  end

  def test_skip
    parser = Parser.define { root skip('foo') }

    assert_equal nil, parser.parse('foo')
    assert_raise(SyntaxError) { parser.parse('bar') }
  end

  def test_skip_in_sequence
    parser = Parser.define { root skip('foo') >> 'bar' >> 'baz' }

    assert_equal ['bar', 'baz'], parser.parse('foobarbaz')
  end

  def test_all_but_one_in_sequence_skipped
    parser = Parser.define { root skip('foo') >> 'bar' }

    assert_equal 'bar', parser.parse('foobar')
  end

  def test_all_in_sequence_skipped
    parser = Parser.define { root skip('foo') >> skip('bar') }

    assert_equal nil, parser.parse('foobar')
  end

  def test_eof
    parser = Parser.define { root 'foo' >> eof }

    assert_equal 'foo', parser.parse('foo')
    assert_raise(SyntaxError) { parser.parse('foobar') }
  end

  def test_transform
    parser = Parser.define do
      root 'foo' do |value|
        value.upcase
      end
    end

    assert_equal 'FOO', parser.parse('foo')
    assert_raise(SyntaxError) { parser.parse('FOO') }
  end

  def test_transform_block_is_not_called_when_the_rule_does_not_match
    called = false

    parser = Parser.define do
      root :foo / :bar

      rule :foo, 'foo' do |value|
        called = true; value
      end

      rule :bar, 'bar'
    end

    parser.parse('bar')
    assert !called
  end

  def test_transform_to_constant_value
    parser = Parser.define do
      root 'foo', 'bar'
    end

    assert_equal 'bar', parser.parse('foo')
  end

  def test_transform_with_multiple_arguments
    parser = Parser.define do
      root 'foo' >> 'bar' >> 'baz' do |one, two, three|
        [three, two, one]
      end
    end

    assert_equal ['baz', 'bar', 'foo'], parser.parse('foobarbaz')
  end

  def test_semantic_action
    parser = Parser.define do
      root :foo
      rule :foo, 'foo'

      action :foo, 'bar'
    end

    assert_equal 'bar', parser.parse('foo')
  end

  def test_zero_or_more_with_separator
    parser = Parser.define do
      root zero_or_more_with_separator('foo', ',')
    end

    assert_equal nil,                   parser.parse('')
    assert_equal 'foo',                 parser.parse('foo')
    assert_equal ['foo', 'foo'],        parser.parse('foo,foo')
    assert_equal ['foo', 'foo', 'foo'], parser.parse('foo,foo,foo')
  end

  def test_backward_reference
    parser = Parser.define do
      rule :foo, 'foo'
      root :foo
    end

    assert_equal 'foo', parser.parse('foo')
  end

  def test_forward_reference
    parser = Parser.define do
      root :foo
      rule :foo, 'foo'
    end

    assert_equal 'foo', parser.parse('foo')
  end

  def test_reference_to_reference
    parser = Parser.define do
      root :foo
      rule :foo, :bar
      rule :bar, 'bar'
    end

    assert_equal 'bar', parser.parse('bar')
  end

  def test_undefined_reference
    parser = Parser.define do
      root :foo
      rule :bar, 'bar'
    end

    assert_raise(RuleNotDefined) { parser.parse('bar') }
  end

  def test_reference_in_a_sequence
    parser = Parser.define do
      root :foo >> 'bar'
      rule :foo, 'foo'
    end

    assert_equal ['foo', 'bar'], parser.parse('foobar')
  end

  def test_referenced_sequence_in_a_sequence
    parser = Parser.define do
      root 'foo' >> :bar
      rule :bar, 'bar' >> 'baz'
    end

    assert_equal ['foo', 'bar', 'baz'], parser.parse('foobarbaz')
  end

  def test_reference_in_a_choice
    parser = Parser.define do
      root :foo / 'bar'
      rule :foo, 'foo'
    end

    assert_equal 'foo', parser.parse('foo')
  end

  def test_reference_in_repetition
    parser = Parser.define do
      root zero_or_more(:foo)
      rule :foo, 'foo'
    end

    assert_equal ['foo', 'foo'], parser.parse('foofoo')
  end

  def test_reference_in_transform
    parser = Parser.define do
      root :foo, &:upcase
      rule :foo, 'foo'
    end

    assert_equal 'FOO', parser.parse('foo')
  end

  def test_recursion
    parser = Parser.define do
      root :foo
      rule :foo, ('foo' >> :foo) / none
    end

    assert_equal nil,            parser.parse('')
    assert_equal 'foo',          parser.parse('foo')
    assert_equal ['foo', 'foo'], parser.parse('foofoo')
  end

  def test_rule_returning_nil
    parser = Parser.define do
      root 'foo' do nil end
    end

    assert_equal nil, parser.parse('foo')
  end

  def test_rule_returning_false
    parser = Parser.define do
      root 'foo' do false end
    end

    assert_equal false, parser.parse('foo')
  end

  def test_defining_rule_more_than_once_raises_an_exception
    assert_raise RuleAlreadyDefined do
      parser = Parser.define do
        root :foo
        rule :foo, 'foo'
        rule :foo, 'bar'
      end
    end
  end

  def test_token_without_value
    parser = Parser.define do
      root :foo
      rule :foo, token('foo')
    end

    assert_equal nil, parser.parse('foo')
    assert_equal nil, parser.parse('foo   ')

    assert_raise(SyntaxError) { parser.parse('') }
    assert_raise(SyntaxError) { parser.parse('bar') }
  end

  def test_token_with_value
    parser = Parser.define do
      root :foo
      rule :foo, token('foo', 'TOKEN_FOO')
    end

    assert_equal 'TOKEN_FOO', parser.parse('foo')
    assert_equal 'TOKEN_FOO', parser.parse('foo   ')

    assert_raise(SyntaxError) { parser.parse('') }
    assert_raise(SyntaxError) { parser.parse('bar') }
  end
end
