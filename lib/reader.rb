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

class Jcsv
  
  #========================================================================================
  #
  #========================================================================================
  
  class Reader
    include_package "org.supercsv.cellprocessor.ift"
    include_package "org.supercsv.prefs"
    include_package "org.supercsv.comment"
    
    attr_reader :col_sep
    attr_reader :comment_starts
    attr_reader :comment_matches
    attr_reader :ignore_empty_lines
    attr_reader :format
    attr_reader :surrounding_space_need_quotes
    attr_reader :quote_char
    
    attr_reader :rows
    attr_reader :headers
    attr_reader :mapping
    attr_reader :processed_column   # last processed column
    attr_reader :name_mapping

    #---------------------------------------------------------------------------------------
    # Accepts the following options:
    # @param comment_starts: character at the beginning of the line that marks a comment
    # @param comment_matches: delimiters that match a comment, needs to comment at the beginning
    # and end of the comment, such as <!.*!>, comments everyting between <! and !>
    # @param quote_char The quote character (used when a cell contains special characters,
    # such as the delimiter char, a quote char, or spans multiple lines).
    # @param col_sep the delimiter character (separates each cell in a row).
    # @param surrounding_spaces_need_quotes Whether spaces surrounding a cell need quotes in
    # order to be preserved. The default value is false (quotes aren't required). 
    # @param ignore_empty_lines Whether empty lines (i.e. containing only end of line symbols)
    # are ignored. The default value is true (empty lines are ignored).
    # @param format Format of result, list, map, vector.
    #---------------------------------------------------------------------------------------
    
    def initialize(filename,
                   col_sep: ",",
                   comment_starts: false,
                   comment_matches: false,
                   default_filter: Jcsv.optional,
                   headers: false,
                   ignore_empty_lines: true,
                   format: :list,
                   surrounding_space_need_quotes: false,
                   quote_char: "\"",
                   chunk_size: 1)
      
      @filename = filename
      @col_sep = col_sep
      @comment_starts = comment_starts
      @comment_matches = comment_matches
      @default_filter = default_filter
      @headers = headers
      @ignore_empty_lines = ignore_empty_lines
      @format = format
      @surrounding_space_need_quotes = surrounding_space_need_quotes
      @quote_char = quote_char
      @chunk_size = chunk_size
      
      @rows = nil
      @filters = false

      # Prepare preferences
      @builder = CsvPreference::Builder.new(quote_char.to_java(:char), col_sep.ord, "\n")
      @builder.skipComments(CommentStartsWith.new(comment_starts)) if comment_starts
      @builder.skipComments(CommentMatches.new(comment_matches)) if comment_matches
      @builder.ignoreEmptyLines(ignore_empty_lines)
      @builder.surroundingSpacesNeedQuotes(surrounding_space_need_quotes)
      
      # create a new reader with the proper preferences
      new_reader(@builder.build)

      @column_mapping = Mapping.new
      # if headers then read them and initialize the @column_mapping the same as the
      # headers
      @headers = @reader.getHeader(true).to_a if @headers
      
    end

    #---------------------------------------------------------------------------------------
    # read the whole file at once if no block given
    #---------------------------------------------------------------------------------------
    
    def read(&block)

      if (!block_given?)
        @rows = Array.new
        parse_with_block do |line_no, row_no, row, headers|
          @rows << row
        end
        @rows
      else
        parse_with_block(&block)
      end
      
    end
        
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def each(&block)
      
      if (!block_given?)
        to_enum
      else
        parse_with_block(&block)
      end
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def filters=(filters)
      
      @filters = Hash.new
      
      case filters
      when Hash
        if (@headers)
          # set all column filters to the @default_filter
          @headers.each do |column_name|
            @filters[column_name] = @default_filter
          end
          
          filters.each do |column_name, processor|
            column_name = column_name.to_s if column_name.is_a? Symbol
            @filters[column_name] = processor
          end
        else
          raise "CSV file does not have headers.  Cannot match filters with headers"
        end
      when Array
        raise "One filter needed for each column.  Filters size: #{filters.size}" if
          headers && (headers.size != filters.size)
        filters.each_with_index do |processor, i|
          @filters[i] = processor
        end
      else
        raise "Filters parameters should either be a hash or an array of filters"
      end
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def mapping=(map)
      @column_mapping.map = map
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    private
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read_chunk

      return @reader.read(@column_mapping, @filters) if @chunk_size == 1
      
      rows = Array.new
      (1..@chunk_size).each do |i|
        if ((row = @reader.read(@column_mapping, @filters)).nil?)
          break
        else
          # rows << row.to_a
          rows << row
        end
      end
      (rows.size == 0)? nil : rows
      
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def parse_with_block(&block)

      while (!((chunk = read_chunk).nil?))
        block.call(@reader.getLineNumber(), @reader.getRowNumber(), format(chunk), @headers)
      end
      
    end
    
  end
  
end

require_relative 'list_reader'
require_relative 'map_reader'
require_relative 'vector_reader'
