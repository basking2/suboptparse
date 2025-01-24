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

  # Add a command (and return the resulting command).
  def addcmd(name, *args)
    o = SubOptParser.new(*args)
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

  def _parse!(argv, into: nil)
    # Parse, removing all matching arguments.
    @op.parse!(argv, into: into)

    # If there is an argument left, see if it is a command.
    if argv.length > 0 && @cmds.length > 0
      name = argv.shift
      cmd = @cmds[name]
      if cmd.nil?
        [@cmd, argv]
      else
        cmd.parse!(argv, into: into)
      end
    else
      [@cmd, argv]
    end
  end

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

end
