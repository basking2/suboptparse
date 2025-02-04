# frozen_string_literal: true

require "suboptparse/auto_require"

SubOptParser::AutoRequire.register do |so|
  so.cmddocadd("b", "B is an empty, intermediate command.")
  so.cmd { puts so.help }
end
