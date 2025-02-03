# frozen_string_literal: true

RSpec.describe SubOptParser::AutoRequire do
  it "autoloads a command" do
    $LOAD_PATH << File.dirname(__FILE__)

    so = SubOptParser.new do |opt|
      opt.autorequire_root = "suboptparse/autoreqtest"
      opt.shared_state = {}
    end

    s = "

help - Print help.
b - B is an empty, intermediate command.

"
    expect(s).to eq(so.get_subcommand("a").cmdhelp)

    so.call("a", "b", "c")
    expect(3).to eq(so.shared_state["x"])
  end
end
