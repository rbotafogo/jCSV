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
  # include_package "org.supercsv.cellprocessor"
  # include_package "org.supercsv.cellprocessor.constraint"

  #========================================================================================
  #
  #========================================================================================

  class RBInRange < Filter

    attr_reader :min
    attr_reader :max
    
    def initialize(min, max)
      @min = min
      @max = max
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      raise ConstraintViolation,
            "#{@min} <= #{value} <= #{@max} does not hold:\n#{context}" if
        (value < @min || value > @max)
      exec_next(value, context)
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBForbidSubstrings < Filter

    attr_reader :substrings
    
    def initialize(substrings)
      @substrings = substrings
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      substrings.each do |sub|
        raise "Substring #{sub} found in #{value}:\n#{context}" if value.include?(sub)
      end
      exec_next(value, context)
    end
    
  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBEquals < Filter

    attr_reader :value
    
    def initialize(value = nil)
      @value = value
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      @value ||= value # if value not initialized then use the first read value for equals
      
      raise "Value '#{value}' is not equal to '#{@value}':\n#{context}" if
        (value != @value)
      exec_next(value, context)
    end

  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBNotNil < Filter
        
    def execute(value, context)
      raise ConstraintViolation, "Empty value found:\n#{context}" if (value.nil?)
      exec_next(value, context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBIsElementOf < Filter
    
    attr_reader :strings
    
    def initialize(strings)
      @strings = strings
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      raise "Value #{value} not element of #{@strings}:\n#{context}" if
        !@strings.include?(value)
      exec_next(value, context)
    end
    
  end

  #========================================================================================
  #
  #========================================================================================

  class RBStrConstraints < Filter

    def initialize(function, *args, check: true)
      @function = function
      @args = args
      @check = check
      super()
    end

    def execute(value, context)
      truth = value.send(@function, *(@args))
      raise "Constraint #{@function} with value #{value} is #{truth}:\n#{context}" if
        truth == @check
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
    RBStrConstraints.new(:ascii_only?)
  end

  def self.not_ascii?
    RBStrConstraints.new(:ascii_only?, check: false)
  end

  def self.empty?
    RBStrConstraints.new(:empty?)
  end

  def self.end_with?(*args)
    RBStrConstraints.new(:end_with?, *args)
  end
  
  def self.include?(*args)
    RBStrConstraints.new(:include?, *args)
  end

  def self.start_with?(*args)
    RBStrConstraints.new(:start_with?, *args)
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
