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

  class MapReader < Reader
    include_package "java.io"

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def initialize(*params)
      super(*params)
      @column_mapping.map = @headers if !@dimensions
      # p @column_mapping
    end
    
    #---------------------------------------------------------------------------------------
    # Maps columns to the given names.  In map reader, there is no column reordering, as
    # this does not really make any sense, since one gets to the data through the key and
    # not through its position in the array.
    #---------------------------------------------------------------------------------------
    
    def mapping=(column_mapping)
      
      map = Array.new
      
      @headers.each do |h|
        name = column_mapping[h]
        if (name.nil?)
          map << h
        #elsif (name == :false)
        #  map << nil
        else
          map << name
        end
        # map << ((name_mapping[h].nil?)? h : name_mapping[h])
      end
      
      @column_mapping.map = map
      
    end
    
    #---------------------------------------------------------------------------------------
    # read the whole file at once if no block given
    #---------------------------------------------------------------------------------------
    
    def read(&block)

      # When no block given, chunks read are stored in an array and returned to the user.
      if (!block_given?)
        if (@dimensions)
          @rows ||= {}
          # If chunk size is > 1 this will not work as the key is the last key and not a key
          # for each element of the chunk... WHAT SHOULD BE DONE!!!
          parse_with_block do |line_no, row_no, ck, headers|
            ck.each do |chunk|
              key = chunk[0].chomp(".")
              key.split('.').reduce(@rows) { |h,m| h[m] ||= {} }
              
              *key, last = chunk[0].split(".")
              key.inject(@rows, :fetch)[last] = chunk[1]
            end
          end
        else
          @rows = Array.new
          parse_with_block do |line_no, row_no, chunk, headers|
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
        @reader = CMR.new(FileReader.new(@filename), preferences, @dimensions);
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
    
  end

end

=begin
        @key = @key.chomp(".")
        @key.split('.').reduce(@return_hash) { |h,m| h[m] ||= {} }
        *@key, last = @key.split(".")
        @key.inject(@return_hash, :fetch)[last] = @processed_columns
        
        @return_hash
=end
