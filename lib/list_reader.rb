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

require_relative "supercsv_interface"

class Jcsv
  
  #========================================================================================
  #
  #========================================================================================
  
  class ListReader < Reader
    include_package "java.io"

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read_chunk

      return @reader.read(@column_mapping, @filters).to_a if @chunk_size == 1
      
      rows = Array.new
      (1..@chunk_size).each do |i|
        if ((row = @reader.read(@column_mapping, @filters)).nil?)
          break
        else
          rows << row.to_a
        end
      end
      rows
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def mapping=(map)
      
      @column_mapping.map = Array.new
      # @filters = Hash.new
      
      case map
      when Hash
        i = 0
        @headers.each_with_index do |column_name, index|
          if map[column_name.to_sym].nil?
            @column_mapping.mapping[index] = i
            i += 1
          else
            @column_mapping.mapping[index] = false
          end
        end
      when Array
        raise "Mapping size needs to be identical to the number of columns" if
          headers && (headers.size != map.size)
        @column_mapping.map = map
      else
        raise "Filters parameters should either be a hash or an array of filters"
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
        @reader = CLR.new(FileReader.new(@filename), preferences)
      rescue java.io.IOException => e
        p e
      end
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def parse_with_block(&block)

      while ((chunk = read_chunk).size != 0)
        block.call(@reader.getLineNumber(), @reader.getRowNumber(), chunk, @headers)
      end
      
    end

  end
  
end
