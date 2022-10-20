# frozen_string_literal: true

require 'open3'

# Helper methods for executing commands on the shell.
module ShellCommand
  extend ActiveSupport::Concern

  # Executes a shell command and returns the standard output.
  #
  # @overload popen3(command, ...)
  #   @param [String] command The name of the command to be executed.
  #   @param [String] ... Zero or more arguments to be passed to the command.
  #   @return [String] The contents of standard output.
  def exec_command(*command)
    Open3.popen3(*command) do |_, stdout, _, _|
      stdout.gets
    end
  end
end
