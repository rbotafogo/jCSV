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
  
  class RBParseHTTPDate < Filter
    
    def initialize(start)
      @start = start
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.httpdate(value, @start), context)
    end

  end
  
  #========================================================================================
  #
  #========================================================================================
  
  class RBParseISO8601 < Filter
    
    def initialize(start)
      @start = start
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.iso8601(value, @start), context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseJD < Filter
        
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.jd(value), context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseJisx0301 < Filter
    
    def initialize(start)
      @start = start
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.jisx0301(value, @start), context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseDate < Filter
    
    def initialize(start, next_filter: nil)
      @start = start
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.parse(value, @start), context)
    end

  end
  
  #========================================================================================
  #
  #========================================================================================

  class RBParseRFC2822 < Filter
    
    def initialize(start)
      @start = start
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.rfc2822(value, @start), context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseRFC3339 < Filter
    
    def initialize(start)
      @start = start
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.rfc3339(value, @start), context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseRFC822 < Filter
    include NextFilter
    
    def initialize(start)
      @start = start
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.rfc822(value, @start), context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseStrptime < Filter
    
    def initialize(format, start)
      @format = format
      @start = start
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.strptime(value, @format, @start), context)
    end

  end

  #========================================================================================
  #
  #========================================================================================

  class RBParseXmlSchema < Filter
    
    def initialize(start)
      @start = start
      super()
    end
    
    def execute(value, context)
      validateInputNotNull(value, context)
      exec_next(DateTime.xmlschema(value, @start), context)
    end

  end

  #========================================================================================
  #
  #========================================================================================
  
  def self.httpdate(start = Date::ITALY)
    Jcsv::RBParseHTTPDate.new(start)
  end

  def self.iso8601(start = Date::ITALY)
    Jcsv::RBParseISO8601.new(start)
  end

  def self.jd
    Jcsv::RBParseJD.new
  end

  def self.jisx0301(start = Date::ITALY)
    Jcsv::RBParseJisx0301.new(start)
  end

  def self.date(start = Date::ITALY)
    Jcsv::RBParseDate.new(start)
  end

  def self.rfc2822(start = Date::ITALY)
    Jcsv::RBParseRFC2822.new(start)
  end
  
  def self.rfc3339(start = Date::ITALY)
    Jcsv::RBParseRFC3339.new(start)
  end

  def self.rfc822(start = Date::ITALY)
    Jcsv::RBParseRFC822.new(start)
  end

  def self.strptime(format, start = Date::ITALY)
    Jcsv::RBParseStrptime.new(format, start)
  end

  def self.xmlschema(start = Date::ITALY)
    Jcsv::RBParseXmlSchema.new(start)
  end

end
