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

module JavaIO
  include_package "java.io"
end

##########################################################################################
#
##########################################################################################

class Jcsv
  include_package "com.univocity.parsers.csv"

  class << self
    attr_accessor :converters
  end

  Jcsv.converters = Hash.new
  
  #---------------------------------------------------------------------------------------
  # read the whole file at once
  #---------------------------------------------------------------------------------------

  def self.read(filename, *options)
    parser = Jcsv.new(filename)
    parser.set_options(*options) if options.size > 0
    parser.send(:parse_all)
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def self.foreach(filename, *options, &block)
    parser = Jcsv.new(filename)
    parser.set_options(*options) if options.size > 0
    parser.send(:parse_with_block, &block) if block_given?
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------
  
  def initialize(filename)
    
    @filename = filename
    @settings = CsvParserSettings.new

    begin
      fis = java.io.FileInputStream.new(filename);
      @isr = java.io.InputStreamReader.new(fis);
    rescue java.io.IOException => e
      p e
    end
        
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def set_options(options)
    options.each do |opt, val|
      send(opt, val)
    end
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def col_sep(char = nil)
    (char)?
      @settings.getFormat().setDelimiter(char) :
      @settings.getFormat().getDelimiter()
  end

  def col_sep?(char)
    @settings.getFormat().isDelimiter(char)
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def comment_char(char = nil)
    (char)?
      @settings.getFormat().setComment(char) :
      @settings.getFormat().getComment()
  end

  #---------------------------------------------------------------------------------------
  #  Identifies whether or not a given character represents a comment
  #---------------------------------------------------------------------------------------
  
  def comment_char?(char)
    @settings.getFormat().isComment(char)
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def has_header(bool)
    @settings.headerExtractionEnabled(bool)
  end
    
  #---------------------------------------------------------------------------------------
  # The line separator sequence is defined here to ensure systems such as MacOS and Windows
  # are able to process this file correctly 
  # MacOS uses '\r'; and Windows uses '\r\n'.
  #---------------------------------------------------------------------------------------

  def row_sep(char = nil)
    (char)?
      @settings.getFormat().setLineSeparator(char) :
      @settings.getFormat().getLineSeparator
  end

  #---------------------------------------------------------------------------------------
  # Compares the given character against the normalizedNewline character.
  #---------------------------------------------------------------------------------------
  
  def row_sep?(char)
    @settings.getFormat().isNewLine(char)
  end
  
  def row_sep_string
    @settings.getFormat().getLineSeparatorString()
  end
  
  #---------------------------------------------------------------------------------------
  # Defines the maximum number of characters allowed for any given value being
  # written/read. Used to avoid OutOfMemoryErrors (defaults to 4096).
  #---------------------------------------------------------------------------------------

  def field_size_limit(size)
    @settings.setMaxCharsPerColumn(size)
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def converters(converters)
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def unconverted_fields
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def headers
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def return_headers
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def header_converters
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def skip_blanks
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def force_quotes
  end
  
  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  private

  #---------------------------------------------------------------------------------------
  # Collects all lines as array of fields
  #---------------------------------------------------------------------------------------

  def parse_all

    rows = Array.new
    parse_with_block do |row|
      rows << row
    end
    rows

  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def parse_with_block(&block)

    begin
      # creates a CSV parser
      parser = CsvParser.new(@settings);
      
      # call beginParsing to read records one by one, iterator-style.
      parser.beginParsing(@isr);
      
      while ((str = parser.parseNext()) != nil)
        block.call(str.to_a)
      end
      
      # The resources are closed automatically when the end of the input is reached,
      # or when an error happens, but you can call stopParsing() at any time.
      
      # You only need to use this if you are not parsing the entire content.
      # But it doesn't hurt if you call it anyway.
      parser.stopParsing();

    rescue com.univocity.parsers.common.TextParsingException => e
      p e
      raise "Parsing error"
    end
    
  end
  
end

