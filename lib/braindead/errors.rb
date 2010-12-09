module Braindead
  Error               = Class.new(RuntimeError)
  RuleAlreadyDefined  = Class.new(Error)
  RuleNotDefined      = Class.new(Error)
  SyntaxError         = Class.new(Error)
  UnresolvedReference = Class.new(Error)
end
