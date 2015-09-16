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

  private
  
  ##########################################################################################
  #
  ##########################################################################################
  
  class Dimension

    attr_reader :name
    attr_reader :frozen
    attr_reader :current_value
    attr_reader :next_value
    attr_reader :labels
    attr_accessor :index     # column index of this dimension in the csv file
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(dim_name)
      @name = dim_name
      @frozen = false
      @next_value = 0
      @max_value = 0
      @labels = Hash.new 
    end

    #------------------------------------------------------------------------------------
    # Adds a new label to this dimension and keeps track of its index.  Labels are
    # indexed starting at 0 and always incrementing.  All labels in the dimension are
    # distinct. If trying to add a label that already exists, will:
    # * add it if it is a new label and return its index;
    # * return the index of an already existing label if the index is non-decreasing and
    #   monotonically increasing or if it is back to 0.  That is, if the last returned
    #   index is 5, then the next index is either 5 or 6 (new label), or 0.
    # * If the last returned index is 0, then the dimension becomes frozen and no more
    #   labels can be added to it.  After this point, add_label has to be called always
    #   in the same order that it was called previously.
    #------------------------------------------------------------------------------------

    def add_label(label)
      
      if (@labels.has_key?(label))
        # Just read one more line with the same label.  No problem, keep reading
        if (@labels[label] == @current_value)
          
        elsif (@labels[label] == @next_value)
          # Reading next label
          @current_value = @next_value
          @next_value = (@next_value + 1) % (@max_value + 1)
        elsif (@labels[label] < @current_value && @labels[label] == 0)
          reset
          return true
        else
          # Label read is out of order
          raise "Invalid label #{label}"
        end
      else
        # p "label: #{label}"
        # Trying to add a label when the dimension is frozen raises an exception
        raise "Dimension '#{@name}' is frozen.  Cannot add label '#{label}'." if frozen
        
        @current_value = @labels[label] = @next_value
        @next_value += 1
      end

      false
      
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def reset
      if !@frozen
        @frozen = true
        @max_value = @current_value
        @current_value = 0
        @next_value = 1
      end
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def index(label)
      @labels[label]
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def[](label)
      index(label)
    end
        
  end

  ##########################################################################################
  #
  ##########################################################################################

  class Dimensions

    attr_reader :dimensions_names
    attr_reader :dimensions
    attr_reader :rank
    
    #------------------------------------------------------------------------------------
    # dimensions is an array of column names that will be used as dimensions
    #------------------------------------------------------------------------------------

    def initialize(dimensions_names)

      @dimensions_names = dimensions_names
      @rank = @dimensions_names.size
      @dimensions = Hash.new
      
      @dimensions_names.each do |dim_name|
        @dimensions[dim_name] = Dimension.new(dim_name)
      end

    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def length(dim_name)
      @dimensions[dim_name].labels.size
    end

    alias :size :length
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def labels(dim_name)
      @dimensions[dim_name].labels
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def shape
      
      sh = Array.new
      @dimensions_names.each do |dim_name|
        sh << length(dim_name)
      end
      sh
      
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def add_label(dim_name, label)

      should_reset = @dimensions[dim_name].add_label(label)

      @dimensions[dim_name].reset if should_reset
#=begin
      (@dimensions_names.index(dim_name)...@dimensions_names.size).each do |i|
        name = @dimensions_names[i]
        @dimensions[name].reset
      end if should_reset
#=end      
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def[]=(dim_name, label)
      add_label(dim_name, label)
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def dimension(name)
      @dimensions[name]
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def[](name)
      @dimensions[name]
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def each
      
      @dimensions_names.each do |name|
        yield @dimensions[name]
      end
      
    end
    
  end

end
