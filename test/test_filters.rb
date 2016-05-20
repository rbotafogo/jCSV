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

      reader = Jcsv.reader("../data/filters.csv", format: :map, col_sep: ";",
                           comment_starts: "#")
      
      bool = Jcsv.bool(true_values: ["sim", "s", "verdadeiro", "v"],
                       false_values: ["nao", "n", "falso", "f"])

      # supports int and long filters, but in Ruby it is better to use the fixnum
      # filter
      reader.filters = {
        :int => Jcsv.int >> Jcsv.in_range(200, 300),
        :double => Jcsv.float,
        :double2 => Jcsv.float(Locale::US),
        :long => Jcsv.long,
        :complex => Jcsv.complex,
        :rational => Jcsv.rational,
        :big_num => Jcsv.bignum,
        :big_decimal => Jcsv.big_decimal(Locale::US),
        :big_decimal2 => Jcsv.big_decimal(Locale::BRAZIL),
        :big_decimal3 => Jcsv.big_decimal(Locale::BRAZIL),
        :truth1 => Jcsv.bool,
        :truth2 => bool,
        :truth3 => bool,
        :name => Jcsv.in_range("P", "Q"),
        :ip1 => Jcsv.ipaddr >> Jcsv.dynamic { |val| val.to_i } }

      filters = reader.read[0]
      p filters

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse dates" do

      reader = Jcsv.reader("../data/dates.csv", format: :map, col_sep: ";",
                           comment_starts: "#")
      
      reader.filters = {
        :httpdate => Jcsv.httpdate(Date::JULIAN),
        :iso8601_1 => Jcsv.iso8601(Date::ENGLAND),
        :iso8601_2 => Jcsv.iso8601(Date::GREGORIAN),
        :iso8601_3 => Jcsv.iso8601(Date::ITALY),     # Date::ITALY is the default start date
        :jd_1 => Jcsv.int >> Jcsv.jd,
        :jisx0301 => Jcsv.jisx0301,
        :date1 => Jcsv.date,
        :date2 => Jcsv.date,
        :date3 => Jcsv.date,
        :rfc2822 => Jcsv.rfc2822,
        :rfc3339 => Jcsv.rfc3339,
        :rfc822 => Jcsv.rfc822,
        :ptime1 => Jcsv.strptime('%Y-%m-%dT%H:%M:%S%z'),
        :xmlschema => Jcsv.xmlschema }
      
      filters = reader.read[0]
      
      assert_equal(DateTime.httpdate('Sat, 03 Feb 2001 04:05:06 GMT', Date::JULIAN),
                   filters[:httpdate])
      assert_equal(DateTime.iso8601('2001-02-03T04:05:06+07:00', Date::ENGLAND),
                   filters[:iso8601_1])
      assert_equal(DateTime.iso8601('20010203T040506+0700', Date::GREGORIAN),
                   filters[:iso8601_2])
      assert_equal(DateTime.iso8601('2001-W05-6T04:05:06+07:00'), filters[:iso8601_3])
      assert_equal(DateTime.jd(2451944), filters[:jd_1])
      assert_equal(DateTime.jisx0301('H13.02.03T04:05:06+07:00'), filters[:jisx0301])
      assert_equal(DateTime.parse('2001-02-03T04:05:06+07:00'), filters[:date1])
      assert_equal(DateTime.parse('20010203T040506+0700'), filters[:date2])
      assert_equal(DateTime.parse('3rd Feb 2001 04:05:06 PM'), filters[:date3])
      assert_equal(DateTime.rfc2822('Sat, 3 Feb 2001 04:05:06 +0700'), filters[:rfc2822])
      assert_equal(DateTime.rfc3339('2001-02-03T04:05:06+07:00'), filters[:rfc3339])
      assert_equal(DateTime.rfc822('Sat, 3 Feb 2001 04:05:06 +0700'), filters[:rfc822])
      assert_equal(DateTime.strptime('2001-02-03T04:05:06+07:00', '%Y-%m-%dT%H:%M:%S%z'),
                   filters[:ptime1])
      assert_equal(DateTime.xmlschema('2001-02-03T04:05:06+07:00'), filters[:xmlschema])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "filter data onto a collector" do

      # type is :map. Rows are hashes. Set the default filter to not_nil. That is, all
      # fields are required unless explicitly set to optional.
      reader = Jcsv.reader("../data/customer.csv", format: :map, chunk_size: 2)

      first_names = Jcsv.collector
      last_names = Jcsv.collector
      kids = Jcsv.collector
      
      reader.filters = {
        :first_name => first_names,
        :last_name => last_names,
        :number_of_kids => Jcsv.convert_nil_to(-1) >> Jcsv.fixnum >> kids
      }
      
      map = reader.read
      assert_equal(["John", "Bob", "Alice", "Bill"], first_names.collection)
      assert_equal(["Dunbar", "Down", "Wunderland", "Jobs"], last_names.collection)
      assert_equal([-1, 0, 0, 3], kids.collection)

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "accept optional fields" do

      reader = Jcsv.reader("../data/customer.csv", format: :map, chunk_size: 2,
                           default_filter: Jcsv.not_nil)
      reader.filters = {
        :number_of_kids => Jcsv.optional >> Jcsv.fixnum,
        :married => Jcsv.optional
      }
      map = reader.read
      # p map
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "work with dynamic filter" do

      reader = Jcsv.reader("../data/BJsales.csv", format: :map)

      rate = 3.75      # dollar to reais convertion rate
      
      reader.filters = {
        :b_jsales => Jcsv.optional >> Jcsv.float(Locale::US) >>
                     Jcsv.in_range(0, 300) >> Jcsv.dynamic { |value| value * rate }
      }
      
      map = reader.read
      assert_equal(200.1 * rate, map[0][:b_jsales])
      assert_equal(199.5 * rate, map[1][:b_jsales])
      assert_equal(199.4 * rate, map[2][:b_jsales])
      assert_equal(198.9 * rate, map[3][:b_jsales])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "create new filters" do

      reader = Jcsv.reader("../data/BJsales.csv", format: :map)

      class RangeFilter < Jcsv::Filter

        def initialize(start, final)
          @start = start
          @final = final
          super()
        end

        def execute(value, context)
          # check the constraint and raise an exception if ConstraintViolation
          raise Jcsv::ConstraintViolation, "value not in range in #{context}" if
            value < @start || value > @final
          # Call next filter
          exec_next(value, context)
        end
          
      end
      
      rate = 3.75      # dollar to reais convertion rate
      
      reader.filters = {
        :b_jsales => Jcsv.optional >> Jcsv.float(Locale::US) >>
                     RangeFilter.new(0, 200) >> Jcsv.dynamic { |value| value * rate }
      }

      assert_raise ( Jcsv::ConstraintViolation ) { map = reader.read }
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "gsub strings" do

      reader = Jcsv.reader("../data/customer.csv", format: :map)

      reader.filters = {
        :mailing_address => Jcsv.gsub(/[eao]/, 'e' => 3, 'o' => '*', 'a' => 'A'),        
        :first_name => Jcsv.gsub(/[aeiou]/, '*'),
        :last_name => Jcsv.gsub(/([aeiou])/, '<\1>'),
        :customer_no => Jcsv.gsub(/./) {|s| s.ord.to_s + ' '} >> Jcsv.fixnum
      }

      map = reader.read

      assert_equal("J*hn", map[0][:first_name])
      assert_equal("D<u>nb<a>r", map[0][:last_name])
      assert_equal(49, map[0][:customer_no])
      assert_equal("1600 Amphith3Atr3 PArkwAy\nM*untAin Vi3w, CA 94043\nUnit3d StAt3s",
                   map[0][:mailing_address])
      assert_equal("Al*c*", map[2][:first_name])
      assert_equal("D<o>wn", map[1][:last_name])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "process with any string functions" do

      reader = Jcsv.reader("../data/customer.csv", format: :map)

      reader.filters = {
        :mailing_address => Jcsv.str(:[], 0, 10),
        :first_name => Jcsv.str(:delete, "aeiou"),
        :last_name => Jcsv.str(:partition, "n"),
        :favourite_quote => Jcsv.str(:reverse) >> Jcsv.str(:prepend, "rev: ") >>
                            Jcsv.str(:[], 0, 20),
        :email => Jcsv.str(:gsub, /[eao]/, 'e' => 3, 'o' => '*', 'a' => 'A')
      }

      map = reader.read
      assert_equal("Jhn", map[0][:first_name])
      assert_equal(["Du", "n", "bar"], map[0][:last_name])
      assert_equal("1600 Amphi", map[0][:mailing_address])
      assert_equal("rev: sraW ratS - \".u", map[0][:favourite_quote])
      assert_equal("jdunbAr@gmAil.c*m", map[0][:email])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "raise errors on contraints" do

      reader = Jcsv.reader("../data/city.csv", format: :map, col_sep: ";")

      reader.filters = {
        # :city => Jcsv.equals
        :city => Jcsv.not_ascii?
        # :city => Jcsv.end_with?("ka")
      }

      phones = reader.read
      # p phones
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "raise error if substring found" do

      reader = Jcsv.reader("../data/customer.csv", format: :map)

      reader.filters = {
        :first_name => Jcsv.forbid_substrings(["jh", "paw", "Jp"]),
        :last_name => Jcsv.is_element_of(["Dunbar", "Down", "Wunderland", "Jobs"])
      }

      customers = reader.read
      # p customers
      
    end

  end
  
end
