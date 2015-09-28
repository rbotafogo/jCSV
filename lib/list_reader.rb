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

    private
    
    #========================================================================================
    #
    #========================================================================================
    
    module Header 
      
      #---------------------------------------------------------------------------------------
      # When file has headers, mapping should be done through the use of a hash like data
      # structure that responds to [] with a key.  In files without header, the mapping will
      # be done by use of arrays.
      #---------------------------------------------------------------------------------------
      
      def mapping=(map)

        # should allow mapping even with dimensions, but we need to be careful since
        # dimensions set a mapping and this needs to be preserved. 
        
        @column_mapping.map = Array.new
        
        i = 0
        @headers.each_with_index do |column_name, index|
          if map[column_name].nil?
            @column_mapping.mapping[index] ||= i
            i += 1
          else
            @column_mapping.mapping[index] ||= map[column_name]
          end
        end
        
      end
      
    end
    
    #========================================================================================
    # Headerless ListReader
    #========================================================================================
    
    module HeaderLess
      
      #---------------------------------------------------------------------------------------
      #
      #---------------------------------------------------------------------------------------
      
      def mapping=(map)
        
        raise "Mapping with array is not allowed when 'dimensions' are defined" if @dim_set
        
        raise "Filters parameters should either be a hash or an array of filters" if
          !map.is_a? Array
        
        @column_mapping.map = map
        @dim_set = true if @dimensions
        
      end
      
    end
        
    #========================================================================================
    #
    #========================================================================================

    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def prepare_headers
      extend Header
      super
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def headerless
      extend HeaderLess
      super
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def new_reader(preferences)

      begin
        @reader = CLR.new(FileReader.new(@filename), preferences, @dimensions)
      rescue java.io.IOException => e
        p e
      end
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------

    def format(chunk)
      chunk.to_a
    end

  end  
  
end
