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
require 'date'

require_relative '../config' if !@platform

require 'jcsv'

class CSVTest < Test::Unit::TestCase

  context "CSV test" do

    setup do

      def match(str, subtotals)
        sub = str.split(".")

        regex_spec = ""
        (0..(sub.length - 2)).each do |i|
          regex_spec << sub[i] << ".*\\..*"
        end
        regex_spec << sub[-1]
        regex = Regexp.new(regex_spec)
        
        # keys.find_all { |e| regex =~ e }

        total = 0
        subtotals.each_pair do |k, v|
          if regex =~ k
            # p "#{k} #{v}"
            total += v
          end
        end

        total
      end

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "read csv file and find subtotals" do

      reader = Jcsv.reader("../data/subtotal.csv", format: :map,
                           subtotals: {:quantity => :sum, :tip => :sum})

      reader.filters = {:quantity => Jcsv.int, :tip => Jcsv.float, :date => Jcsv.date}
      
      reader.read {}

      # Subtotal´s keys are converted to Strings so that one can do subtotal search by
      # substrings, as we will see in another example
      assert_equal(21.0, reader.grand_totals["quantity"])
      assert_equal(500, reader.grand_totals["tip"])
      
    end

    #-------------------------------------------------------------------------------------
    # Subtotal´s keys are converted to Strings so that one can do subtotal search by
    # substrings, as we will see in another example
    #-------------------------------------------------------------------------------------

    should "read csv file and find subtotals with dimensions" do

      # Note that the dimensions used and their order is critical to the results
      # obtained.  Let´s start with only one dimension: :vendor
      reader = Jcsv.reader("../data/sales.csv", format: :map,
                           dimensions: [:vendedor],
                           subtotals: {:faturamento => :sum},
                           :suppress_warnings => true)

      reader.filters = {:mes => Jcsv.date, :faturamento => Jcsv.float(Jcsv::Locale::BRAZIL)}
      
      reader.read {}
      
      assert_equal(11_200, reader.grand_totals["faturamento"])
      assert_equal(2_700, reader.subtotals["Célia.faturamento"])
      assert_equal(2_060, reader.subtotals["Francisco.faturamento"])
      assert_equal(1_120, reader.subtotals["José.faturamento"])
      assert_equal(1_500, reader.subtotals["Marcos.faturamento"])
      assert_equal(1_780, reader.subtotals["Maria.faturamento"])

      # Let´s read again the same file with two dimensions now, :vendedor and :mês.  Note
      # that although the data has :mês before :vendedor, we can swap the dimensions
      # order.
      reader = Jcsv.reader("../data/sales.csv", format: :map,
                           dimensions: [:vendedor, :mês],
                           subtotals: {:faturamento => :sum},
                           :suppress_warnings => true)

      reader.filters = {:mes => Jcsv.date, :faturamento => Jcsv.float(Jcsv::Locale::BRAZIL)}
      
      reader.read {}

      # note that now we have the subtotals first by the name of the seler and then by
      # month
      assert_equal(550, reader.subtotals["Célia.jan-15.faturamento"])
      assert_equal(430, reader.subtotals["Francisco.jan-15.faturamento"])
      
      # Let´s read again the same file with dimensions, :região, :vendedor.  Note
      # that although the data has :mês before :vendedor, we can swap the dimensions
      # order.
      reader = Jcsv.reader("../data/sales.csv", format: :map,
                           dimensions: [:região, :vendedor],
                           subtotals: {:faturamento => :sum},
                           :suppress_warnings => true)

      reader.filters = {:mes => Jcsv.date, :faturamento => Jcsv.float(Jcsv::Locale::BRAZIL)}
      
      reader.read {}

      pp reader.subtotals

    end
    
=begin    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "generate subtotals for dimensions" do
      
      #subtotals: :count, :sum, :mean, :max, :min, :formula
      # subtotal: {:quantity => :count, :tip => :mean}])

      reader = Jcsv.reader("../data/subtotal.csv", format: :map, dimensions: [:date, :type],
                           subtotals: {:quantity => :sum, :tip => :sum})

      reader.filters = {:quantity => Jcsv.int, :tip => Jcsv.float, :date => Jcsv.date}
      
      reader.read do |line_no, row_no, row, headers|
        # p row
      end

      p "matched visa"
      p match(".visa.qu", reader.subtotals)
      puts ""

      p "matched tip"
      p match("T16..tip", reader.subtotals)
      puts ""
      
      # prety print all subtotals
      pp reader.subtotals
      # pp reader.grand_totals

      # Retrieve subtotals by prefix
      # reader.subtotals.each_pair("2011-11-14T16:") do |key, val|
        # p "#{key}: #{val}"
      # end

      # p reader.subtotals["2011-11-14T16:53:41Z.tab.quantity"]
      
    end
=end
  end
  
end
