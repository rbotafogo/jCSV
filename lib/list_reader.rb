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
  
  class CLR < org.supercsv.io.CsvListReader
    include_package "org.supercsv.cellprocessor.ift"
    include_package "org.supercsv.exception"
    include_package "org.supercsv.util"
    include_package "org.supercsv.io"
    include ICsvListReader

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read(filters)
      (filters == false)? super() : super(filters.values.to_java(CellProcessor))
    end

  end
    
  #========================================================================================
  #
  #========================================================================================

  class ListReader < Reader
    include_package "java.io"
    include_package "org.supercsv.cellprocessor.ift"
    include_package "org.supercsv.io"
    include_package "org.supercsv.prefs"

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read_chunk

      return (@reader.read(@filters)).to_a if @chunk_size == 1
      
      rows = Array.new
      (1..@chunk_size).each do |i|
        if ((row = @reader.read(@filters)).nil?)
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

    private

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def new_reader(preferences)

      begin
        @reader = CLR.new(FileReader.new(@filename), preferences);
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
