module Braindead
  autoload :Range,               'braindead/range'
  autoload :Choice,              'braindead/choice'
  autoload :Cursor,              'braindead/cursor'
  autoload :Eof,                 'braindead/eof'
  autoload :GraphWalker,         'braindead/graph_walker'
  autoload :InvalidRange,        'braindead/errors'
  autoload :None,                'braindead/none'
  autoload :Parser,              'braindead/parser'
  autoload :Reference,           'braindead/reference'
  autoload :Rule,                'braindead/rule'
  autoload :RuleAlreadyDefined,  'braindead/errors'
  autoload :RuleNotDefined,      'braindead/errors'
  autoload :Satisfy,             'braindead/satisfy'
  autoload :Sequence,            'braindead/sequence'
  autoload :Skip,                'braindead/skip'
  autoload :String,              'braindead/string'
  autoload :SyntaxError,         'braindead/errors'
  autoload :Transform,           'braindead/transform'
  autoload :UnresolvedReference, 'braindead/errors'
  autoload :ZeroOrMore,          'braindead/zero_or_more'
end

require 'braindead/core_extensions'