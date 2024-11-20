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
    - [Specifying the Target Branch](#specifying-the-target-branch)
    - [Customizing RuboCop Configuration](#customizing-rubocop-configuration)
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

LinterChanges provides a command-line interface (CLI) to run RuboCop on the files changed between your current branch and the target branch.

### Basic Usage

By default, LinterChanges will:

- Compare your current branch with the `main` branch.
- Run the linters on the changed files that linter listen to.

**Command:**

```bash
bin/linter_changes lint
```

**Example Output:**

```
Running RuboCop linter
Linting files with RuboCop: app/models/user.rb, app/controllers/users_controller.rb
Inspecting 2 files
..

2 files inspected, no offenses detected
```

### Specifying the Target Branch

If you want to compare against a different branch, you can specify it using the `--target-branch` option.

**Command:**

```bash
bin/linter_changes lint --target-branch origin/master
```

This will compare your current branch with the `origin/master` branch.

### Customizing RuboCop Configuration

You can customize the RuboCop configuration files and command options.

**Specify Custom Config Files:**

Note: each config file passed is interpreted as regex on the full file path

```bash
bin/linter_changes lint --config-files rubocop:rubocop,custom_rubocop.yml
```

**Specify Custom RuboCop Command:**

```bash
bin/linter_changes lint --linter-command rubocop:"rubocop --parallel"
```

**Combining Both:**

```bash
bin/linter_changes lint \
  --config-files rubocop:.rubocop.yml,custom_rubocop.yml \
  --linter-command rubocop:"rubocop --parallel"
```

---

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