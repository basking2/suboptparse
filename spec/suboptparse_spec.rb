# frozen_string_literal: true

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
      opt.addcmd("cmd1", "this does things") { puts "cmd1" }
      opt.on('-i=int', "Add an int.") {}
    end

    o.addcmd("cmd2", "this does other things") { puts "cmd2" }

    expect('''Usage: rspec [options]

cmd1 - this does things
cmd2 - this does other things

    -i=int                           Add an int.
''').to eq(o.help)
  end
end
