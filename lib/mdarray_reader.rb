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

require 'mdarray'

class Jcsv

  #========================================================================================
  #
  #========================================================================================
  
  class MDArrayReader < MapReader
    include_package "java.io"

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def initialize(*params)

      filter = nil
      
      @dtype = params[1].delete(:dtype)
      
      case @dtype
      when :byte, :short, :int
        filter = Jcsv.int
      when :long
        filter = Jcsv.long
      when :float, :double
        filter = Jcsv.double
      else
        raise "Cannot create MDArray of dtype '#{@dtype}'"
      end
      
      params[1][:default_filter] = filter
      super(*params)
      
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read
      to_mdarray(@dtype, super)
    end

    #---------------------------------------------------------------------------------------
    # Converts the data to an MDArray
    #---------------------------------------------------------------------------------------

    def to_mdarray(dtype, storage)

      raise "Cannot convert deep map into MDArray" if (@deep_map == true)
      
      prod = nil
      shape = []
      
      columns = @column_mapping.mapping - [true, false, nil]
      
      @dimensions.dimensions_names.each do |name|
        keys = @dimensions[name].labels.keys
        shape << keys.size
        prod = (prod.nil?)? keys : prod.product(keys)
      end
      
      header_size = columns.size
      shape << header_size
      vector = Array.new
      
      prod.each do |k|
        row = storage[k.flatten.join(".")]
        vector.concat(((row.nil?)? ([Float::NAN] * header_size) : row.values))
      end

      array = MDArray.build(@dtype, shape, vector)
      
    end
    
  end
  
end
