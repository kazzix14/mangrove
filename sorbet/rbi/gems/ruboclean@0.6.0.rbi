# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `ruboclean` gem.
# Please instead update this file by running `bin/tapioca gem ruboclean`.


# Ruboclean entry point
#
# source://ruboclean//lib/ruboclean/cli_arguments.rb#3
module Ruboclean
  class << self
    # source://ruboclean//lib/ruboclean.rb#26
    def post_execution_message(changed, verify); end

    # source://ruboclean//lib/ruboclean.rb#14
    def run_from_cli!(args); end
  end
end

# Reads command line arguments and exposes corresponding reader methods
#
# source://ruboclean//lib/ruboclean/cli_arguments.rb#5
class Ruboclean::CliArguments
  # @return [CliArguments] a new instance of CliArguments
  #
  # source://ruboclean//lib/ruboclean/cli_arguments.rb#6
  def initialize(command_line_arguments = T.unsafe(nil)); end

  # source://ruboclean//lib/ruboclean/cli_arguments.rb#10
  def path; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/cli_arguments.rb#22
  def preserve_comments?; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/cli_arguments.rb#26
  def preserve_paths?; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/cli_arguments.rb#18
  def silent?; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/cli_arguments.rb#14
  def verbose?; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/cli_arguments.rb#30
  def verify?; end

  private

  # Returns the value of attribute command_line_arguments.
  #
  # source://ruboclean//lib/ruboclean/cli_arguments.rb#36
  def command_line_arguments; end

  # source://ruboclean//lib/ruboclean/cli_arguments.rb#46
  def find_argument(name); end

  # source://ruboclean//lib/ruboclean/cli_arguments.rb#38
  def find_path; end
end

# Groups the rubocop configuration items into three categories:
#   - base: base configuration like 'require', 'inherit_from', etc
#   - namespaces: every item which does **not** include an "/"
#   - cops: every item which **includes** an "/"
#
# source://ruboclean//lib/ruboclean/grouper.rb#8
class Ruboclean::Grouper
  # @return [Grouper] a new instance of Grouper
  #
  # source://ruboclean//lib/ruboclean/grouper.rb#9
  def initialize(configuration_hash); end

  # source://ruboclean//lib/ruboclean/grouper.rb#13
  def group_config; end

  private

  # Returns the value of attribute configuration_hash.
  #
  # source://ruboclean//lib/ruboclean/grouper.rb#23
  def configuration_hash; end

  # source://ruboclean//lib/ruboclean/grouper.rb#25
  def empty_groups; end

  # source://ruboclean//lib/ruboclean/grouper.rb#29
  def find_target_group(key); end
end

# Logger for clean management of log levels
#
# source://ruboclean//lib/ruboclean/logger.rb#5
class Ruboclean::Logger
  # @raise [ArgumentError]
  # @return [Logger] a new instance of Logger
  #
  # source://ruboclean//lib/ruboclean/logger.rb#6
  def initialize(log_level = T.unsafe(nil)); end

  # source://ruboclean//lib/ruboclean/logger.rb#12
  def verbose(message); end
end

# Orders the items within the groups alphabetically
#
# source://ruboclean//lib/ruboclean/orderer.rb#5
class Ruboclean::Orderer
  # @return [Orderer] a new instance of Orderer
  #
  # source://ruboclean//lib/ruboclean/orderer.rb#6
  def initialize(configuration_hash); end

  # source://ruboclean//lib/ruboclean/orderer.rb#10
  def order; end

  private

  # Returns the value of attribute configuration_hash.
  #
  # source://ruboclean//lib/ruboclean/orderer.rb#19
  def configuration_hash; end

  # source://ruboclean//lib/ruboclean/orderer.rb#25
  def grouped_config; end

  # source://ruboclean//lib/ruboclean/orderer.rb#21
  def order_by_key(group_items); end
end

# Cleans up any `Include` or `Exclude` paths that don't exist.
# The `Include` and `Exclude` paths are relative to the directory
# where the `.rubocop.yml` file is located. If a path includes a
# regexp, it's assumed to be valid.
# If all entries in `Include` or `Exclude` are removed, the entire property is removed.
# If a Cop gets entirely truncated due to removing all `Includes` and/or `Exclude`, the Cop itself will be removed.
#
# source://ruboclean//lib/ruboclean/path_cleanup.rb#10
class Ruboclean::PathCleanup
  # @return [PathCleanup] a new instance of PathCleanup
  #
  # source://ruboclean//lib/ruboclean/path_cleanup.rb#11
  def initialize(configuration_hash, root_directory); end

  # source://ruboclean//lib/ruboclean/path_cleanup.rb#16
  def cleanup; end

  private

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/path_cleanup.rb#70
  def any_global_command_pattern?(item); end

  # Returns the value of attribute configuration_hash.
  #
  # source://ruboclean//lib/ruboclean/path_cleanup.rb#28
  def configuration_hash; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/path_cleanup.rb#60
  def path_exists?(item); end

  # source://ruboclean//lib/ruboclean/path_cleanup.rb#51
  def process_cop_property(cop_property_key, cop_property_value); end

  # top_level_value could be something like this:
  #
  # {
  #   Include: [...],
  #   Exclude: [...],
  #   EnforcedStyle: "..."
  # }
  #
  # We process it further in case of a Hash.
  #
  # source://ruboclean//lib/ruboclean/path_cleanup.rb#39
  def process_top_level_value(top_level_value); end

  # We don't support Regexp, so we just say it exists.
  #
  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/path_cleanup.rb#75
  def regexp_pattern?(item); end

  # Returns the value of attribute root_directory.
  #
  # source://ruboclean//lib/ruboclean/path_cleanup.rb#28
  def root_directory; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/path_cleanup.rb#66
  def specific_path_exists?(item); end
end

# Entry point for processing
#
# source://ruboclean//lib/ruboclean/runner.rb#8
class Ruboclean::Runner
  # @return [Runner] a new instance of Runner
  #
  # source://ruboclean//lib/ruboclean/runner.rb#9
  def initialize(args = T.unsafe(nil)); end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/runner.rb#23
  def changed?(target_yaml); end

  # source://ruboclean//lib/ruboclean/runner.rb#35
  def path; end

  # source://ruboclean//lib/ruboclean/runner.rb#13
  def run!; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/runner.rb#27
  def verbose?; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/runner.rb#31
  def verify?; end

  private

  # source://ruboclean//lib/ruboclean/runner.rb#55
  def cleanup_paths(configuration_hash); end

  # Returns the value of attribute cli_arguments.
  #
  # source://ruboclean//lib/ruboclean/runner.rb#41
  def cli_arguments; end

  # source://ruboclean//lib/ruboclean/runner.rb#61
  def convert_to_yaml(configuration_hash); end

  # @raise [ArgumentError]
  #
  # source://ruboclean//lib/ruboclean/runner.rb#75
  def find_source_file_pathname; end

  # source://ruboclean//lib/ruboclean/runner.rb#47
  def load_file; end

  # source://ruboclean//lib/ruboclean/runner.rb#51
  def order(configuration_hash); end

  # source://ruboclean//lib/ruboclean/runner.rb#71
  def source_file_pathname; end

  # source://ruboclean//lib/ruboclean/runner.rb#43
  def source_yaml; end

  # source://ruboclean//lib/ruboclean/runner.rb#65
  def write_file!(target_yaml); end
end

# Converts the configuration hash to YAML and applies modifications on it, if requested
#
# source://ruboclean//lib/ruboclean/to_yaml_converter.rb#5
class Ruboclean::ToYamlConverter
  # @return [ToYamlConverter] a new instance of ToYamlConverter
  #
  # source://ruboclean//lib/ruboclean/to_yaml_converter.rb#6
  def initialize(configuration_hash, preserve_comments, source_yaml); end

  # source://ruboclean//lib/ruboclean/to_yaml_converter.rb#12
  def to_yaml; end

  private

  # Returns the value of attribute configuration_hash.
  #
  # source://ruboclean//lib/ruboclean/to_yaml_converter.rb#22
  def configuration_hash; end

  # Returns the value of attribute preserve_comments.
  #
  # source://ruboclean//lib/ruboclean/to_yaml_converter.rb#22
  def preserve_comments; end

  # @return [Boolean]
  #
  # source://ruboclean//lib/ruboclean/to_yaml_converter.rb#24
  def preserve_comments?; end

  # source://ruboclean//lib/ruboclean/to_yaml_converter.rb#32
  def preserve_preceding_comments(source, target); end

  # source://ruboclean//lib/ruboclean/to_yaml_converter.rb#28
  def sanitize_yaml(data); end

  # Returns the value of attribute source_yaml.
  #
  # source://ruboclean//lib/ruboclean/to_yaml_converter.rb#22
  def source_yaml; end
end

# source://ruboclean//lib/ruboclean/version.rb#4
Ruboclean::VERSION = T.let(T.unsafe(nil), String)
