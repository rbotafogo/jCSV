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
        raise "'true' is not allowed as a mapping: #{column_mapping}" if name == true
        @column_mapping.mapping[i] = (name.nil?)? h : name
      end

    end
    
    #---------------------------------------------------------------------------------------
    # read the file.
    #---------------------------------------------------------------------------------------
    
    def read(&block)

      # When no block given, chunks read are stored in an array and returned to the user.
      if (!block_given?)
        @rows = Array.new
        if (@dimensions && @deep_map == true && @chunk_size > 0)
          parse_with_block do |line_no, row_no, chunk|
            map ||= {}
            chunk.each do |row|
              key = row[:key].dup
              key.reduce(map) { |h,m| h[m] ||= {} }
              last = key.pop
              if (key.inject(map, :fetch)[last] != {})
                # p "overriding value for key: #{chunk[:key]} with #{chunk}"
                raise "Key #{row[:key]} not unique for this dataset. #{row}"
              end
              key.inject(map, :fetch)[last] = row
            end
            @rows << map
          end
        else
          # parse_with_block do |line_no, row_no, chunk, headers|
          parse_with_block do |line_no, row_no, chunk|
            @rows << chunk
          end
        end
        @rows
      else
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
        raise "Reading file as map requires headers." if !@headers
        @reader = CMR.new(FileReader.new(@filename), preferences, @dimensions,
                          @suppress_errors)
      rescue java.io.IOException => e
        p e
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

  end

end
