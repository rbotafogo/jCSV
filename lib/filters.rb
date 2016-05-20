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

require 'bigdecimal'
require 'ipaddr'

require_relative 'locale'

class Jcsv

  #========================================================================================
  #
  #========================================================================================

  class FilterError < RuntimeError

  end

  class ConstraintViolation < RuntimeError

  end

  #========================================================================================
  #
  #========================================================================================

  module NextFilter

    # This object's next filter
    attr_accessor :next_filter
    
    # last_filter is a variable that points to the last filter in the sequence of
    # filters.  It is necessary to build the linked list of filters
    attr_accessor :last_filter

    #---------------------------------------------------------------------------------------
    # Method >> is used to link one filter to the next filter.  Basically we keep a linked
    # list of filters.
    #---------------------------------------------------------------------------------------
   
    def >>(next_filter)
      if (@next_filter.nil?)
        @next_filter = next_filter
        # this check is necessary in the following case: a >> (b >> c) >> d.  In
        # principle one has no reason to use parenthesis, but if done, then this check
        # should make everything still work fine
        @last_filter = (next_filter.last_filter.nil?)? @next_filter :
                         @next_filter.last_filter
      else
        @last_filter.next_filter = next_filter
        @last_filter = next_filter        
      end
      self
    end
    
    #---------------------------------------------------------------------------------------
    # Executes the next filter
    #---------------------------------------------------------------------------------------

    def exec_next(value, context)
      @next_filter? @next_filter.execute(value, context) : value      
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class Filter < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor
    include NextFilter

  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBParseBool < org.supercsv.cellprocessor.ParseBool
    include NextFilter
    
    def initialize(true_values, false_values, ignore_case)
      true_values = true_values.to_java(:string)
      false_values = false_values.to_java(:string)
      super(true_values, false_values, ignore_case)
    end
    
    def execute(value, context)
      begin
        exec_next(super(value, context), context)
      rescue org.supercsv.exception.SuperCsvCellProcessorException => e
        puts e.message
        # puts e.print_stack_trace
        raise FilterError
      end
      
    end

  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBConvertNilTo < Filter
    attr_reader :value
    
    def initialize(value)
      @value = value
      super()
    end
    
    def execute(value, context)
      val = (value)? value : @value
      exec_next(val, context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBOptional < Filter
        
    def execute(value, context)
      (value)? exec_next(value, context) : value      
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseChar < org.supercsv.cellprocessor.ParseChar
    include NextFilter

    def initialize
      super()
    end

    def execute(value, context)
      begin
        exec_next(super(value, context), context)
      rescue org.supercsv.exception.SuperCsvCellProcessorException => e
        puts e.message
        raise FilterError
      end
    end
    
  end

  #========================================================================================
  #
  #========================================================================================
  
  class RBCollector < Filter

    attr_reader :collection
    
    def initialize
      @collection = []
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      @collection << value
      exec_next(value, context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBIPAddr < Filter

    def execute(value, context)
      validateInputNotNull(value, context)
      value = IPAddr.new(value)
      exec_next(value, context)
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBDynamic < Filter

    def initialize(block: nil)
      @block = block
      super()
    end

    def execute(value, context)
      value = @block.call(value, context) if @block
      exec_next(value, context)
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBGsub < Filter
    
    def initialize(*args, block: nil)
      @args = args
      @block = block
      super()
    end

    def execute(value, context)
      value = (@block)? @block.call(value, *(@args)) : value.gsub(*(@args))
      exec_next(value, context)
    end
    
  end

  #========================================================================================
  #
  #========================================================================================

  class RBStringGeneric < Filter

    def initialize(function, *args, block: nil)
      @function = function
      @args = args
      @block = block
      super()
    end

    def execute(value, context)
      value = value.send(@function, *(@args), &(@block))
      exec_next(value, context)
    end
    
  end

  #========================================================================================
  #
  #========================================================================================

  def self.bool(true_values: ["true", "1", "y", "t"],
                false_values: ["false", "n", "0", "f"],
                ignore_case: true)
    RBParseBool.new(true_values, false_values, ignore_case)
  end

  def self.convert_nil_to(value)
    RBConvertNilTo.new(value)
  end

  def self.optional
    RBOptional.new
  end

  def self.char
    RBParseChar.new
  end
    
  def self.collector
    RBCollector.new
  end

  def self.ipaddr
    RBIPAddr.new
  end
  
  def self.dynamic(*args, &block)
    RBDynamic.new(*args, block: block)
  end

  def self.gsub(*args, &block)
    RBGsub.new(*args, block: block)
  end
  
  def self.str(function, *args, &block)
    RBStringGeneric.new(function, *args, block: block)
  end
  
end

require_relative 'date_filters'
require_relative 'numeric_filters'
require_relative 'constraints'


=begin
# class Java::OrgSupercsvCellprocessor::CellProcessorAdaptor
class Java::OrgSupercsvCellprocessor::CellProcessorAdaptor
  field_reader :next
end
=end
