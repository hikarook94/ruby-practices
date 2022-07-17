# frozen_string_literal: true

require 'etc'

class DirectoryContent
  attr_reader :stat

  MODE_MAP = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  def initialize(name)
    @name = name
    @stat = build_stat(name)
  end

  def show(max_stat_sizes)
    [
      @stat[:type],
      @stat[:permission],
      " #{@stat[:nlink].rjust(max_stat_sizes[:nlink])}",
      " #{@stat[:user].ljust(max_stat_sizes[:user])}",
      " #{@stat[:group].ljust(max_stat_sizes[:group])}",
      " #{@stat[:size].rjust(max_stat_sizes[:size])}",
      " #{@stat[:time]}",
      " #{@stat[:name]}"
    ].join
  end

  private

  def build_stat(name)
    file_stat = File::Stat.new(name)
    {
      type: format_type(file_stat),
      permission: format_permissions(file_stat.mode).join,
      nlink: file_stat.nlink.to_s,
      user: Etc.getpwuid(file_stat.uid).name,
      group: Etc.getgrgid(file_stat.gid).name,
      size: file_stat.size.to_s,
      time: format_mtime(file_stat.mtime),
      name: name,
      blocks: file_stat.blocks
    }
  end

  def format_type(file_stat)
    file_stat.directory? ? 'd' : '-'
  end

  def format_permissions(file_stat_mode)
    permission_digits = file_stat_mode.to_s(8)[-3..].split(//)
    permission_digits.map { |n| MODE_MAP[n] }
  end

  def format_mtime(file_stat_mtime)
    file_stat_mtime.strftime('%m %d %H:%M')
  end
end
