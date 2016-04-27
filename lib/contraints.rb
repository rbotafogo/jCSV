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
    include NextFilter

    attr_reader :min
    attr_reader :max
    
    def initialize(min, max)
      @min = min
      @max = max
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      raise "#{@min} <= #{value} <= #{@max} does not hold" if (value < @min || value > @max)
      exec_next(value, context)
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBForbidSubstrings < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor
    include NextFilter

    attr_reader :substrings
    
    def initialize(substrings)
      @substrings = substrings
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      substrings.each do |sub|
        raise "Substring #{sub} found in #{value}" if value.include?(sub)
      end
      exec_next(value, context)
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBEquals < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor
    include NextFilter

    attr_reader :value
    
    def initialize(value = nil)
      @value = value
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      @value ||= value # if value not initialized then use the first read value for equals
      
      raise "Value '#{value}' is not equal to '#{@value}'" if (value != @value)
      exec_next(value, context)
    end

  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBNotNil < org.supercsv.cellprocessor.CellProcessorAdaptor
    include NextFilter
    
    def initialize
      super()
    end
    
    def execute(value, context)
      raise "Value is nil" if (value.nil?)
      exec_next(value, context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBIsElementOf < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    include org.supercsv.cellprocessor.ift.DoubleCellProcessor
    include org.supercsv.cellprocessor.ift.StringCellProcessor
    include NextFilter
    
    attr_reader :strings
    
    def initialize(strings)
      @strings = strings
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      raise "Value #{value} not element of #{@strings}" if !@strings.include?(value)
      exec_next(value, context)
    end
    
  end

  #========================================================================================
  #
  #========================================================================================

  class RBStrContraints < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.StringCellProcessor
    include NextFilter

    def initialize(function, *args, check: true)
      @function = function
      @args = args
      @check = check
      super()
    end

    def execute(value, context)
      truth = value.send(@function, *(@args))
      raise "Contraint #{@function} with value #{value} is #{truth}" if truth == @check
      exec_next(value, context)
    end

  end
  
  #========================================================================================
  #
  #========================================================================================

  def self.in_range(min, max)
    RBInRange.new(min, max)
  end

  def self.equals(value = nil)
    RBEquals.new(value)
  end
  
  def self.ascii_only?
    RBStrContraints.new(:ascii_only?)
  end

  def self.not_ascii?
    RBStrContraints.new(:ascii_only?, check: false)
  end

  def self.empty?
    RBStrContraints.new(:empty?)
  end

  def self.end_with?(*args)
    RBStrContraints.new(:end_with?, *args)
  end
  
  def self.include?(*args)
    RBStrContraints.new(:include?, *args)
  end

  def self.start_with?(*args)
    RBStrContraints.new(:start_with?, *args)
  end

  def self.not_nil
    RBNotNil.new
  end

  def self.forbid_substrings(substrings)
    RBForbidSubstrings.new(substrings)
  end

  def self.is_element_of(strings)
    RBIsElementOf.new(strings)
  end

end
