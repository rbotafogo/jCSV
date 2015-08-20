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
    attr_reader :type
    attr_reader :surrounding_space_need_quotes
    attr_reader :quote_char
    
    attr_reader :rows
    attr_reader :headers

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def initialize(filename,
                   col_sep: ",",
                   comment_starts: false,
                   comment_matches: false,
                   default_filter: Jcsv.optional,
                   headers: false,
                   ignore_empty_lines: true,
                   type: :list,
                   surrounding_space_need_quotes: false,
                   quote_char: "\"")
      
      @filename = filename
      @col_sep = col_sep
      @comment_starts = comment_starts
      @comment_matches = comment_matches
      @default_filter = default_filter
      @headers = headers
      @ignore_empty_lines = ignore_empty_lines
      @type = type
      @surrounding_space_need_quotes = surrounding_space_need_quotes
      @quote_char = quote_char
      
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

      # if headers then read them
      @mapping = @headers = @reader.getHeader(true).to_a if @headers 
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def filters=(filters)
      
      @filters = Hash.new
      
      case filters
      when Hash
        if (@headers)
          # by default, all columns are required
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
        raise "One filter needed for each column.  Filters size: #{filters.size}"
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
    
    def read(&block)
      parse_all(&block)
      self
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
        @rows = Array.new
        parse_with_block do |line_no, row_no, row, headers|
          @rows << row
        end
        return @rows
      else
        parse_with_block(&block)
      end
      
    end
    
  end

end

require_relative 'list_reader'
require_relative 'map_reader'
