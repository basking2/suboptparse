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
        x.on('-q') {}
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
    o.call()
    expect(i).to eq 1
    o.call("a")
    expect(i).to eq 2
    o.call("b")
    expect(i).to eq 3
    o.call("b", "c", "-q", "--a=3")
    expect(i).to eq 4
    expect(argv).to eq [ "--a=3" ]
    o.call("1", "c")
    expect(i).to eq 1

    o.raise_unknown = true
    expect { o.call("b", "c", "-q", "--a=3") } .to raise_error(Exception)
  end

  it "fully works without blocks" do
    i = 0
    argv = []

    o = SubOptParser.new
    o.cmd { i = 1 }
    cmda = o.addcmd("a")
    cmda.cmd { i = 2 }
    cmdb = o.addcmd("b")
    cmdb.on('-q') {}
    cmdb.cmd proc { i = 3 }
    cmdc = cmdb.addcmd("c")
    cmdc.cmd do |a|
      i = 4 
      argv = a
    end

    expect(i).to eq 0
    o.call()
    expect(i).to eq 1
    o.call("a")
    expect(i).to eq 2
    o.call("b")
    expect(i).to eq 3
    o.call("b", "c", "-q", "--a=3")
    expect(i).to eq 4
    expect(argv).to eq [ "--a=3" ]
    o.call("1", "c")
    expect(i).to eq 1

    o.raise_unknown = true
    expect { o.call("b", "c", "-q", "--a=3") } .to raise_error(Exception)
  end
end
