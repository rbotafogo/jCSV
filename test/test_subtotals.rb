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

  end
  
end
