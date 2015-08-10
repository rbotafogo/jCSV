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
  include_package "java.io"
  include_package "org.supercsv.cellprocessor"
  include_package "org.supercsv.cellprocessor.constraint"
  include_package "org.supercsv.io"
  include_package "org.supercsv.cellprocessor.ift"
  include_package "org.supercsv.prefs"
  include_package "org.supercsv.comment"

  attr_reader :builder
  
  #---------------------------------------------------------------------------------------
  # read the whole file at once
  # Accepts the following options:
  # @param comment_starts: character at the beginning of the line that marks a comment
  # @param comment_matches: delimiters that match a comment, needs to comment at the beginning and
  # end of the comment, such as <!.*!>, comments everyting between <! and !>
  # @param quote_char The quote character (used when a cell contains special characters,
  # such as the delimiter char, a quote char, or spans multiple lines).
  # @param col_sep the delimiter character (separates each cell in a row).
  # @param surrounding_spaces_need_quotes Whether spaces surrounding a cell need quotes in
  # order to be preserved. The default value is false (quotes aren't required). 
  # @param ignore_empty_lines Whether empty lines (i.e. containing only end of line symbols)
  # are ignored. The default value is true (empty lines are ignored).
  # @param type Type of result, either a list or a map.
  #---------------------------------------------------------------------------------------
  
  def self.read(filename,
                col_sep: ",",
                comment_starts: false,
                comment_matches: false,
                headers: nil,
                ignore_empty_lines: true,
                type: :list,
                surrounding_space_need_quotes: false,
                quote_char: "\"",
                &block)

    @builder = CsvPreference::Builder.new(quote_char.to_java(:char), col_sep.ord, "\n")
    @builder.skipComments(CommentStartsWith.new(comment_starts)) if comment_starts
    @builder.skipComments(CommentMatches.new(comment_matches)) if comment_matches
    @builder.ignoreEmptyLines(ignore_empty_lines)
    @builder.surroundingSpacesNeedQuotes(surrounding_space_need_quotes)
    
    preferences = @builder.build
    parser = Jcsv.new(filename, preferences, type: type)
    parser.send(:parse_all, &block)
      
  end

  #---------------------------------------------------------------------------------------
  # @param end_of_line_symbols The end of line symbols to use when writing (Windows, Mac
  # and Linux style line breaks are all supported when reading, so this preference won't be
  # used at all for reading).
  # @param encoder Use your own encoder when writing CSV. See the section on custom
  # encoders below.
  # quoteMode
  # Allows you to enable surrounding quotes for writing (if a column wouldn't normally be
  # quoted because it doesn't contain special characters). See the section on quote modes below.
  #---------------------------------------------------------------------------------------

  def self.write

  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------
  
  def initialize(filename, preferences, type:)
    
    @filename = filename
    @type = type
    @processors = Array.new

    begin
      case type
      when :list
        @reader = CsvListReader.new(FileReader.new(@filename), preferences);
      when :map
        @reader = CsvMapReader.new(FileReader.new(@filename),
                                   CsvPreference::STANDARD_PREFERENCE);
      else
        raise "Wrong type for reading CSV file: #{type}"
      end
      
    rescue java.io.IOException => e
      p e
    end

    
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  private
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def parse_all(&block)

    if (!block_given?)
      rows = Array.new
      parse_with_block do |row|
        rows << row
      end
      return rows
    else
      parse_with_block(&block)
    end

  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def parse_with_block(&block)

    while ((row = @reader.read) != nil)
      block.call(row.to_a)
    end
    
  end
  
end
  

