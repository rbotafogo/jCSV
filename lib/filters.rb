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

class Pack

  attr_reader :ruby_obj
  
  def initialize(val)
    @ruby_obj = val
  end
  
end

class RBParseDate < org.supercsv.cellprocessor.CellProcessorAdaptor
  include_package "org.supercsv.cellprocessor.ift"
  include DateCellProcessor
  
  def initialize(next_filter = nil)
    (next_filter)? super(next_filter): super()
  end
  
  def execute(value, context)
    validateInputNotNull(value, context)
    Pack.new(Time.at(value.getTime()/1000))
  end
  
end

  
class Jcsv
  include_package "org.supercsv.cellprocessor"
  include_package "org.supercsv.cellprocessor.constraint"

  def self.big_decimal
    ParseBigDecimal.new
  end

  def self.bool
    ParseBool.new
  end

  def self.char
    ParseChar.new
  end
  
  def self.date(date, lenient = nil, next_filter = nil)
    ParseDate.new(date, lenient, next_filter)
  end

  def self.double
    PareDouble.new
  end

  def self.enum
    ParseEnum.new
  end

  def self.int
    ParseInt.new
  end

  def self.long
    ParseLong.new
  end
  
  def self.not_null
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
