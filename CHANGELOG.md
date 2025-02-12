## [Unreleased]

- Support post_parse and after_parse.
- Alias on_parse to pre_parse.

## [0.1.13] - 2025-02-04

- Throw the LoadError what prevents an command from being auto-required
  if that command is ever executed.

## [0.1.12] - 2025-02-03

- Adjust SubOptParse::AutoRequire.require to automatically add the sub-command
  and pass the created SubOptParse object to the callback for further 
  configuration.
- Improve help output to remove duplicate commands and sort the commands by
  command name. Duplicates could appear when a command was registered by
  cmdadd() and cmddocsadd().

## [0.1.11] - 2025-02-03

- Extend cmddocadd() to also support dynamic autloading of commands
  defined in this way. This allows cmd documentation to exist when
  autoloading is defined.

## [0.1.10] - 2025-02-03

- Add recurisve help. Help is printed from the root command down to the 
  last called child command.

## [0.1.9] - 2025-02-02

- Add sub-command documentation when there is no loaded command.
- Allow auto-loading of files if an autorequire_root path is defined.
- Migrate cmdpath to a list of command names rather than a single string.

## [0.1.8] - 2025-01-31

- Update changelog and readme to match new release process.

## [0.1.7] - 2025-01-31

- *No Change* - Configuring GitHub actions to release code.

## [0.1.6] - 2025-01-31

- *No Change* - Configuring GitHub actions to release code.

## [0.1.5] - 2025-01-30

- Update project meta data.
- Update project rdoc documentation.
- Add RDoc::Task to Rakefile. Output to ./rdoc.

## [0.1.4] - 2025-01-30

- Set @cmdpath in the command ussage. This is the path in the command tree
  that leads to the executing command.
- Add SubOptParse::Util.merge_recursive() to assist in merging
  configurations loaded into Ruby Hash objects.
- Add SubOptParse::SharedState to help use shared_state correctly
  in instances of SubOptParsers.

## [0.1.3] - 2025-01-28

- Set banner correctly on sub-commands.

## [0.1.2] - 2025-01-28

- Update usage on sub-commands.
- Allow an optional description to be included when calling .cmdadd().

## [0.1.1] - 2025-01-28

- Add default "help" sub-command to all commands.
- Allow for custom command lookups by overriding SubOptParser#[].
- Allow for adding commands are parse time with .on_parse { |so| ... }

## [0.1.0] - 2025-01-21

- Initial release
