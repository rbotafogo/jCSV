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

    should "read balanced panel data" do

      # person,year,income,age,sex
      # 1,2001,1300,27,1
      # 1,2002,1600,28,1
      # 1,2003,2000,29,1
      # 2,2001,2000,38,2
      # 2,2002,2300,39,2
      # 2,2003,2400,40,2

      reader = Jcsv.reader("../data/balanced_panel.csv", format: :mdarray, dtype: :double,
                           dimensions: [:person, :year])
      balanced_panel = reader.read

      assert_equal(["1", "2"], reader[:person])
      assert_equal(["2001", "2002", "2003"], reader[:year])
      assert_equal([:income, :age, :sex], reader[:data])

      # Take a section of the MDArray.  Get all data values from person 1
      balanced_panel.section([0, 0, 0],
                             [1, reader[:year].size, reader[:data].size]).print

      # Get the income for both persons for year 2001 and calculate their mean
      puts balanced_panel.section([0, 0, 0],
                                  [reader[:person].size, 1, 1], true).
            reset_statistics.mean
      
    end
=begin
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "convert to MDArray" do

      reader = Jcsv.reader("../data/sleep.csv", format: :mdarray, col_sep: ";",
                           comment_starts: "#", dtype: :float,
                           dimensions: [:group, :id])
      reader.mapping = {:row => false}
      ssleep = reader.read
      ssleep.print

      ssleep.slice(0,0).print
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "convert csv data to an MDArray" do

      reader = Jcsv.reader("../data/epilepsy.csv", headers: true, format: :mdarray,
                           dtype: :double, dimensions: [:treatment, :subject, :period])
      treatment = reader.read
      # treatment.print
      treatment.slice(0,0).print
      
    end
=end
  end
  
end
