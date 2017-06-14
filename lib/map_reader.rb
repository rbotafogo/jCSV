# -*- coding: utf-8 -*-

##########################################################################################
# author Rodrigo Botafogo
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

require 'critbit'

class Jcsv

  #========================================================================================
  #
  #========================================================================================

  class MapReader < Reader
    include_package "java.io"

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def initialize(*params)
      super(*params)
      @column_mapping.mapping = @headers if !@dimensions
      @map_klass = (@format == :map)? Hash : Critbit
    end
    
    #---------------------------------------------------------------------------------------
    # Maps columns to the given names.  In map reader, there is no column reordering, as
    # this does not really make any sense, since one gets to the data through the key and
    # not through its position in the array.  If there are dimensions set, then every
    # dimension will map to true, in order for it to be properly processed by the parsing
    # method. Other fields can still be mapped to false, so that they are not read if
    # desired.
    #---------------------------------------------------------------------------------------

    def mapping=(column_mapping)

      @column_mapping.mapping ||= Array.new
      
      @headers.each_with_index do |h, i|
        next if @dimensions && !@dimensions[h].nil?
        name = column_mapping[h]
        raise ArgumentError.new("'true' is not allowed as a mapping: #{column_mapping}") if
          name == true
        @column_mapping.mapping[i] = (name.nil?)? h : name
      end

    end
    
    #---------------------------------------------------------------------------------------
    # read the file.
    #---------------------------------------------------------------------------------------
    
    def read(&block)

      # When no block given, chunks read are stored in an array and returned to the user.
      if (!block_given?)
        # if dimensions and chunk_size is 0, then do not wrap each row in an array, we
        # can access the data directly by using the dimension key
        if (@dimensions && @chunk_size == 0)
          rows = @map_klass.new
          parse_with_block do |line_no, row_no, chunk|
            rows.merge!(chunk)
          end
        else
          # chunk_size > 0, then each chunk should be a hash, and all chunks should
          # be wrapped inside an array
          rows = []
          parse_with_block do |line_no, row_no, chunk|
            rows << chunk
          end
        end
        rows
      else # block given
        parse_with_block(&block)
      end
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    private
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def new_reader(preferences)
      
      begin
        raise MissingHeadersError.new("Reading file as map requires headers.") if
          (!@headers && !@custom_headers)
        @reader = CMR.new(FileReader.new(@filename), preferences, @dimensions,
                          @suppress_warnings, @subtotals)
      rescue java.io.IOException => e
        raise IOError.new(e.message)
      end

    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def format(chunk)
      chunk
    end
    
    #---------------------------------------------------------------------------------------
    # Maps columns to the given names.  In map reader, there is no column reordering, as
    # this does not really make any sense, since one gets to the data through the key and
    # not through its position in the array.  If there are dimensions set, then every
    # dimension will map to true, in order for it to be properly processed by the parsing
    # method. Other fields can still be mapped to false, so that they are not read if
    # desired.
    #---------------------------------------------------------------------------------------

    def assign_mapping(column_mapping)

      @column_mapping.mapping ||= Array.new
      
      @headers.each_with_index do |h, i|
        name = column_mapping[h]
        @column_mapping.mapping[i] = (name.nil?)? h : name
      end

    end
    
    #---------------------------------------------------------------------------------------
    # A chunk is either one row of the file, or an array with rows.  One row can be either
    # a one dimensional array with all columns or a hash with all columns (excluding the
    # dimensions).
    #---------------------------------------------------------------------------------------

    def read_chunk

      if (@dimensions)
        if (@chunk_size == 0)
          row = @reader.read(@column_mapping, @filters)
          return (row.nil?)? nil : { row.delete(:key).join(".") => row }
        end

        rows = {}
        (1..@chunk_size).each do |i|
          if ((row = @reader.read(@column_mapping, @filters)).nil?)
            return (rows.size == 0)? nil : rows
          else
            if (@deep_map)
              key = row.delete(:key)
              key.reduce(rows) { |h,m| h[m] ||= {} }
              last = key.pop
              if (key.inject(rows, :fetch)[last] != {})
                # p "overriding value for key: #{chunk[:key]} with #{chunk}"
                raise DuplicateKeyError.new("Key #{row[:key]} not unique for this dataset. #{row}")
              end
              key.inject(rows, :fetch)[last] = row
            else # not a deep map
              key = row.delete(:key).join(".")
              raise DuplicateKeyError.new("Key #{key} not unique for this dataset. #{row}") if
                rows.has_key?(key)
              rows.merge!({key => row})
            end
          end
        end
        return rows
      else # no dimensions
        super
      end
    end
      
  end
    
end
