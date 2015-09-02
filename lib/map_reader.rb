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
  include_package "org.supercsv.cellprocessor.ift"

  #========================================================================================
  #
  #========================================================================================

  class MapReader < Reader
    include_package "java.io"
    include_package "org.supercsv.cellprocessor.ift"
    include_package "org.supercsv.io"
    include_package "org.supercsv.prefs"

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def initialize(*params)
      super(*params)
      @processed_columns = Hash.new
      @column_mapping.map = @headers
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read_chunk

      return _read.to_a if @chunk_size == 1
      
      rows = Array.new
      (1..@chunk_size).each do |i|
        if ((row = _read).nil?)
          break
        else
          rows << row.to_a
        end
      end
      rows

    end

    #---------------------------------------------------------------------------------------
    # Maps columns to the given names
    #---------------------------------------------------------------------------------------

    def mapping=(column_mapping)

      map = Array.new
      
      @headers.each do |h|
        name = column_mapping[h]
        if (name.nil?)
          map << h
        elsif (name == :false)
          map << nil
        else
          map << name
        end
        # map << ((name_mapping[h].nil?)? h : name_mapping[h])
      end
      
      @column_mapping = map
      
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
        # if there is a proper mapping should also work... FIX!!
        raise "Reading file as map requires headers." if !@headers
        @reader = CMR.new(FileReader.new(@filename), preferences);
      rescue java.io.IOException => e
        p e
      end

    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def parse_with_block(&block)
      
      while ((row = @reader.read(@mapping, @filters)) != nil)
        block.call(@reader.getLineNumber(), @reader.getRowNumber(), row, @headers)
      end
      
    end

  end

end
