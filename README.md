# LinterChanges

LinterChanges is a Ruby gem that runs linters on files changed between your current branch and a target branch (e.g., `master`). It helps maintain code quality by ensuring that only the changed files are linted, saving time and resources.

**What sets LinterChanges apart from other tools like Pronto is that it checks entire files rather than just the changed lines when raising errors. Additionally, if configuration changes for the linter occur, LinterChanges will run the linter on the entire repository, not just on the current changes.**

Currently, **LinterChanges** supports **RuboCop** for Ruby code. Support for additional linters can be added in the future.

---

## Table of Contents

- [LinterChanges](#linterchanges)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Basic Usage](#basic-usage)
    - [CLI](#cli)
    - [Customizing Configuration](#customizing-configuration)
  - [Contributing](#contributing)
  - [Running the test suite](#running-the-test-suite)
  - [Acknowledgments](#acknowledgments)

---

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'linter_changes', git: 'https://github.com/bukhr/linter_changes.git'
```

```bash
bundle install
```

---

## Usage

LinterChanges provides a command-line interface (CLI) to run Linters on the files changed between your current branch and the target branch. Also if you change a configuration file, it will run on the entire repository.

### Basic Usage

By default, LinterChanges will:

- Run globally on all files applying all linters specify in configuration.
  - The linters will only run on files that the linter listen to.
- Optionally, if you pass CHANGE_TARGET environment variable to run only on changed files between HEAD and the CHANGE_TARGET branch.

**Command:**

```bash
CHANGE_TARGET=origin/master bin/linter_changes lint
```

**Example Output:**

```bash
❯ CHANGE_TARGET=master ./Jenkins/test-scripts/rubocop.sh
[DEBUG] Using configuration file: .linter_changes.yml
[DEBUG] Running Rubocop linter
[DEBUG] Target branch: origin/master
[DEBUG] Executing command: git diff --name-only origin/master...HEAD
[DEBUG] Changed files: bin/linter_changes, packs/hcm/core/employee_management/app/models/employee.rb
[DEBUG] Executing command: bin/rubocop --list-target-files
[DEBUG] Linting files with [Rubocop]: packs/hcm/core/employee_management/app/models/employee.rb
[DEBUG] [Rubocop] Executing command: bin/rubocop --parallel --extra-details --display-style-guide --fail-level convention --display-only-fail-level-offenses --format clang packs/hcm/core/employee_management/app/models/employee.rb

1 file inspected, no offenses detected
```

### CLI

The `linter_changes` command provides several options to customize its behavior:

```bash
bin/linter_changes lint [options]
```

**Global Options:**

- `--debug`: Enable debug mode to see detailed logging information
- `--force_global`: Force running linters on all files, ignoring git diff

**Lint Command Options:**

- `--linters=rubocop,eslint,...`: Specify which linters to run (comma-separated list)
- `--config_file=PATH`: Path to the configuration file (default: `.linter_changes.yml`)

**Environment Variables:**

- `CHANGE_TARGET`: Specify the target branch for comparison (e.g., `CHANGE_TARGET=origin/master`). If not specified, it will run on all files.

**Examples:**

```bash
# Run with debug logging
bin/linter_changes lint --debug

# Force global run regardless of changed files
bin/linter_changes lint --force_global

# Only run specific linters
bin/linter_changes lint --linters=rubocop,eslint

# Use a custom config file
bin/linter_changes lint --config_file=custom_linter_config.yml

# Combine options
CHANGE_TARGET=main bin/linter_changes lint --debug --linters=rubocop
```

### Customizing Configuration

You can customize the configuration creating a file called `.linter_changes.yml` at the root of your proyect.

Example:

```yml
---
rubocop:
  linter_command: "bin/rubocop \
    --parallel \
    --extra-details \
    --display-style-guide \
    --fail-level convention \
    --display-only-fail-level-offenses \
    --format clang"
  config_files:
  - "rubocop"
```

each key represents a linter (e.g., `rubocop`) and inside it you can specify the linter command and the files that trigger a global run of the linter.
In this example, if a file containing `rubocop` is edited, it would trigger a full run on all the proyect.

Also, if you want to specify another yml file, you can pass it though the cli with the option `--config_file`. The default is `.linter_changes.yml`.

## Contributing

Contributions are welcome! If you'd like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch:

   ```bash
   git checkout -b feature/your_feature_name
   ```

3. Make your changes.
4. Commit your changes:

   ```bash
   git commit -m "Add your commit message"
   ```

5. Push to your branch:

   ```bash
   git push origin feature/your_feature_name
   ```

6. Open a pull request on GitHub.

---

## Running the test suite

```bash
bundle exec rake test
```

---

## Acknowledgments

- [RuboCop](https://github.com/rubocop/rubocop) - The Ruby static code analyzer and formatter.
- [Thor](https://github.com/erikhuda/thor) - A toolkit for building powerful command-line interfaces.

---

**Note:** Currently, LinterChanges supports only RuboCop for linting Ruby files. Support for additional linters may be added in the future.

**Key Features:**

- **Full File Linting:** Unlike tools like Pronto that only check the changed lines, LinterChanges lints the entire files that have been modified. This ensures that any issues in the modified files are caught, not just those in the changed lines.
- **Configuration Change Detection:** If a configuration file for the linter (e.g., `.rubocop.yml`) has changed, LinterChanges will run the linter on the entire repository. This ensures that any new or altered linting rules are applied across all files.

---
