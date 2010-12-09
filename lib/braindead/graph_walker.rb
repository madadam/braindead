require 'set'

module Braindead
  module GraphWalker
    extend self

    def walk(node, &block)
      process_node(Set.new, node, &block)
    end

    private

    def process_node(visited, node, &block)
      return if visited.include?(node)
      visited << node

      block.call(node)
      node.parts.each { |child| process_node(visited, child, &block) }
    end
  end
end
