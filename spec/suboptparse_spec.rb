# frozen_string_literal: true

RSpec.describe SubOptParser do
  it "has a version number" do
    expect(SubOptParse::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(true).to eq(true)
  end

  it "normal opt works" do
    i = 0
    SubOptParser.new do |opt|
      opt.on("-i=int", Integer, "Add i") do |v|
        i = v
      end
    end.parse("-i", "4")

    expect(i).to be_an(Integer)
    expect(i).to eq(4)
  end

  it "prints a banner" do
    o = SubOptParser.new do |opt|
      opt.addcmd("cmd1") { |opt| opt.description = "this does things" }
      opt.on("-i=int", "Add an int.") {}
    end

    o.addcmd("cmd2") { |opt| opt.description = "this does other things" }

    expect('Usage: rspec [options]

cmd1 - this does things
cmd2 - this does other things

    -i=int                           Add an int.
').to eq(o.help)
  end

  it "fully works" do
    i = 0
    argv = []

    o = SubOptParser.new do |opt|
      opt.cmd { i = 1 }
      opt.addcmd("a") { |x| x.cmd { i = 2 } }
      opt.addcmd("b") do |x|
        x.on("-q") {}
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
    o.call
    expect(i).to eq 1
    o.call("a")
    expect(i).to eq 2
    o.call("b")
    expect(i).to eq 3
    o.call("b", "c", "-q", "--a=3")
    expect(i).to eq 4
    expect(argv).to eq ["--a=3"]
    o.call("1", "c")
    expect(i).to eq 1

    o.raise_unknown = true
    expect { o.call("b", "c", "-q", "--a=3") }.to raise_error(Exception)
  end

  it "fully works without blocks" do
    i = 0
    argv = []

    o = SubOptParser.new
    o.cmd { i = 1 }
    cmda = o.addcmd("a")
    cmda.cmd { i = 2 }
    cmdb = o.addcmd("b")
    cmdb.on("-q") {}
    cmdb.cmd proc { i = 3 }
    cmdc = cmdb.addcmd("c")
    cmdc.cmd do |a|
      i = 4
      argv = a
    end

    expect(i).to eq 0
    o.call
    expect(i).to eq 1
    o.call("a")
    expect(i).to eq 2
    o.call("b")
    expect(i).to eq 3
    o.call("b", "c", "-q", "--a=3")
    expect(i).to eq 4
    expect(argv).to eq ["--a=3"]
    o.call("1", "c")
    expect(i).to eq 1

    o.raise_unknown = true
    expect { o.call("b", "c", "-q", "--a=3") }.to raise_error(Exception)
  end

  it "allows []= syntax" do
    i = 0
    so = SubOptParser.new do |o|
      o["a"] = SubOptParser.new do |o2|
        o2.description = "The letter a"
        o2.cmd { i = 42 }
      end
    end

    expect(so.help).to eq 'Usage: rspec [options]

a - The letter a

'

    so.call("a")
    expect(i).to be(42)
  end

  it "prints help cmd contents" do
    so = SubOptParser.new do |so|
      so.cmdadd("a") do |so2|
        so2.on("--foo", "-f", "Do the foos.")
      end
    end
    r, w = IO.pipe

    pid = Process.fork
    if pid.nil?
      $stdout.reopen(w)
      so.call("a", "help")
      # Exit, everything closes.
    else
      w.close
      Process.waitpid(pid)
      txt = r.read
      txt = txt.sub(/.Finished in .*/m, "")

      # rubocop:disable Layout/TrailingWhitespace
      exp_txt = "Usage: rspec [options]

a - 


Usage: rspec a [options]

help - Print help.

    -f, --foo                        Do the foos.
"
      r.close
      expect(exp_txt).to eq(txt)
      # rubocop:enable Layout/TrailingWhitespace
    end
  end

  # rubocop:disable Layout/EmptyLinesAroundArguments
  it "handles custom sub-command lookups" do
    x = 0
    so = SubOptParser.new
    so.on_parse do |so, argv|
      if so["subcmd1"].nil?
        so["subcmd1"] = SubOptParser.new do |so|
          so.on("-x=int", Integer, "Set an int.") { |v| x = v }
          so.description = "Set x."
          so.cmd { |argv| }
        end
      end
      argv
    end

    so.call("subcmd1", "-x", "3")
    expect(x).to be 3

    x = 0

    so.call("subcmd1", "-x", "3")
    expect(x).to be 3

    expect('Usage: rspec [options]

subcmd1 - Set x.

').to eq so.help
  end
  # rubocop:enable Layout/EmptyLinesAroundArguments

  it "shares state using a hash" do
    shared_state = {}
    parser1 = SubOptParser.new do |sop|
      sop.shared_state = shared_state

      sop.addcmd("a", "A sub command") do |sop|
        sop.addcmd("b", "B sub command of a") do |sop|
          sop.cmd do |args|
            sop.shared_state["args"] = args
          end
        end
      end
    end

    # Call the "a" cmd with unknown arguments.
    # Those arguments are put in the shared state of "b" and
    # should be visible to the parent commands "a" and the root.
    parser1.call("a", "b", "--extra-arg", "foo")

    # The cmd b stored the args.
    expect(["--extra-arg", "foo"]).to eq(shared_state["args"])

    # The commands share an identical state.
    expect(shared_state).to be(parser1["a"].shared_state)
    expect(shared_state).to be(parser1["a"]["b"].shared_state)
  end

  it "shares state" do
    shared_state = {}
    parser1 = SubOptParser.new do |sop|
      sop.shared_state = shared_state

      sop.addcmd("a", "A sub command") do |sop|
        sop.addcmd("b", "B sub command of a") do |sop|
          sop.cmd do |args|
            sop.shared_state["args"] = args
          end
        end
      end
    end

    # Call the "a" cmd with unknown arguments.
    # Those arguments are put in the shared state of "b" and
    # should be visible to the parent commands "a" and the root.
    parser1.call("a", "b", "--extra-arg", "foo")

    # The cmd b stored the args.
    expect(["--extra-arg", "foo"]).to eq(shared_state["args"])

    # The commands share an identical state.
    expect(shared_state).to be(parser1["a"].shared_state)
    expect(shared_state).to be(parser1["a"]["b"].shared_state)
  end

  describe SubOptParse::SharedState do
    it "shares state" do
      shared_state = SubOptParse::SharedState.new

      parser1 = SubOptParser.new do |sop|
        sop.shared_state = shared_state
        sop.addcmd("a", "A sub command") do |sop|
          sop.addcmd("b", "B sub command of a") do |sop|
            sop.cmd do |args|
              sop.shared_state.merge!({ "args" => args })
            end
          end
        end
      end

      # Call the "a" cmd with unknown arguments.
      # Those arguments are put in the shared state of "b" and
      # should be visible to the parent commands "a" and the root.
      parser1.call("a", "b", "--extra-arg", "foo")

      # The cmd b stored the args.
      expect(["--extra-arg", "foo"]).to eq(shared_state["args"])
      expect(["--extra-arg", "foo"]).to eq(shared_state.curr["args"])

      # The commands share an identical state.
      expect(shared_state).to be(parser1["a"].shared_state)
      expect(shared_state).to be(parser1["a"]["b"].shared_state)
    end
  end

  it "handles pre and post events" do
    pre = 0
    post = 0
    so = SubOptParser.new
    so.cmdadd("a") do |so|
      # rubocop:disable Style/Semicolon
      so.pre_parse { |_, y| pre += 1; y }
      so.post_parse { |_, y| post += 1; y }
      # rubocop:enable Style/Semicolon
      so.cmd {}
    end

    so.call("a")

    expect(pre).to be(1)
    expect(post).to be(1)
  end
end
