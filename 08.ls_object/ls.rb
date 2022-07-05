#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/command'
require 'optparse'

Command.new(ARGV.getopts('alr')).exec
