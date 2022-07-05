# frozen_string_literal: true

require_relative 'directory_content'

class Command
  COLUMN_NUMBER = 3
  SPACES_BTWN_ROWS = 6

  def initialize(opts)
    @opts = opts
    @filenames = filenames
    return unless long?

    @directory_contents = generate_directory_contents(@filenames)
    contents_stats = @directory_contents.map(&:stat)
    @max_stat_sizes = build_max_stat_sizes(contents_stats)
    @total_block = build_total_block(contents_stats)
  end

  def exec
    long? ? print_long_format(@max_stat_sizes) : print_short_format
  end

  private

  def generate_directory_contents(filenames)
    filenames.each_with_object([]) do |filename, files|
      files << DirectoryContent.new(filename)
    end
  end

  def print_short_format
    filenames = reverse? ? @filenames.reverse : @filenames
    row_number = (filenames.size / COLUMN_NUMBER).ceil
    max_length = filenames.map(&:size).max
    lines = Array.new(row_number) { [] }
    filenames.each_with_index do |filename, index|
      line_number = index % row_number
      lines[line_number].push(filename.ljust(max_length + SPACES_BTWN_ROWS))
    end
    lines.each { |line| puts line.join }
  end

  def print_long_format(max_stat_sizes)
    directory_contents = reverse? ? @directory_contents.reverse : @directory_contents
    puts "total #{@total_block}"
    directory_contents.each do |content|
      puts content.show(max_stat_sizes)
    end
  end

  def filenames
    all? ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
  end

  def build_max_stat_sizes(stats)
    {
      nlink: stats.map { |stat| stat[:nlink].size }.max,
      user: stats.map { |stat| stat[:user].size }.max,
      group: stats.map { |stat| stat[:group].size }.max,
      size: stats.map { |stat| stat[:size].size }.max
    }
  end

  def build_total_block(stats)
    stats.map { |stat| stat[:blocks] }.sum
  end

  def reverse?
    @opts['r']
  end

  def long?
    @opts['l']
  end

  def all?
    @opts['a']
  end
end
