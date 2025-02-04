# frozen_string_literal: true

require "suboptparse/auto_require"

SubOptParser::AutoRequire.register do |so|
  so.cmd do
    so.shared_state["x"] = 3
  end
end
