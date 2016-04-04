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

require_relative 'dimensions'

class Jcsv
  include_package "org.supercsv.cellprocessor.ift"
  
  #========================================================================================
  # Mapping contains a mapping from column names to:
  #   * other column names: when we want to change the name of the column
  #   * false: when we want to remove the column from reading
  #   * true: when the column is a dimensions
  # If there is no mapping then the column number maps to itself
  #========================================================================================

  class Mapping

    attr_accessor :mapping

    def initialize
      @mapping = nil
    end
    
    def [](index)
      # p "#{@mapping}, #{index}"
      (@mapping.nil?)? index : @mapping[index]
    end

    def []=(index, value)
      @mapping[index] = value
    end
    
  end  

  #========================================================================================
  # Module Processors interfaces the Ruby code with the SuperCsv cell processors.
  #========================================================================================

  module Processors
    include_package "org.supercsv.util"
    include_package "org.supercsv.exception"

    attr_reader :dimensions
    attr_reader :key_array
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def headers
      @headers ||= getHeader(true).to_a
    end

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
      
      context = CsvContext.new(getLineNumber(), getRowNumber(), 1);
      context.setRowSource(source);

      # raise "The number of columns to be processed #{source.size} must match the number of
      # CellProcessors #{processors.length}" if (source.size != processors.length)

      @key_array = Array.new
      
      source.each_with_index do |s, i|
        begin
          # is @column_mapping[i] ever nil? I don't think so... CHECK!!!
          next if ((@column_mapping[i] == false) || (@column_mapping[i].nil?))
          # if column mapping is 'true', then this column is a dimension and the data in this
          # column is part of the key
          if (@column_mapping[i] == true)
            begin
              @dimensions[@headers[i]] = s
            rescue RuntimeError => e
              p "Error reading row: #{source.toString()} in field '#{@headers[i]}'. " +
                e.message if !@suppress_errors
              # raise "Error reading row: #{source.toString()} in field '#{@headers[i]}'. " + e.message
            end
            @key_array[@dimensions.dimensions_names.index(@headers[i])] = s
            next
          end
          
          context.setColumnNumber(i + 1)
          if (i >= processors.size)
            @processed_columns[@column_mapping[i]] = s
          else
            if (processors[i] == nil)
              @processed_columns[@column_mapping[i]] = s
            else
              cell = processors[i].execute(s, context)
              cell = (cell.is_a? Jcsv::Pack)? cell.ruby_obj : cell
              @processed_columns[@column_mapping[i]] = cell
            end
          end
        rescue SuperCsvConstraintViolationException => e
          raise "Constraint violation: #{context.toString}"
        end
        
      end

      # @processed_columns[:key] = @key_array if (@dimensions)
      @processed_columns
      
    end
    
  end
  
  #========================================================================================
  # Class CLR (CSV List Reader) wraps java CsvListReader.
  #========================================================================================

  class CLR < org.supercsv.io.CsvListReader
    include_package "org.supercsv.cellprocessor.ift"
    include Processors

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def initialize(filereader, preferences, dimensions = nil, suppress_errors)
      @dimensions = dimensions
      @suppress_errors = suppress_errors
      super(filereader, preferences)
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read(column_mapping, filters)

      # initialize @processed_columns to a new Array.  This will be used by method
      # executeProcessor from module Processors.  @column_mapping also needs to be initialized
      # to the column_mapping received. Used by methods in module Processors
      @processed_columns = Array.new
      @column_mapping = column_mapping
      
      (filters == false)? super([].to_java(CellProcessor)) :
        super(filters.values.to_java(CellProcessor))
      
    end
    
  end

  #========================================================================================
  # class CMR (CSV Map Reader) wraps class CsvMapReader
  #========================================================================================

  class CMR < org.supercsv.io.CsvMapReader
    include_package "org.supercsv.cellprocessor.ift"
    include Processors

    # When dimensions are defined, then the composition of all dimensions is the 'key'
    # attr_reader :key
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def initialize(filereader, preferences, dimensions = nil, suppress_errors)
      @dimensions = dimensions
      @suppress_errors = suppress_errors
      super(filereader, preferences)
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read(column_mapping, filters)

      # initialize @processed_columns to a new Hash.  This will be used by method
      # executeProcessor from module Processors
      @processed_columns = Hash.new
      @column_mapping = column_mapping
      
      (filters == false)? super(*column_mapping.mapping) :
        filter_input(column_mapping, filters.values.to_java(CellProcessor))
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def filter_input(name_mapping, processors)
      if (readRow())
        processed_columns = executeProcessors(processors)
        processed_columns[:key] = @key_array if dimensions
        return processed_columns
      end
    end

=begin
    def filter_input(name_mapping, processors)
      processed_columns = executeProcessors(processors) if (readRow())
    end
=end
  end
  
end

