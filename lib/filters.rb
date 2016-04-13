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
  
class Jcsv
  include_package "org.supercsv.cellprocessor"
  include_package "org.supercsv.cellprocessor.constraint"

  def self.[](filter)
    case filter
    when :char
      Jcsv.char
    when :bool
      Jcsv.bool
    when :int
      Jcsv.int
    when :big_decimal
      Jcsv.big_decimal
    when :double
      Jcsv.double
    when :date
      Jcsv.date
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
    
    def initialize(next_filter = nil)
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
  
  class RBParseBigDecimal < org.supercsv.cellprocessor.CellProcessorAdaptor
    include_package "org.supercsv.cellprocessor.ift"
    # include DateCellProcessor
    
    def initialize(next_filter = nil)
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      BigDecimal.new(value)
    end
    
  end

  #========================================================================================
  #
  #========================================================================================

  def self.bool
    ParseBool.new
  end

  def self.char
    ParseChar.new
  end
  
  def self.date(date_format, lenient = false, next_filter = nil)
    ParseDate.new(date_format, lenient, Jcsv::RBParseDate.new(next_filter))
  end

  def self.int
    ParseInt.new
  end

  def self.long
    ParseLong.new
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
  
  def self.big_decimal(next_filter = nil)
    Jcsv::RBParseBigDecimal.new(next_filter)
  end

  def self.double
    ParseDouble.new
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
