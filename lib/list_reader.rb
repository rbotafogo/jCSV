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
    # read the file.
    #---------------------------------------------------------------------------------------
    
    def read(&block)

      # When no block given, chunks read are stored in an array and returned to the user.
      if (!block_given?)
        rows = []
          parse_with_block do |line_no, row_no, chunk|
            rows << chunk
          end
        rows
      else
        parse_with_block(&block)
      end
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    private
    
    #========================================================================================
    # This module should be included if the ListReader has headers; otherwise, the
    # HeaderLess module should be included.
    #========================================================================================
    
    module Header 
      
      #---------------------------------------------------------------------------------------
      # When file has headers, mapping should be done through the use of a hash like data
      # structure that responds to [] with a key.  A mapping allows reordering of columns and
      # also columns removal.  A column will be removed if this columns mapping is false.
      # When reading with dimensions, a mapping is automatically created and dimensions are
      # mapped to true.  
      #---------------------------------------------------------------------------------------
      
      def mapping=(column_mapping)
        
        # should allow mapping even with dimensions, but we need to be careful since
        # dimensions set a mapping and this needs to be preserved. 
        @column_mapping.mapping ||= Array.new        
        
        j = 0
        @headers.each_with_index do |h, i|
          if column_mapping[h].nil?
            @column_mapping.mapping[i] ||= j
            j += 1
          else
            raise "'true' is not allowed as a mapping: #{column_mapping}" if
              column_mapping[h] == true
            @column_mapping.mapping[i] ||= column_mapping[h]
          end
        end
        
      end
      
    end
    
    #========================================================================================
    # Headerless ListReader
    #========================================================================================
    
    module HeaderLess
      
      #---------------------------------------------------------------------------------------
      # TODO: Needs to be reviewed.  Headerless ListReader needs further testing and
      # eventually a new set of features.
      #---------------------------------------------------------------------------------------
      
      def mapping=(map)
        
        raise "Mapping with array is not allowed when 'dimensions' are defined" if @dim_set
        
        raise "Filters parameters should either be a hash or an array of filters" if
          !map.is_a? Array
        
        @column_mapping.mapping ||= map
        @dim_set = true if @dimensions
        
      end
      
    end
        
    #========================================================================================
    #
    #========================================================================================

    #---------------------------------------------------------------------------------------
    # Should be called when the data has headers
    #---------------------------------------------------------------------------------------

    def prepare_headers
      extend Header
      super
    end
    
    #---------------------------------------------------------------------------------------
    # Should be called for headerless data
    #---------------------------------------------------------------------------------------

    def headerless
      extend HeaderLess
      super
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    private
    
    #---------------------------------------------------------------------------------------
    # Creates a new CLR reader with the given set of preferences
    #---------------------------------------------------------------------------------------

    def new_reader(preferences)

      begin
        @reader = CLR.new(FileReader.new(@filename), preferences, @dimensions,
                          @suppress_warnings)
      rescue java.io.IOException => e
        puts e
      end
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def format(chunk)
      chunk.to_a
    end

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def assign_mapping(column_mapping)
      
      # should allow mapping even with dimensions, but we need to be careful since
      # dimensions set a mapping and this needs to be preserved. 
      @column_mapping.mapping ||= Array.new
      
      j = 0
      @headers.each_with_index do |h, i|
        if column_mapping[h].nil?
          @column_mapping.mapping[i] ||= j
          j += 1
        else
          @column_mapping.mapping[i] ||= column_mapping[h]
        end
      end
      
      # p @column_mapping.mapping
      
    end
    
  end
  
end  

