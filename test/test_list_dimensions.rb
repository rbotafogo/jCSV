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

require 'test/unit'
require 'shoulda'

require_relative '../config'

require 'jcsv'

class CSVTest < Test::Unit::TestCase

  context "CSV test" do

    setup do

    end
        
    #-------------------------------------------------------------------------------------
    # Read data into a list. 
    #-------------------------------------------------------------------------------------

    should "read panel data into a list" do

      reader = Jcsv.reader("../data/epilepsy.csv",
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}
      
      # read all the data into a flat map (hash) with keys the dimensions values
      # concatenated with '.'.
      treatment = reader.read
      # p treatment

      assert_equal(["placebo", "1", "1"], treatment[0][0])
      assert_equal([1, 11, 31, 5], treatment[0][1..-1])
      assert_equal(["placebo", "2", "2"], treatment[5][0])
      
    end

    #-------------------------------------------------------------------------------------
    # Read data into a list with chunk_size
    #-------------------------------------------------------------------------------------

    should "read panel data into a list with chunk size" do

      # deep_map is ignored if reading into a list
      reader = Jcsv.reader("../data/epilepsy.csv", chunk_size: 20, deep_map: true,
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}
      
      # read all the data into a flat map (hash) with keys the dimensions values
      # concatenated with '.'.
      treatment = reader.read
      # p treatment[0]
      # p treatment[10]

      assert_equal(["placebo", "1", "1"], treatment[0][0][0])
      assert_equal(["placebo", "2", "2"], treatment[0][5][0])
      assert_equal(["placebo", "16", "1"], treatment[3][0][0])
      assert_equal(["Progabide", "52", "4"], treatment[10][7][0])

    end

    #-------------------------------------------------------------------------------------
    # Read data into a list. 
    #-------------------------------------------------------------------------------------

    should "read more panel data" do
      
      reader = Jcsv.reader("../data/GoodOrder.csv", col_sep: ";",
                           dimensions: [:dim_1, :dim_2, :dim_3])
      reader.filters = {
        :data => Jcsv.int,
      }
      
      table = reader.read
      # p table
      
    end
    
  end
  
end
