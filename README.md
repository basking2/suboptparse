# Suboptparse

SubOptParse is a collection of classes and utilities to extend Ruby's 
OptionParser with some understanding of sub-commands.

Sub-commands maybe thought of as a traditional CLI command but with 
a single parent command as the entry poiont. As an example, consider
a CLI application that buys things from a store. We'll call the command
`./buy`. You can have a sub-command `./buy apples --count=3` that
knows how to buy apples. Now, purchasing from the deli is different
and so we isolate that into a different sub-command, `deli`.
You could run `./buy deli potato_salad`.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add suboptparse

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install suboptparse

## Usage

### Looks Like OptionParser

```ruby
require "suboptparse"

# Looks like OptionParser.
parser = SubOptParser.new do |sop|
  # Normal OptionParser calls.
  sop.on("--my-option=foo", "-m", "Sets a value") do |v|
    # Record value somewhere.
  end
end

# Still looks like OptionParser, but a command to execute is returned.
cmd = parser.parse!

# If you don't specify a command, don't call this! It throws an exception.
cmd.call()
```

### Define A Root Command

This is like the previous example, but we define a command to call.

```ruby
require "suboptparse"

# Looks like OptionParser.
parser = SubOptParser.new do |sop|
  # Normal OptionParser calls.
  sop.on("--my-option=foo", "-m", "Sets a value") do |v|
    # Record value somewhere.
  end

  sop.cmd do |args|
    puts "Root command run."
  end
end

# Still looks like OptionParser, but a command to execute is returned.
cmd = parser.parse!

# Now this prints, "Root command run."
cmd.call()
```

### Sub Command Example

This example shows a sub-command and a few features.

You can raise an exception if arguments are not consumed during parsing
using `raise_unknown=true`. 

You can share state between commands so they can parse into a common location.
This makes parent commands sharing common values with child commands
easier.

Finally, if you set `raise_unknown=false` (the default value), then
unparsed command line options are passed to the called command.

```ruby
require "suboptparse"

# Looks like OptionParser.
parser = SubOptParser.new do |sop|

  # Set shared state. All sub-commands may add values to this.
  # This is set at command creation time and should not be changed after.
  sop.shared_state = SubOptParse::SharedState.new

  # This command should raise an error if it executes with unconsumed options.
  # Default is false.
  sop.raise_unknown = true

  # Normal OptionParser calls.
  sop.on("--my-option=foo", "-m", "Sets a value") do |v|
    # Record value somewhere.
  end

  sop.cmd do |args|
    puts "Root command run."
  end

  sop.cmdadd("subcommand", "This is a sub-command.") do |sop|
    sop.on("--sub-command-option=value", "A sub-command option.") do |v|
      sop.shared_state["sub-command-option"] = v
    end

    sop.cmd do |unconsumed_arguments|
      sop.shared_state["sub-command-option"]
    end
  end
end

# Parse and call the command in 1 call.
ret = parser.call("subcommand", "--sub-command-option=foo", "--my-option=bar")

# The returns "foo".
puts "Calling subcommand returned #{ret}."
```

## How Tos

### Intercept -h

Calling `-h` normally has the effect of terminating parsing and printing the
help of the parent command. You can register an `on_parse` handler to 
remove `-h` and append `help` to the end of the command line arguemnts.
This will cause the default help function of the child command to be called
when `-h` is on the command line.

```ruby
require "suboptparse"

# Looks like OptionParser.
parser = SubOptParser.new do |sop|

  sop.on_parse do |op, argv|
    if argv.include? "-h" or argv.include? "--help"
        argv.delete("-h")
        argv.delete("--help")
        argv.push('help')
    end
    argv
  end

  sop.shared_state = SubOptParse::SharedState.new

  # Normal OptionParser calls.
  sop.on("--my-option=foo", "-m", "Sets a value") do |v|
    # Record value somewhere.
  end

  sop.cmd do |args|
    puts "Root command run."
  end

  sop.cmdadd("subcommand", "This is a sub-command.") do |sop|
    sop.on("--sub-command-option=value", "A sub-command option.") do |v|
      sop.shared_state["sub-command-option"] = v
    end

    sop.cmd do
      sop.shared_state["sub-command-option"]
    end
  end
end

# Parse and call the command in 1 call.
ret = parser.call("-h", "subcommand")

puts "Calling subcommand returned #{ret}."
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/basking2/suboptparse.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
