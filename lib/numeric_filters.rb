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
  
  class RBParseLong < org.supercsv.cellprocessor.ParseLong
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

  class RBParseFloat < org.supercsv.cellprocessor.CellProcessorAdaptor
    include NextFilter
    
    attr_reader :locale
    attr_reader :dfs
    
    def initialize(locale)
      @locale = locale
      @dfs = DFSymbols.new(locale)
      @grouping_separator = @dfs.grouping_separator
      @decimal_separator = @dfs.decimal_separator
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      # raise "BigDecimal expects a String as input not #{value}" if !(value.is_a? String)
      value = value.gsub(@grouping_separator.chr, "").
              gsub(@decimal_separator.chr, ".").to_f
      exec_next(value, context)
    end
    
  end

  #========================================================================================
  #
  #========================================================================================
  
  class RBParseBignum < org.supercsv.cellprocessor.CellProcessorAdaptor
    include NextFilter
    
    def initialize
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(value.to_i, context)
    end

  end

  #========================================================================================
  #
  #========================================================================================
  
  class RBParseComplex < org.supercsv.cellprocessor.CellProcessorAdaptor
    include NextFilter
    
    def initialize
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(value.to_c, context)
    end

  end

  #========================================================================================
  #
  #========================================================================================
  
  class RBParseRational < org.supercsv.cellprocessor.CellProcessorAdaptor
    include NextFilter
    
    def initialize
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(value.to_r, context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseBigDecimal < org.supercsv.cellprocessor.CellProcessorAdaptor
    include NextFilter
    
    attr_reader :locale
    attr_reader :dfs
    
    def initialize(locale)
      @locale = locale
      @dfs = DFSymbols.new(locale)
      @grouping_separator = @dfs.grouping_separator
      @decimal_separator = @dfs.decimal_separator
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      # raise "BigDecimal expects a String as input not #{value}" if !(value.is_a? String)
      bd = BigDecimal.new(value.gsub(@grouping_separator.chr, "").
                           gsub(@decimal_separator.chr, "."))
      exec_next(bd, context)
    end
    
  end

  #========================================================================================
  #
  #========================================================================================

  def self.int
    RBParseInt.new
  end

  def self.long
    RBParseLong.new
  end

  def self.fixnum
    RBParseBignum.new
  end

  def self.float(locale = Locale.default)
    RBParseFloat.new(locale)
  end

  def self.complex
    RBParseComplex.new
  end

  def self.rational
    RBParseRational.new
  end
  
  def self.bignum
    RBParseBignum.new
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
  
  def self.big_decimal(locale = Locale.default)
    Jcsv::RBParseBigDecimal.new(locale)
  end
  
end
