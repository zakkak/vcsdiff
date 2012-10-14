#!/usr/bin/env ruby

################################################################################
#                                                                              #
# File: vcsdiff.rb                                                             #
#                                   ++++++++++++++++++++++++++++++             #
# Copyright (C) 2012                + Author:  Foivos S. Zakkak  +             #
#                                   + Website: foivos.zakkak.net +             #
#                                   + Email:   foivos@zakkak.net +             #
#                                   ++++++++++++++++++++++++++++++             #
#                                                                              #
# Based on the script svnvimdiff, written by                                   #
#   Geoff Buchan  <geoffrey.buchan@gmail.com>                                  #
#                                                                              #
# This program is free software: you can redistribute it and/or modify         #
# it under the terms of the GNU General Public License as published by         #
# the Free Software Foundation, either version 3 of the License, or            #
# (at your option) any later version.                                          #
#                                                                              #
# This program is distributed in the hope that it will be useful,              #
# but WITHOUT ANY WARRANTY; without even the implied warranty of               #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                #
# GNU General Public License for more details.                                 #
#                                                                              #
# You should have received a copy of the GNU General Public License            #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.        #
#                                                                              #
################################################################################

require 'optparse'
require 'ftools'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = %'Usage: #{opts.program_name} [OPTIONS] -- [DIFF OPTIONS]'
  opts.separator ''
  opts.separator 'Options'

  options[:files] = Array.new
  opts.on('-f','--file FILE',Array,'Define the file/files you want to diff',
          '(you can use it more than once',
          'or seperate the filenames with commas)') do |f|
    options[:files]+=f
  end

  avail_sys = %w[svn hg git]
  opts.on('-s','--system NAME',avail_sys,
          'Define the version control system you are using',
          "(#{avail_sys.join(',')})",
          "if not given, #{opts.program_name} tries to automatically detect it"
          ) do |s|
    options[:sys]=s
  end

  avail_diff = %w[vimdiff kompare]
  options[:diff]="vimdiff"
  opts.on('-t','--tool NAME',avail_diff,
          'Define the prefered diff visualization tool',
          "(#{avail_diff.join(',')})",
          'defaults to vimdiff') do |t|
    options[:diff]=t
  end
  
  opts.separator ''
  opts.separator 'Diff options:'
  opts.separator 'All diff options are passed to svn/git/hg diff'
  opts.separator ''
  opts.separator 'Common options:'

  opts.on_tail('-h','--help','Show this message') do
    puts option_parser
    exit 0;
  end
end

begin
  option_parser.parse!(ARGV)
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts option_parser
  exit 1;
end

if options[:sys].length == 0
#   TODO: implement auto detection
  options[:sys]="svn"
end

# if the user didn't specify any arguments go through each file in the directory
if options[:files].length == 0
#   FIXME: works only for svn and hg like this
  modified=%x[#{options[:sys]} status 2> /dev/null | grep -e "^[MU]" | awk '{print $2}']
  modified.split(%r[\n]).each do |f|
    options[:files].push(f) if File.file?(f)
  end
end

patch="/tmp/svnkomp_747_patch"
remote=""

options[:files].each do |f|
  remote="/tmp/"+f
  %x[cp #{f} #{remote}]
  %x[#{options[:sys]} diff #{ARGV.join(" ")} #{f} > #{patch}]
  if !($?.success?)
    exit 1;
  end
  %x[patch -R -p0 #{remote} #{patch}]
  %x[#{options[:diff]} #{remote} #{f}]
  File.delete(remote)
end

at_exit do
  %x[rm -rf #{remote} #{patch}]
end
