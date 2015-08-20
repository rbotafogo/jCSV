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

  class CMR < org.supercsv.io.CsvMapReader
    include_package "org.supercsv.cellprocessor.ift"
    include_package "org.supercsv.exception"
    include_package "org.supercsv.util"
    include_package "org.supercsv.io"
    include ICsvListReader

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def read(name_mapping, filters)
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

    def new_reader(preferences)
      
      begin
        raise "Reading file as map requires headers." if !@headers
        @reader = CMR.new(FileReader.new(@filename), preferences);
      rescue java.io.IOException => e
        p e
      end

    end
    
    #---------------------------------------------------------------------------------------
    # Maps columns to the given names
    #---------------------------------------------------------------------------------------

    def mapping=(name_mapping)

      map = Array.new
      @headers.each do |h|
        name = name_mapping[h]
        if (name.nil?)
          map << h
        elsif (name == :false)
          map << nil
        else
          map << name
        end
        # map << ((name_mapping[h].nil?)? h : name_mapping[h])
      end
      
      @mapping = map
      
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    private
    
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
