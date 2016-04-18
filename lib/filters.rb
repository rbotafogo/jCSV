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

  class FilterError < RuntimeError

  end

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
  
  class RBParseBignum < org.supercsv.cellprocessor.CellProcessorAdaptor
    # include_package "org.supercsv.cellprocessor.ift"
    
    def initialize(next_filter: nil)
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      value.to_i
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
      BigDecimal.new(value.gsub(@grouping_separator.chr, "").
                      gsub(@decimal_separator.chr, "."))
    end
    
  end

  #========================================================================================
  #
  #========================================================================================
  
  class RBParseHTTPDate < org.supercsv.cellprocessor.CellProcessorAdaptor
    # include_package "org.supercsv.cellprocessor.ift"
    
    def initialize(start, next_filter: nil)
      @start = start
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.httpdate(value, @start)
    end

  end
  
  #========================================================================================
  #
  #========================================================================================
  
  class RBParseISO8601 < org.supercsv.cellprocessor.CellProcessorAdaptor
    # include_package "org.supercsv.cellprocessor.ift"
    
    def initialize(start, next_filter: nil)
      @start = start
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.iso8601(value, @start)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseJD < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor
    
    def initialize(next_filter: nil)
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.jd(value)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseJisx0301 < org.supercsv.cellprocessor.CellProcessorAdaptor
    
    def initialize(start, next_filter: nil)
      @start = start
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.jisx0301(value, @start)
    end

  end

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

  #========================================================================================
  #
  #========================================================================================

  class RBInRange < org.supercsv.cellprocessor.CellProcessorAdaptor
    include org.supercsv.cellprocessor.ift.LongCellProcessor

    attr_reader :min
    attr_reader :max
    
    def initialize(min, max, next_filter: nil)
      @min = min
      @max = max
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      raise "#{@min} <= #{value} <= #{@max} does not hold" if (value < @min || value > @max)
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

  def self.double
    ParseDouble.new
  end

  def self.bool
    ParseBool.new
  end

  def self.char
    ParseChar.new
  end
  
  def self.date(date_format, lenient = false, next_filter: nil)
    ParseDate.new(date_format, lenient,
                  Jcsv::RBParseDate.new(next_filter: next_filter))
  end

  def self.http_time(start = Date::ITALY, next_filter: nil)
    Jcsv::RBParseHTTPDate.new(start, next_filter: next_filter)
  end

  def self.iso8601(start = Date::ITALY, next_filter: nil)
    Jcsv::RBParseISO8601.new(start, next_filter: next_filter)
  end

  def self.jd(next_filter: nil)
    Jcsv::RBParseJD.new(next_filter: next_filter)
  end

  def self.jisx0301(start = Date::ITALY, next_filter: nil)
    Jcsv::RBParseJisx0301.new(start, next_filter: next_filter)
  end

  def self.in_range(min, max)
    Jcsv::RBInRange.new(min, max)
  end
  
  def self.enum
    ParseEnum.new
  end
  
  def self.not_nil
    NotNull.new
  end

  def self.collector
    Collector.new
  end

  def self.convert_null_to(val)
    ConvertNullTo.new(val)
  end

  def self.hash_mapper
    HashMapper.new
  end

  def self.optional(cont = nil)
    (cont)? Optional.new(cont) : Optional.new
  end
  
end

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

