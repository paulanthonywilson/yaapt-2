# Monkey-patch to fix a parsing bug.
# (Submitted to Edge as http://dev.rubyonrails.org/ticket/7641/)

module HTML
  class Document
    def initialize(text, strict=false, xml=false)
      tokenizer = Tokenizer.new(text)
      @root = Node.new(nil)
      node_stack = [ @root ]
      while token = tokenizer.next
        node = Node.parse(node_stack.last, tokenizer.line, tokenizer.position, token)

        node_stack.last.children << node unless node.tag? && node.closing == :close
        if node.tag?
          if node_stack.length > 1 && node.closing == :close
            if node_stack.last.name == node.name
              if node_stack.last.children.empty?
                node_stack.last.children << Text.new(node_stack.last, node.line, node.position, "")
              end
              node_stack.pop
            else
              open_start = node_stack.last.position - 20
              open_start = 0 if open_start < 0
              close_start = node.position - 20
              close_start = 0 if close_start < 0
              msg = <<EOF.strip
ignoring attempt to close #{node_stack.last.name} with #{node.name}
  opened at byte #{node_stack.last.position}, line #{node_stack.last.line}
  closed at byte #{node.position}, line #{node.line}
  attributes at open: #{node_stack.last.attributes.inspect}
  text around open: #{text[open_start,40].inspect}
  text around close: #{text[close_start,40].inspect}
EOF
              strict ? raise(msg) : warn(msg)
            end
          elsif !node.childless?(xml) && node.closing != :close
            node_stack.push node
          end
        end
      end
    end
  end
end
