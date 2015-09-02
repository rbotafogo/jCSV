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

  module Processors
    include_package "org.supercsv.util"
    
    #---------------------------------------------------------------------------------------
    # This method uses variable @processed_columns that should be initialized in the class
    # that includes this module. In the case of a list_reader for instance, processed_columns
    # is initalized as an Array.  For map_reader, processed_columns is initalized as a
    # Hash.  So, processed_columns is a data structure for storing the data processed.  The
    # mapping defines where the data should be stored in this data structure.  In the case
    # of list_reader, mapping[i] = i, for map_reader, mapping[i] = <mapping name for hash>
    #---------------------------------------------------------------------------------------
    
    def executeProcessors(processors)

      source = getColumns()

      if processors.size == 0
        source.each_with_index do |s, i|
          next if @column_mapping[i] == false
          @processed_columns[@column_mapping[i]] = s
        end
        return @processed_columns
      end
      
      raise "Processos should not be null" if processors == nil
      context = CsvContext.new(getLineNumber(), getRowNumber(), 1);
      context.setRowSource(source);

      raise "The number of columns to be processed #{source.size} must match the number of 
CellProcessors #{processors.length}" if (source.size != processors.length)

      source.each_with_index do |s, i|

        begin
          next if @column_mapping[i] == false
          context.setColumnNumber(i + 1)
          if (processors[i] == nil)
            @processed_columns[@column_mapping[i]] = s
          else
            cell = processors[i].execute(s, context)
            cell = (cell.is_a? Jcsv::Pack)? cell.ruby_obj : cell
            @processed_columns[@column_mapping[i]] = cell
          end
        rescue SuperCsvConstraintViolationException => e
          raise "Contraint violation: #{context.toString}"
        end
        
      end

      @processed_columns
      
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class CLR < org.supercsv.io.CsvListReader
    include_package "org.supercsv.cellprocessor.ift"
    include Processors
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read(column_mapping, filters)

      # initialize @processed_columns to a new Array.  This will be used by method
      # executeProcessor from module Processors
      @processed_columns = Array.new
      @column_mapping = column_mapping
      
      (filters == false)? super([].to_java(CellProcessor)) :
        super(filters.values.to_java(CellProcessor))
      
    end
    
  end

  #========================================================================================
  #
  #========================================================================================

  class CMR < org.supercsv.io.CsvMapReader
    include_package "org.supercsv.cellprocessor.ift"
    include Processors

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read(name_mapping, filters)

      # initialize @processed_columns to a new Hash.  This will be used by method
      # executeProcessor from module Processors
      @processed_columns = Hash.new
      
      (filters == false)? super(*name_mapping) :
        filter_input(name_mapping, filters.values.to_java(CellProcessor))
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def filter_input(name_mapping, processors)

      if (readRow())
        
        processedColumns = Hash.new
        
        source = getColumns()
        raise "Processos should not be null" if processors == nil
        context = CsvContext.new(getLineNumber(), getRowNumber(), 1);
        context.setRowSource(source);
        
        raise "The number of columns to be processed #{source.size} must match the number of 
CellProcessors #{processors.length}" if (source.size != processors.length)
        
        source.each_with_index do |s, i|
          
          begin
            next if name_mapping[i] == nil
            context.setColumnNumber(i + 1)
            if (processors[i] == nil)
              processedColumns[name_mapping[i].to_sym] = s
            else
              cell = processors[i].execute(s, context)
              cell = (cell.is_a? Jcsv::Pack)? cell.ruby_obj : cell
              processedColumns[name_mapping[i].to_sym] = cell
            end
          rescue SuperCsvConstraintViolationException => e
            raise "Contraint violation: #{context.toString}"
          end
          
        end

        return processedColumns

      end
      
      return nil
      
    end

  end
  
end
