# frozen_string_literal: true

require_relative "suboptparse/version"
require_relative "suboptparse/shared_state"
require_relative "suboptparse/util"
require_relative "suboptparse/auto_require"

require "optparse"

module SubOptParse
  class Error < StandardError; end
end

# An adaptation of Ruby's default OptionParser to support sub-commands.
# :stopdoc:
# rubocop:disable Metrics/ClassLength
# :startdoc:
class SubOptParser
  include SubOptParser::AutoRequire

  # The description of this command.
  attr_accessor :description

  # The path of parent commands to this command.
  # This is automatically set by #cmdadd().
  attr_accessor :cmdpath

  # The parent command, or nil? if this is the root command.
  attr_accessor :cmdparent

  # Arbitrary user data that is shared with all child objects.
  # If the user does not change this, all child commands get the same
  # state assigned when created with #cmdadd().
  #
  # NOTE: This must be set before calling #cmdadd().
  #
  # This may be any object, but the SubOptParse::ShareState class is a
  # useful helper.
  attr_accessor :shared_state

  # When non-nil the +cmdpath+ of this command and a sub-command will be used to
  # automatically `require` the Ruby file to register the command.
  #
  attr_accessor :autorequire_root

  # Initialize a new SubOptParser.
  #
  # If block is given, this object is passed to allow for further initialization.
  #
  # banner:: Passed to OptionParser.new.
  # width:: Passed to OptionParser.new.
  # indent:: Passed to OptionParser.new.
  # :parent => parent:: Defines the parent command to this one.
  #
  def initialize(banner = nil, width = 32, indent = " " * 4, **args) # :yields: self
    autorequire_init
    @op = OptionParser.new(banner, width, indent)
    self.raise_unknown = false
    @banner = @op.banner
    @on_parse_blk = nil
    @cmdpath = [File.basename($PROGRAM_NAME)]

    # This command's body.
    @cmd = proc { raise StandardError, "No command defined." }

    # Sub-command which are SubOptParser objects.
    @cmds = {}

    @cmdparent = args.delete(:parent)

    yield(self) if block_given?
  end

  def method_missing(name, *args, &block)
    @op.__send__(name, *args, &block)
  end

  def respond_to_missing?(_name, _include_private = false)
    true
  end

  # If true, an exception will be thrown when an unknown argument is given.
  def raise_unknown
    @op.raise_unknown
  end

  # If true, an exception will be thrown when an unknown argument is given.
  def raise_unknown=(value)
    @op.raise_unknown = value
  end

  # Add a sub command as the given name.
  # No automatic initializtion is done. Prefer using #cmdadd().
  #
  #     parser["sub_parser"] = SubOptParser.new do { |sub| ... }
  def []=(name, subcmd)
    @cmds[name] = subcmd
    @op.banner = @banner + cmdhelp
  end

  # Users may override how to lookup a command or return "nil" if none is found.
  def [](name)
    @cmds[name]
  end

  # A callable that is invoked when this SubOptParser starts parsing arguments.
  # This is primarily here to allow for lazy-populating of commands
  # instead of requiring them to be defined at program invokation *or*
  # to allow filtering or manipulating the command line arguments before
  # parsing.
  #
  # The proc takes 2 arguments, this SubOptParse object and the current
  # command line options array. Whatever is returned by this call
  # is assigned to the command line options array value and is parsed. Eg:
  #
  #     parser = SubOptParser.new
  #     parser.on_parse { |p,args| p["subcmd"] = SubOptParser.new ; args}
  #
  # Be careful to not create infinite recursion by adding
  # commands that call themselves and then add themselves.
  def on_parse(&blk) # :yields: sub_opt_parser, arguments
    @on_parse_blk = blk
  end

  # Add a command (and return the resulting command).
  def cmdadd(name, description = nil, *args) # :yields: self
    o = _create_sub_command(name, description, *args)

    # Add default "help" sub-job (unless we are the help job).
    _add_default_help_cmd(o) if name != "help"

    @cmds[name] = o
    yield(o) if block_given?
    @op.banner = @banner + cmdhelp
    o
  end

  def cmd(prc = nil, &blk) # :yields: unconsumed_arguments
    @cmd = prc unless prc.nil?
    @cmd = blk unless blk.nil?
  end

  # Put the parent help text at the start of this command's help.
  # This allows for building recursive help.
  def help
    if @cmdparent.nil?
      @op.help
    else
      "#{@cmdparent.help}\n#{@op.help}"
    end
  end

  def cmdhelp
    # Inject defined commands.
    h = @cmds.inject("\n\n") do |h, v|
      "#{h}#{v[0]} - #{v[1].description}\n"
    end

    # Inject unloaded but documented commands.
    h = @cmddocs.inject(h) do |h, v|
      "#{h}#{v[0]} - #{v[1]}\n"
    end

    # Append extra line.
    "#{h}\n"
  end

  alias addcmd cmdadd

  def parse!(argv, into: nil)
    _parse!(argv, into: into)
  end

  # Calls parse!.
  def parse(*argv, into: nil)
    _parse!(argv, into: into)
  end

  # Parse the arguments in *argv and execute #call() on the returned command.
  # Any unparsed values are passed to the invocation of #call().
  #
  # This is equivalent to
  #
  #     cmd = parser.parse!(args)
  #     cmd.call(args)
  def call(*argv, into: nil)
    cmd, rest = _parse!(argv, into: into)

    # Explode if we have arguments left but should not.
    raise StandardError, "Unconsumed arguments: #{argv.join(",")}" if raise_unknown && !rest.empty?

    cmd.call(rest)
  end

  # How sub-commands are loaded.
  # If no sub-command can be loaded for the name, +nil+ is returned.
  def get_subcommand(name)
    if (cmd = self[name])
      cmd
    elsif autorequire_root && (cmd = autorequire(name))
      cmd
    end
  end

  private

  def _parse!(argv, into: nil)
    argv = @on_parse_blk.call(self, argv) if @on_parse_blk

    # Parse, removing all matching arguments.
    @op.parse!(argv, into: into)

    if !argv.empty? && (cmd = get_subcommand(argv[0]))
      argv.shift
      cmd.parse!(argv, into: into)
    else
      [@cmd, argv]
    end
  end

  def _add_default_help_cmd(opt_parser)
    opt_parser.cmdadd("help") do |o2|
      o2.cmd do
        puts opt_parser.help
        exit 0
      end
      o2.description = "Print help."
    end
  end

  def _create_sub_command(name, description, *args)
    cmdpath = @cmdpath.dup.append(name)
    o = SubOptParser.new("Usage: #{cmdpath.join(" ")} [options]", *args, parent: self)
    o.cmdpath = cmdpath
    o.description ||= description
    o.shared_state = @shared_state
    o.raise_unknown = raise_unknown
    o.autorequire_root = autorequire_root
    o
  end
end
# :stopdoc:
# rubocop:enable Metrics/ClassLength
# :startdoc:
