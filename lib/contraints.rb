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
  include_package "org.supercsv.cellprocessor"
  include_package "org.supercsv.cellprocessor.constraint"

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

  class RBForbidSubstrings < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor

    attr_reader :substrings
    
    def initialize(substrings, next_filter: nil)
      @substrings = substrings
      (next_filter.nil?)? super() : super(next_filter)
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      substrings.each do |sub|
        raise "Substring #{sub} found in #{value}" if value.include?(sub)
      end
      (self.next)? self.next.execute(value, context) : value
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBEquals < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor

    attr_reader :value
    
    def initialize(value = nil, next_filter: nil)
      @value = value
      (next_filter.nil?)? super() : super(next_filter)
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      @value ||= value # if value not initialized then use the first read value for equals
      
      raise "Value '#{value}' is not equal to '#{@value}'" if (value != @value)
      (self.next)? self.next.execute(value, context) : value
    end

  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBNotNil < org.supercsv.cellprocessor.CellProcessorAdaptor
    
    def initialize(next_filter: nil)
      (next_filter.nil?)? super() : super(next_filter)
    end
    
    def execute(value, context)
      raise "Value is nil" if (value.nil?)
      (self.next)? self.next.execute(value, context) : value
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBIsElementOf < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor
    
    attr_reader :strings
    
    def initialize(strings, next_filter: nil)
      @strings = strings
      (next_filter.nil?)? super() : super(next_filter)
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      raise "Value #{value} not element of #{@strings}" if !@strings.include?(value)
      (self.next)? self.next.execute(value, context) : value
    end
    
  end

  #========================================================================================
  #
  #========================================================================================

  class RBStrContraints < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.StringCellProcessor

    def initialize(function, *args, check: true, next_filter: nil)
      @function = function
      @args = args
      @check = check
      (next_filter)? super(next_filter): super()
    end

    def execute(value, context)
      truth = value.send(@function, *(@args))
      raise "Contraint #{@function} with value #{value} is #{truth}" if truth == @check
      (self.next)? self.next.execute(value, context) : value  
    end

  end
  
  #========================================================================================
  #
  #========================================================================================

  def self.in_range(min, max, next_filter: nil)
    RBInRange.new(min, max, next_filter: next_filter)
  end

  def self.equals(value = nil, next_filter: nil)
    RBEquals.new(value, next_filter: next_filter)
  end
  
  def self.ascii_only?(next_filter: nil)
    RBStrContraints.new(:ascii_only?, next_filter: next_filter)
  end

  def self.not_ascii?(next_filter: nil)
    RBStrContraints.new(:ascii_only?, check: false, next_filter: next_filter)
  end

  def self.empty?(next_filter: nil)
    RBStrContraints.new(:empty?, next_filter: next_filter)
  end

  def self.end_with?(*args, next_filter: nil)
    RBStrContraints.new(:end_with?, *args, next_filter: next_filter)
  end
  
  def self.include?(*args, next_filter: nil)
    RBStrContraints.new(:include?, *args, next_filter: next_filter)
  end

  def self.start_with?(*args, next_filter: nil)
    RBStrContraints.new(:start_with?, *args, next_filter: next_filter)
  end

  def self.not_nil(next_filter: nil)
    RBNotNil.new(next_filter: next_filter)
  end

  def self.forbid_substrings(substrings, next_filter: next_filter)
    RBForbidSubstrings.new(substrings, next_filter: next_filter)
  end

  def self.is_element_of(strings, next_filter: next_filter)
    RBIsElementOf.new(strings, next_filter: next_filter)
  end

end
