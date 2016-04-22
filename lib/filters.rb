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
require_relative 'locale'

# class Java::OrgSupercsvCellprocessor::CellProcessorAdaptor
class Java::OrgSupercsvCellprocessor::CellProcessorAdaptor
  field_reader :next
end

class Jcsv
  include_package "org.supercsv.cellprocessor"
  include_package "org.supercsv.cellprocessor.constraint"

  class FilterError < RuntimeError

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseBool < org.supercsv.cellprocessor.ParseBool
    
    def initialize(true_values, false_values, ignore_case, next_filter)
      true_values = true_values.to_java(:string)
      false_values = false_values.to_java(:string)
      (next_filter)? super(true_values, false_values, ignore_case, next_filter) :
        super(true_values, false_values, ignore_case)
    end
    
    def execute(value, context)
      begin
        super(value, context)
      rescue org.supercsv.exception.SuperCsvCellProcessorException => e
        puts e.message
        raise FilterError
      end
      
    end

  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBConvertNilTo < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor

    attr_reader :value
    
    def initialize(value, next_filter: nil)
      @value = value
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      val = (value)? value : @value
      (self.next)? self.next.execute(val, context) : val      
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBOptional < org.supercsv.cellprocessor.CellProcessorAdaptor
    
    def initialize(next_filter: nil)
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      (value && self.next)? self.next.execute(value, context) : value      
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBInRange < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor

    attr_reader :min
    attr_reader :max
    
    def initialize(min, max, next_filter: nil)
      @min = min
      @max = max
      (next_filter.nil?)? super() : super(next_filter)
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      raise "#{@min} <= #{value} <= #{@max} does not hold" if (value < @min || value > @max)
      (self.next)? self.next.execute(value, context) : value
    end

  end

  #========================================================================================
  #
  #========================================================================================
  
  class RBCollector < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor

    attr_reader :collection
    
    def initialize(next_filter: nil)
      @collection = []
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      @collection << value
      (self.next)? self.next.execute(value, context) : value      
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBDynamic < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor

    def initialize(*args, block: nil, next_filter: nil)
      @args = args
      @block = block
      (next_filter)? super(next_filter): super()
    end

    def execute(value, context)
      # p value
      @block.call(value, *(@args))
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  def self.bool(true_values: ["true", "1", "y", "t"],
                false_values: ["false", "n", "0", "f"],
                ignore_case: true, next_filter: nil)
    RBParseBool.new(true_values, false_values, ignore_case, next_filter)
  end

  def self.convert_nil_to(value, next_filter: nil)
    RBConvertNilTo.new(value, next_filter: next_filter)
  end

  def self.optional(next_filter: nil)
    RBOptional.new(next_filter: next_filter)
  end

  def self.char
    ParseChar.new
  end
  
  def self.in_range(min, max, next_filter: nil)
    RBInRange.new(min, max, next_filter: next_filter)
  end
  
  def self.collector(next_filter: nil)
    RBCollector.new(next_filter: next_filter)
  end

  def self.dynamic(*args, next_filter: nil, &block)
    RBDynamic.new(*args, block: block, next_filter: next_filter)
  end



  
  def self.not_nil
    NotNull.new
  end

  def self.hash_mapper
    HashMapper.new
  end

  
end

require_relative 'date_filters'
require_relative 'numeric_filters'

=begin

Reading	Writing	 Reading / Writing	Constraints
ParseBigDecimal	FmtBool	   Collector	DMinMax
ParseBool	FmtDate	   ConvertNullTo	Equals
ParseChar	FmtNumber	HashMapper	ForbidSubStr
ParseDate		    Optional	IsElementOf
ParseDouble		    StrReplace	IsIncludedIn
ParseEnum		    Token	LMinMax
ParseInt		    Trim	NotNull
ParseLong		    Truncate	RequireHashCode

RequireSubStr
Strlen
StrMinMax
StrNotNullOrEmpty
StrRegEx
Unique
UniqueHashCode
=end

=begin
  #========================================================================================
  #
  #========================================================================================

  class Pack
    
    attr_reader :ruby_obj
    
    def initialize(val)
      @ruby_obj = val
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBParseDate < org.supercsv.cellprocessor.CellProcessorAdaptor
    include_package "org.supercsv.cellprocessor.ift"
    include DateCellProcessor
    
    def initialize(next_filter: nil)
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      Jcsv::Pack.new(Time.at(value.getTime()/1000))
    end
    
  end
=end
