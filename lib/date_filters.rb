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

  class RBParseDate < org.supercsv.cellprocessor.CellProcessorAdaptor
    
    def initialize(start, next_filter: nil)
      @start = start
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.parse(value, @start)
    end

  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBParseRFC2822 < org.supercsv.cellprocessor.CellProcessorAdaptor
    
    def initialize(start, next_filter: nil)
      @start = start
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.rfc2822(value, @start)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseRFC3339 < org.supercsv.cellprocessor.CellProcessorAdaptor
    
    def initialize(start, next_filter: nil)
      @start = start
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.rfc3339(value, @start)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseRFC822 < org.supercsv.cellprocessor.CellProcessorAdaptor
    
    def initialize(start, next_filter: nil)
      @start = start
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.rfc822(value, @start)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseStrptime < org.supercsv.cellprocessor.CellProcessorAdaptor
    
    def initialize(format, start, next_filter: nil)
      @format = format
      @start = start
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.strptime(value, @format, @start)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseXmlSchema < org.supercsv.cellprocessor.CellProcessorAdaptor
    
    def initialize(start, next_filter: nil)
      @start = start
      (next_filter)? super(next_filter): super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      DateTime.xmlschema(value, @start)
    end

  end

  #========================================================================================
  #
  #========================================================================================
  
  def self.httpdate(start = Date::ITALY, next_filter: nil)
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

  def self.date(start = Date::ITALY, next_filter: nil)
    Jcsv::RBParseDate.new(start, next_filter: next_filter)
  end

  def self.rfc2822(start = Date::ITALY, next_filter: nil)
    Jcsv::RBParseRFC2822.new(start, next_filter: next_filter)
  end
  
  def self.rfc3339(start = Date::ITALY, next_filter: nil)
    Jcsv::RBParseRFC3339.new(start, next_filter: next_filter)
  end

  def self.rfc822(start = Date::ITALY, next_filter: nil)
    Jcsv::RBParseRFC822.new(start, next_filter: next_filter)
  end

  def self.strptime(format, start = Date::ITALY, next_filter: nil)
    Jcsv::RBParseStrptime.new(format, start, next_filter: next_filter)
  end

  def self.xmlschema(start = Date::ITALY, next_filter: nil)
    Jcsv::RBParseXmlSchema.new(start, next_filter: next_filter)
  end

end
