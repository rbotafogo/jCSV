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

class Jcsv
  include_package "org.supercsv.cellprocessor"
  include_package "org.supercsv.cellprocessor.constraint"

  #========================================================================================
  #
  #========================================================================================
  
  class RBParseInt < org.supercsv.cellprocessor.ParseInt
    # include_package "org.supercsv.cellprocessor"

    def initialize(next_filter: nil)
      (next_filter)? super(next_filter) : super()
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
  
  class RBParseLong < org.supercsv.cellprocessor.ParseLong
    # include_package "org.supercsv.cellprocessor"

    def initialize(next_filter: nil)
      (next_filter)? super(next_filter) : super()
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

  class RBParseFloat < org.supercsv.cellprocessor.CellProcessorAdaptor

    attr_reader :locale
    attr_reader :dfs
    
    def initialize(locale, next_filter: nil)
      
      @locale = locale
      @dfs = DFSymbols.new(locale)
      @grouping_separator = @dfs.grouping_separator
      @decimal_separator = @dfs.decimal_separator
      (next_filter)? super(next_filter): super()
      
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      # raise "BigDecimal expects a String as input not #{value}" if !(value.is_a? String)
      value = value.gsub(@grouping_separator.chr, "").
              gsub(@decimal_separator.chr, ".").to_f
      (self.next)? self.next.execute(value, context) : value
    end
    
  end

  #========================================================================================
  #
  #========================================================================================
  
  class RBParseBignum < org.supercsv.cellprocessor.CellProcessorAdaptor
    # include_package "org.supercsv.cellprocessor.ift"
    
    def initialize(next_filter: nil)
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      (self.next)? self.next.execute(value.to_i, context) : value.to_i
    end

  end

  #========================================================================================
  #
  #========================================================================================
  
  class RBParseComplex < org.supercsv.cellprocessor.CellProcessorAdaptor
    # include_package "org.supercsv.cellprocessor.ift"
    
    def initialize(next_filter: nil)
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      (self.next)? self.next.execute(value.to_c, context) : value.to_c
    end

  end

  #========================================================================================
  #
  #========================================================================================
  
  class RBParseRational < org.supercsv.cellprocessor.CellProcessorAdaptor
    # include_package "org.supercsv.cellprocessor.ift"
    
    def initialize(next_filter: nil)
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      (self.next)? self.next.execute(value.to_r, context) : value.to_r
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseBigDecimal < org.supercsv.cellprocessor.CellProcessorAdaptor

    attr_reader :locale
    attr_reader :dfs
    
    def initialize(locale, next_filter: nil)
      
      @locale = locale
      @dfs = DFSymbols.new(locale)
      @grouping_separator = @dfs.grouping_separator
      @decimal_separator = @dfs.decimal_separator
      (next_filter)? super(next_filter): super()
      
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      # raise "BigDecimal expects a String as input not #{value}" if !(value.is_a? String)
      bd = BigDecimal.new(value.gsub(@grouping_separator.chr, "").
                           gsub(@decimal_separator.chr, "."))
      (self.next)? self.next.execute(bd, context) : bd  
    end
    
  end

  #========================================================================================
  #
  #========================================================================================

  def self.int(next_filter: nil)
    RBParseInt.new(next_filter: next_filter)
  end

  def self.long(next_filter: nil)
    RBParseLong.new(next_filter: next_filter)
  end

  def self.fixnum(next_filter: nil)
    RBParseBignum.new(next_filter: next_filter)
  end

  def self.float(locale = Locale.default, next_filter: nil)
    RBParseFloat.new(locale, next_filter: next_filter)
  end

  def self.complex(next_filter: nil)
    RBParseComplex.new(next_filter: next_filter)
  end

  def self.rational(next_filter: nil)
    RBParseRational.new(next_filter: next_filter)
  end
  
  def self.bignum(next_filter: nil)
    RBParseBignum.new(next_filter: next_filter)
  end

  #---------------------------------------------------------------------------------------
  # Convert a String to a BigDecimal. It uses the String constructor of BigDecimal
  # (new BigDecimal("0.1")) as it yields predictable results (see BigDecimal).
  # If the data uses a character other than "." as a decimal separator (Germany uses ","
  # for example), then use the constructor that accepts a DecimalFormatSymbols object, as
  # it will convert the character to a "." before creating the BigDecimal. Likewise if the
  # data contains a grouping separator (Germany uses "." for example) then supplying a
  # DecimalFormatSymbols object will allow grouping separators to be removed before
  # parsing.
  #---------------------------------------------------------------------------------------
  
  def self.big_decimal(locale = Locale.default, next_filter: nil)
    Jcsv::RBParseBigDecimal.new(locale, next_filter: next_filter)
  end
  
end
