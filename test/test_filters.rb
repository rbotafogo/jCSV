# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2015 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation for educational, research, and 
# not-for-profit purposes, without fee and without a signed licensing agreement, is hereby 
# granted, provided that the above copyright notice, this paragraph and the following two 
# paragraphs appear in all copies, modifications, and distributions. Contact Rodrigo
# Botafogo - rodrigo.a.botafogo@gmail.com for commercial licensing opportunities.
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

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'matrix'
require 'mdarray'

require_relative '../config'

require 'jcsv'

class CSVTest < Test::Unit::TestCase

  context "CSV test" do

    setup do

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------
=begin
    should "work with DecimalFormatSymbols" do

      dfs = DecimalFormatSymbols.new
      p dfs.currency_symbol
      p dfs.decimal_separator.chr
      p dfs.digit.chr
      p dfs.exponent_separator
      p dfs.grouping_separator.chr
      p dfs.infinity
      # Returns the ISO 4217 currency code of the currency of these DecimalFormatSymbols.
      p dfs.international_currency_symbol
      p dfs.minus_sign.chr
      p dfs.monetary_decimal_separator.chr
      p dfs.getNaN
      # Gets the character used to separate positive and negative subpatterns in a pattern.
      # p pattern_separator.chr
      # Gets the character used for percent sign.
      p	dfs.percent.chr
      # Gets the character used for per mille sign.
      p dfs.per_mill
      # Gets the character used for zero.
      p dfs.zero_digit.chr

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "work with Locales" do
      
      locale = Locale.default
      puts "Your locale country is: #{locale.display_country}"

      # Switch default locale to France, so display_country will be in French.
      locale = Locale.default = Locale::FRANCE
      assert_equal("français", locale.display_language)
      assert_equal("France", locale.display_country)

      # Create a new locale, but default is still France, so output is in French.
      loc2 = Locale.new(language: "en", country: "US")
      assert_equal("en-US", loc2.to_language_tag)
      assert_equal("US", loc2.country)
      assert_equal("Etats-Unis", loc2.display_country)

      locale = Locale::US
      p locale
    end
=end        
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "check all filters" do

      reader = Jcsv.reader("filters.csv", format: :map, col_sep: ";", comment_starts: "#")
      reader.filters = {
        :long => Jcsv.long,
        :big_num => Jcsv.bignum,
        :big_decimal => Jcsv.big_decimal(Locale::US),
        :big_decimal2 => Jcsv.big_decimal(Locale::BRAZIL),
        :big_decimal3 => Jcsv.big_decimal(Locale::BRAZIL),
        :http_time => Jcsv.http_time(Date::JULIAN),
        :iso8601_1 => Jcsv.iso8601(Date::ENGLAND),
        :iso8601_2 => Jcsv.iso8601(Date::GREGORIAN),
        :iso8601_3 => Jcsv.iso8601(Date::ITALY),     # Date::ITALY is the default start date
        :jd_1 => Jcsv.int(next_filter: Jcsv.jd),
        :jisx0301 => Jcsv.jisx0301 }
      
      filters = reader.read[0]
      p filters

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

  end

end
