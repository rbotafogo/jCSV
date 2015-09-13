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
  
  class VectorReader < ListReader
    include_package "java.io"

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def initialize(*params)

      type = params[1].delete(:type)
      # creating default double... need to make it the proper type
      params[1][:default_filter] = Jcsv.int
      super(*params)

    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read(&block)

      buffer = Array.new
      lines = 0

      raise "Reading into a vector does not support block" if block_given?
      parse_with_block do |line_no, row_no, row, headers|
        
        buffer.concat(row)
        # buffer << row
        lines = row_no
        
      end

      p @reader.dimensions.shape
      # p @reader.dimensions.dimensions[:patient]
 
      # [[lines-1, headers.size-1], buffer]
      buffer
      
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def each(&block)
      raise "Reading into a vector does not support each"
    end
    
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def self.read_file(filename, options = {})

    table = SmarterCSV.process(filename, options) do |array|
      row = array[0]
      headers ||= row.keys
      # columns is initialized with the first row.size
      columns ||= row.size
      
      lines += 1
      # every row should have the same number of columns
      if (row.size != columns)
        raise "Data does not have the same number of columns for all lines"
      end

      # delete dimensions from data and store them on their proper dimension
      dimensions_names.each do |name|
        dimensions[name] = row.delete(name)
      end
      
      row.each_pair do |key, val|
        # if it is a Date, then convert it to seconds since epoch
        p key
        p val
        # if (Date.parse(val))
          #buffer << val.to_time.to_i
          # if it is numeric then just add it to the buffer
        if (val.is_a? Numeric)
          buffer << val
        #else
         # raise "Value must be either a 'date' or 'numeric': #{val}"
        end
        
      end
      
    end

    dimensions.dimensions["Columns"] = headers
    p dimensions.dimensions["Columns"]
    p buffer
    
  end
  
end
