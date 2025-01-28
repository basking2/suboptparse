# frozen_string_literal: true

require_relative "suboptparse/version"

require 'optparse'

module Suboptparse
  class Error < StandardError; end
  # Your code goes here...
end

class SubOptParser

  attr_accessor :description
  attr_accessor :name
  attr_accessor :raise_unknown

  def initialize(*args)
    @op = OptionParser.new(*args)
    @op.raise_unknown = false
    @banner = @op.banner

    # This command's body.
    @cmd = proc {
      raise Exception.new("No command defined.")
    }

    # Sub-command which are SubOptParser objects.
    @cmds = {}

    yield(self) if block_given?
  end

  def method_missing(name, *args, &block)
    @op.__send__(name, *args, &block)
  end

  # Add a sub command as the given name.
  def []=(name, subcmd)
    @cmds[name] = subcmd
    @op.banner = @banner + cmdhelp
  end

  # Add a command (and return the resulting command).
  def cmdadd(name, *args)
    o = SubOptParser.new(*args)

    # Add default "help" sub-job (unless we are the help job).
    if name != "help"
      o.cmdadd('help') do |o2|
        o2.cmd { puts o.help; exit 0 }
        o2.description = "Print help."
      end
    end

    @cmds[name] = o
    yield(o) if block_given?
    @op.banner = @banner + cmdhelp
    o
  end

  def cmd(prc=nil, &blk)
    @cmd = prc unless prc.nil?
    @cmd = blk unless blk.nil?
  end

  def cmdhelp
    @cmds.inject("\n\n") do |h, v|
      h += "#{v[0]} - #{v[1].description}\n"
    end + "\n"
  end

  alias addcmd cmdadd

  def parse!(argv, into: nil)
    _parse!(argv, into: nil)
  end

  # Calls parse!.
  def parse(*argv, into: nil)
    _parse!(argv, into: into)
  end

  def call(*argv, into: nil)
    cmd, rest = _parse!(argv, into: into)

    # Explode if we have arguments left but should not.
    raise Exception.new("Unconsumed arguments: #{argv.join(',')}") if @raise_unknown && ! rest.empty?

    cmd.call(rest)
  end

  protected

  # Users may override how to lookup a command or return "nil" if none is found.
  def [](name)
    @cmds[name]
  end

  private

  def _parse!(argv, into: nil)
    # Parse, removing all matching arguments.
    @op.parse!(argv, into: into)

    if not argv.empty? and cmd = self[argv[0]]
      argv.shift
      cmd.parse!(argv, into: into)
    else
      [ @cmd , argv ]
    end
  end

end
