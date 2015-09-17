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

require_relative 'dimensions'

class Jcsv
  
  #========================================================================================
  #
  #========================================================================================
  
  class Reader
    include_package "org.supercsv.cellprocessor.ift"
    include_package "org.supercsv.prefs"
    include_package "org.supercsv.comment"

    # Reader configuration parameters
    attr_reader :filename
    attr_reader :col_sep
    attr_reader :comment_starts
    attr_reader :comment_matches
    attr_reader :ignore_empty_lines
    attr_reader :surrounding_space_need_quotes
    attr_reader :quote_char
    attr_reader :strings_as_keys
    attr_reader :format             # output format: list, map, vector, others...

    # chunk_size can be changed on the fly
    attr_accessor :chunk_size
    
    attr_reader :headers
    attr_reader :column_mapping
    attr_reader :dimensions_names
    
    # last processed column
    attr_reader :processed_column   

    # Rows read.  Returned when reading a chunk of data
    attr_reader :rows

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
                   ignore_empty_lines: true,
                   surrounding_space_need_quotes: false,
                   quote_char: "\"",
                   default_filter: Jcsv.optional,
                   strings_as_keys: false,
                   format: :list,
                   headers: false,
                   chunk_size: 1,
                   dimensions: nil)
      
      @filename = filename
      @col_sep = col_sep
      @comment_starts = comment_starts
      @comment_matches = comment_matches
      @default_filter = default_filter
      @strings_as_keys = strings_as_keys
      @headers = headers
      @ignore_empty_lines = ignore_empty_lines
      @format = format
      @surrounding_space_need_quotes = surrounding_space_need_quotes
      @quote_char = quote_char
      @chunk_size = chunk_size
      @dimensions_names = dimensions

      prepare_dimensions if dimensions
      
      # set all preferences.  To create a new reader we need to have the dimensions already
      # prepared as this information will be sent to supercsv for processing.
      new_reader(set_preferences)
      # Convert headers to lower case symbols
      prepare_headers if @headers
      
      # if headers then read them
      # @headers = @reader.headers if @headers

      # initialize filters with the default filter
      init_filters

      @column_mapping = Mapping.new
      @rows = nil
            
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
    # Initialize filters with the default_filter.  Only possible if the file has headers.
    #---------------------------------------------------------------------------------------

    def init_filters

      @filters = Hash.new

      if (@headers)
        # set all column filters to the @default_filter
        @headers.each do |column_name|
          @filters[column_name] = @default_filter
        end
      end
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def filters=(filters)

      
      case filters
      when Hash
        filters = filters.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} unless
          @strings_as_keys
        if (@headers)
          filters.each do |column_name, processor|
            # column_name = column_name.to_s if column_name.is_a? Symbol
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

    def dimensions
      @reader.dimensions
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

      # p "read_chunk with size: #{@chunk_size}"
      
      rows = Array.new
      (1..@chunk_size).each do |i|
        if ((row = @reader.read(@column_mapping, @filters)).nil?)
          break
        else
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
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def set_preferences
      
      # Prepare preferences
      builder = CsvPreference::Builder.new(@quote_char.to_java(:char), @col_sep.ord, "\n")
      builder.skipComments(CommentStartsWith.new(@comment_starts)) if @comment_starts
      builder.skipComments(CommentMatches.new(@comment_matches)) if @comment_matches
      builder.ignoreEmptyLines(@ignore_empty_lines)
      builder.surroundingSpacesNeedQuotes(@surrounding_space_need_quotes)
      builder.build
      
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def prepare_headers

      # Read headers
      @headers = @reader.headers

      # Convert headers to symbols, unless user specifically does not want it
      @headers.map! { |head| head.downcase.to_sym } unless @strings_as_keys
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def prepare_dimensions

      if ((!@dimensions_names.nil?) && (@dimensions_names.size != 0))
        @dimensions_names.map! { |x| x.downcase.to_sym } # unless params[:strings_as_keys] || options[:keep_original_headers]
        @dimensions = Dimensions.new(@dimensions_names)
      end
      
      # Build mapping for the dimensions: dimensions need to map to true
      map = Hash.new
      @dimensions.each do |dim|
        map[dim.name] = true
      end
      
    end

  end
  
end

require_relative 'list_reader'
require_relative 'map_reader'
require_relative 'vector_reader'
