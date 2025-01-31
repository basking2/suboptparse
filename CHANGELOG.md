## [Unreleased]

- Update project meta data.

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
