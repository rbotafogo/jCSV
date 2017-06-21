# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
# Copyright © 2015 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

require_relative '../config'
require_relative 'exceptions.rb'
require_relative 'filters'
require_relative 'reader'

# Ignoring surrounding spaces if they're not within quotes
# In accordance with RFC 4180, the default behaviour of Super CSV is to treat all spaces
# as important, including spaces surrounding the text in a cell.
#
# This means for reading, a cell with contents    surrounded by spaces    is read with
# surrounding spaces preserved. And for writing, the same String is written with surrounding
# spaces and no surrounding quotes (they're not required, as spaces are considered important).
#
# There are some scenarios where this restriction must be relaxed, in particular when the CSV
# file you're working with assumes that surrounding spaces must be surrounded by quotes,
# otherwise will be ignored. For this reason, Super CSV allows you to enable the
# surrounding_spaces_need_quotes preference.
#
# With surrounding_spaces_need_quotes enabled, it means that for reading, a cell with contents
# '    surrounded by spaces   ' would be read as 'surrounded by spaces' (surrounding spaces
# are trimmed), unless the String has surrounding quotes, e.g. "   surrounded by spaces   ",
# in which case the spaces are preserved. And for writing, any String containing surrounding
# spaces will automatically be given surrounding quotes when written in order to preserve
# the spaces.
#
# You can enable this behaviour by calling surrounding_spaces_need_quotes(true) on the Builder.
# You can do this with your own custom preference, or customize an existing preference

# Skipping comments
# Although comments aren't part of RFC4180, some CSV files use them so it's useful to be able
# to skip these lines (or even skip lines because they contain invalid data). You can use one
# of the predefined comment matchers:
#
# CommentStartsWith - matches lines that start with a specified String
# CommentMatches - matches lines that match a specified regular expression
# Or if you like you can write your own by implementing the CommentMatcher interface.

class Jcsv  
  include_package "org.supercsv.cellprocessor.ift"

  attr_reader :reader
  
  #---------------------------------------------------------------------------------------
  # @param end_of_line_symbols The end of line symbols to use when writing (Windows, Mac
  # and Linux style line breaks are all supported when reading, so this preference won't be
  # used at all for reading).
  # @param encoder Use your own encoder when writing CSV. See the section on custom
  # encoders below.
  # quoteMode
  # Allows you to enable surrounding quotes for writing (if a column wouldn't normally be
  # quoted because it doesn't contain special characters).
  #---------------------------------------------------------------------------------------

  def self.write

  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def self.reader(*params)

    format = params[1]? params[1][:format] : :list
    
    case format
    when :map, :critbit
      @reader = Jcsv::MapReader.new(*params)
    when :mdarray
      @reader = Jcsv::MDArrayReader.new(*params)
    else
      @reader = Jcsv::ListReader.new(*params)
    end
    
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------
  
  def filters=(filters)
    @reader.filters=(filters)
  end
  
end
