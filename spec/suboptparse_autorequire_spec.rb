# frozen_string_literal: true

RSpec.describe SubOptParser::AutoRequire do
  describe "autoloads a command" do
    $LOAD_PATH << File.dirname(__FILE__)

    it "using implicit reqiure" do
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

    it "using explicit require to cmddocadd" do
      so = SubOptParser.new do |opt|
        opt.shared_state = {}
        opt.autorequire_root = "suboptparse/autoreqtest2"
        opt.cmddocadd("a", "A", "a_command")
        opt.cmddocadd("b", "B", "a/b_command")
        opt.cmddocadd("c", "C", "a/b/c_command")
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
end
