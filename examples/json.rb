require 'braindead'
require 'test/unit'

# TODO: This parser is incomplete. Missing are some string escape sequences and floating
# point numbers. Maybe more.
JsonParser = Braindead::Parser.define do
  root :whitespace >> :value

  rule :colon,    token(':')
  rule :comma,    token(',')
  rule :lbracket, token('[')
  rule :rbracket, token(']')
  rule :lbrace,   token('{')
  rule :rbrace,   token('}')
  rule :rquote,   token('"')

  rule :true,     token('true',  true)
  rule :false,    token('false', false)
  rule :null,     token('null',  nil)

  rule :value, :array / :object / :number / :string / :true / :false / :null

  rule :object, :lbrace >> zero_or_more_with_separator(:object_element, :comma) >> :rbrace
  rule :object_element, :string >> :colon >> :value

  rule :array, :lbracket >> zero_or_more_with_separator(:value, :comma) >> :rbracket

  rule :number, ('0' / (:non_zero_digit >> zero_or_more(:digit))) >> :whitespace
  rule :non_zero_digit, '1' .. '9'
  rule :digit,          '0' / :non_zero_digit

  rule :string, :lquote >> zero_or_more(:char) >> :rquote
  rule :char, any_except('"', '\\') / :escape_sequence
  rule :escape_sequence, transform('\\"', '"') /
                         transform('\\n', "\n") /
                         transform('\\t', "\t")
  rule :lquote, skip('"')



  action :object do |*elements|
    Hash[*elements]
  end

  action :array do |*elements|
    elements
  end

  action :number do |*digits|
    digits.join.to_i
  end

  action :string do |*chars|
    chars.join
  end
end

class JsonParserTest < Test::Unit::TestCase
  def test_null
    assert_equal nil, JsonParser.parse('null')
  end

  def test_true
    assert_equal true, JsonParser.parse('true')
  end

  def test_false
    assert_equal false, JsonParser.parse('false')
  end

  def test_number
    (0 .. 100).each do |number|
      assert_equal number, JsonParser.parse(number.to_s)
    end
  end

  def test_string
    assert_equal 'Hello JSON!', JsonParser.parse('"Hello JSON!"')
  end

  def test_string_with_escape_sequences
    assert_equal "first line\nsecond line", JsonParser.parse('"first line\\nsecond line"')
    assert_equal "some \"quoted\" text", JsonParser.parse('"some \\"quoted\\" text"')
    assert_equal "first column\tsecond column", JsonParser.parse('"first column\\tsecond column"')
  end

  def test_array
    assert_equal [],            JsonParser.parse('[]')
    assert_equal [true],        JsonParser.parse('[true]')
    assert_equal [true, false], JsonParser.parse('[true,false]')
  end

  def test_object
    assert_equal({},                         JsonParser.parse('{}'))
    assert_equal({'foo' => 'bar'},           JsonParser.parse('{"foo":"bar"}'))
    assert_equal({'foo' => 10, 'bar' => 20}, JsonParser.parse('{"foo":10,"bar":20}'))
  end

  def test_complex
    # This examples is from wikipedia's page on JSON:
    input = %(
      {
        "firstName": "John",
        "lastName": "Smith",
        "age": 25,
        "address": {
          "streetAddress": "21 2nd Street",
          "city": "New York",
          "state": "NY",
          "postalCode": "10021"
        },
        "phoneNumber": [
          { "type": "home", "number": "212 555-1234" },
          { "type": "fax", "number": "646 555-4567" }
        ]
      }
    )

    expected = {
      'firstName' => 'John',
      'lastName'  => 'Smith',
      'age'       => 25,
      'address'   => {
        'streetAddress' => '21 2nd Street',
        'city'          => 'New York',
        'state'         => 'NY',
        'postalCode'    => '10021'
      },
      'phoneNumber' => [
        { 'type' => 'home', 'number' => '212 555-1234' },
        { 'type' => 'fax',  'number' => '646 555-4567' }
      ]
    }

    assert_equal expected, JsonParser.parse(input)
  end
end
