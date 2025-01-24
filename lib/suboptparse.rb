# frozen_string_literal: true

require_relative "suboptparse/version"

require 'optparse'

module Suboptparse
  class Error < StandardError; end
  # Your code goes here...
end

class SubOptParser
  def initialize(*args)
    @op = OptionParser.new(*args)
    @op.raise_unknown = false
    @banner = @op.banner
    @cmd = proc {
      puts @op.help
    }
    @cmds = {}

    yield(self) if block_given?
  end

  def method_missing(name, *args, &block)
    @op.__send__(name, *args, &block)
  end

  # Add a command (and return the resulting command).
  def addcmd(name, description, &body)
    @cmds[name] = {
      description: description,
      body: body,
    }

    @op.banner = @banner + cmdhelp
  end

  def setcmd(&body)
    @cmd = body
  end

  def cmdhelp
    @cmds.inject("\n\n") do |h, v|
      h += "#{v[0]} - #{v[1][:description]}\n"
    end + "\n"
  end

  def parse(*args, into: nil)
    self.parse!(args)

    if args.length > 0 && @cmds.length > 0
      name = args.shift
      cmd = cmds[name]
      raise Error.new("Subcommand #{name} was not found.") if cmd.nil?

      cmd.parse!(args)
    end
  end

end
