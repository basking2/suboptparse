# frozen_string_literal: true

require 'pp'

RSpec.describe Suboptparse do
  it "has a version number" do
    expect(Suboptparse::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(true).to eq(true)
  end

  it "normal opt works" do
    i = 0
    SubOptParser.new() do |opt|
      opt.on('-i=int', Integer, 'Add i') do |v|
        i = v
      end
    end.parse(*['-i', '4'])

    expect(i).to be_an(Integer)
    expect(i).to eq(4)
  end

  it "prints a banner" do
    o = SubOptParser.new do |opt|
      opt.addcmd("cmd1") { |opt| opt.description = "this does things" }
      opt.on('-i=int', "Add an int.") {}
    end

    o.addcmd("cmd2") { |opt| opt.description = "this does other things"}

    expect('''Usage: rspec [options]

cmd1 - this does things
cmd2 - this does other things

    -i=int                           Add an int.
''').to eq(o.help)
  end

  it "fully works" do
    i = 0
    argv = []

    o = SubOptParser.new do |opt|
      opt.cmd { i = 1 }
      opt.addcmd("a") { |x| x.cmd { i = 2 }}
      opt.addcmd("b") do |x| 
        x.cmd proc { i = 3 }
        x.addcmd("c") do |x2|
          x2.cmd do |a|
            i = 4 
            argv = a
          end
        end
      end
    end

    expect(i).to eq 0
    o.parse().call
    expect(i).to eq 1
    o.parse("a").call
    expect(i).to eq 2
    o.parse("b").call
    expect(i).to eq 3
    o.parse("b", "c", "--a=3", "-q").call
    expect(i).to eq 4
    o.parse("1", "c").call
    expect(i).to eq 1
  end
end
