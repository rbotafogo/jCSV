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
  
  class Locale
    
    attr_accessor :locale
    
    class << self
      attr_accessor :available_locs
    end
    
    Locale.available_locs = []
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def self.available_locales
      
      if (@available_locs.size == 0)
        java.util.Locale.available_locales.each do |loc|
          @available_locs << Locale.new(loc)
        end
      end
      
      @available_locs
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def self.default
      Locale.new(locale: java.util.Locale.default)
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def self.default=(locale)
      java.util.Locale.set_default(locale.locale)
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def self.method_missing(symbol, *args)
      java.util.Locale.send(symbol, *args)
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def initialize(locale: nil, language: nil, country: nil, variant: nil)
      
      args = [language, country, variant]
      
      if (locale)
        @locale = locale
      else
        @locale = java.util.Locale.new(*(args.compact))
      end
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def method_missing(symbol, *args)
      @locale.send(symbol, *args)
    end
    
  end
  
  #=========================================================================================
  #
  #=========================================================================================
  
  class Locale
  
    CANADA = Locale.new(locale: java.util.Locale::CANADA)
    CANADA_FRENCH = Locale.new(locale: java.util.Locale::CANADA_FRENCH)
    CHINA  = Locale.new(locale: java.util.Locale::CHINA)
    CHINESE = Locale.new(locale: java.util.Locale::CHINESE)
    ENGLISH = Locale.new(locale: java.util.Locale::ENGLISH)
    FRANCE = Locale.new(locale: java.util.Locale::FRANCE)
    FRENCH = Locale.new(locale: java.util.Locale::FRENCH)
    GERMAN = Locale.new(locale: java.util.Locale::GERMAN)
    GERMANY = Locale.new(locale: java.util.Locale::GERMANY)
    ITALIAN = Locale.new(locale: java.util.Locale::ITALIAN)
    ITALY = Locale.new(locale: java.util.Locale::ITALY)
    JAPAN = Locale.new(locale: java.util.Locale::JAPAN)
    JAPANESE = Locale.new(locale: java.util.Locale::JAPANESE)
    KOREA = Locale.new(locale: java.util.Locale::KOREA)
    KOREAN = Locale.new(locale: java.util.Locale::KOREAN)
    PRC = Locale.new(locale: java.util.Locale::PRC)
    ROOT = Locale.new(locale: java.util.Locale::ROOT)
    SIMPLIFIED_CHINESE = Locale.new(locale: java.util.Locale::SIMPLIFIED_CHINESE)
    TAIWAN = Locale.new(locale: java.util.Locale::TAIWAN)
    TRADITIONAL_CHINESE = Locale.new(locale: java.util.Locale::TRADITIONAL_CHINESE)
    UK = Locale.new(locale: java.util.Locale::UK)
    US = Locale.new(locale: java.util.Locale::US)
    BRAZIL = Locale.new(language: "pt", country: "BR")
    
  end
  
  ##########################################################################################
  #
  ##########################################################################################
  
  class DFSymbols
    
    attr_accessor :decimal_format_symbols
    
    class << self
      attr_accessor :available_locs
    end
    
    DFSymbols.available_locs = []
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def self.available_locales
      
      if (@available_locs.size == 0)
        java.text.DecimalFormatSymbols.available_locales.each do |loc|
          @available_locs << Locale.new(loc)
        end
      end
      
      @available_locs
      
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def self.method_missing(symbol, *args)
      java.text.DecimalFormatSymbols.send(symbol, *args)
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def initialize(locale = nil)
      @decimal_format_symbols = (locale.nil?)? java.text.DecimalFormatSymbols.new() :
                                  java.text.DecimalFormatSymbols.new(locale.locale)
    end
    
    #---------------------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------------------
    
    def method_missing(symbol, *args)
      @decimal_format_symbols.send(symbol, *args)
    end
    
  end
  
end

