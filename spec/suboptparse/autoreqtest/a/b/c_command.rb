# frozen_string_literal: true

require "suboptparse/auto_require"

SubOptParser::AutoRequire.register do |so, name|
  so.addcmd(name, "A command.") do |so|
    so.cmd do
      so.shared_state["x"] = 3
    end
  end
end
