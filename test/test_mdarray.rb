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

      # method [] of reader returns the labels of the given dimension.  Headers can be
      # obtained by doing reader[:_data_], _data_ is the header dimension
      assert_equal(["1", "2"], reader[:person])
      assert_equal(["2001", "2002", "2003"], reader[:year])
      assert_equal([:income, :age, :sex], reader[:_data_])

      # Take a section of the MDArray.  Get all data values from person 1
      balanced_panel.section([0, 0, 0],
                             [1, reader[:year].size, reader[:_data_].size]).print

      # Get the income for both persons for year 2001 and calculate their mean
      puts balanced_panel.section([0, 0, 0],
                                  [reader[:person].size, 1, 1], true).
            reset_statistics.mean
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "read unbalanced panel data" do

      # Note that in this case the data is unbalanced, i.e., there are two entries for
      # person 1, 3 entries for person 2 and one entry for person 3.  jCSV will
      # automatically fill the missing data with NaN.
      
      # person,year,income,age,sex
      # 1,2001,1600,23,1
      # 1,2002,1500,24,1
      # 2,2001,1900,41,2
      # 2,2002,2000,42,2
      # 2,2003,2100,43,2
      # 3,2002,3300,34,1
      
      reader = Jcsv.reader("../data/unbalanced_panel.csv", format: :mdarray,
                           dtype: :double, dimensions: [:person, :year])
      ub_panel = reader.read
      
      assert_equal(["1", "2", "3"], reader[:person])
      assert_equal(["2001", "2002", "2003"], reader[:year])
      assert_equal([:income, :age, :sex], reader[:_data_])

      # The following data is expected after reading the unbalanced data
      
      # person,year,income,age,sex
      # 1,2001,1600,23,1
      # 1,2002,1500,24,1
      # 1,2003,NaN,NaN,NaN
      # 2,2001,1900,41,2
      # 2,2002,2000,42,2
      # 2,2003,2100,43,2
      # 3,2001,NaN,NaN,NaN
      # 3,2002,3300,34,1
      # 3,2003,NaN,NaN,NaN

      assert_equal(1600, ub_panel[0, 0, 0])
      assert_equal(true, ub_panel[0, 2, 0].nan?)
      assert_equal(34, ub_panel[2, 1, 1])
      assert_equal(true, ub_panel[2, 2, 2].nan?)

    end
    

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "convert to MDArray" do

      # Data which show the effect of two soporific drugs (increase in hours of sleep
      # compared to control) on 10 patients.      

      reader = Jcsv.reader("../data/sleep.csv", format: :mdarray, col_sep: ";",
                           comment_starts: "#", dtype: :float,
                           dimensions: [:group, :id])
      reader.mapping = {:row => false}
      ssleep = reader.read
      # ssleep.print
      
      group1 = ssleep.slice(0, 0)
      group2 = ssleep.slice(0, 1)

      # Print many statistics about group1. Need to call reset_statistics on group1 to
      # prepare it for calculations and clear all the caches.  Calculations are
      # cached, for example, when the mean is calculated it will be cached.  When the
      # standard deviation is calculated, there is no need to calculate the mean again,
      # since it has already been calculated.  Thre problem with this approach is that
      # if the array is changed in any way, then reset_statistics needs to be called
      # again or all cached values will be returned again.
      group1.reset_statistics

      puts "correlation group1 vs group2: " +  group1.correlation(group2).to_s
      puts "auto correlation: " + group1.auto_correlation(1).to_s
      puts "durbin watson: " + group1.durbin_watson.to_s
      puts "geometric mean: " + group1.geometric_mean.to_s
      puts "harmonic mean: " + group1.harmonic_mean.to_s
      puts "kurtosis: " + group1.kurtosis.to_s
      puts "lag1: " + group1.lag1.to_s
      puts "max: " + group1.max.to_s
      puts "mean: " + group1.mean.to_s
      puts "mean deviation: " + group1.mean_deviation.to_s
      puts "median: " + group1.median.to_s
      puts "min: " + group1.min.to_s
      puts "moment3: " + group1.moment3.to_s
      puts "moment4: " + group1.moment4.to_s
      puts "product: " + group1.product.to_s
      puts "quantile(0.2): " + group1.quantile(0.2).to_s
      puts "quantile inverse(35.0): " + group1.quantile_inverse(35.0).to_s
      puts "rank interpolated(33.0): " + group1.rank_interpolated(33.0).to_s
      puts "rms: " + group1.rms.to_s
      puts "sample kurtosis: " + group1.sample_kurtosis.to_s
      puts "sample kurtosis standard error: " + group1.sample_kurtosis_standard_error.to_s
      puts "sample skew: " + group1.sample_skew.to_s
      puts "sample skew standard error: " + group1.sample_skew_standard_error.to_s
      puts "sample standard deviation: " + group1.sample_standard_deviation.to_s
      puts "sample variance: " + group1.sample_variance.to_s
      puts "skew: " + group1.skew.to_s
      puts "standard deviation: " + group1.standard_deviation.to_s
      puts "standard error: " + group1.standard_error.to_s
      puts "sum: " + group1.sum.to_s
      puts "sum of inversions: " + group1.sum_of_inversions.to_s
      puts "sum of logarithms: " + group1.sum_of_logarithms.to_s
      puts "sum of power deviations: " + group1.sum_of_power_deviations(2, group1.mean).to_s
      puts "sum of powers(3): " + group1.sum_of_powers(3).to_s
      puts "sum of squares: " + group1.sum_of_squares.to_s
      puts "sum of squared deviations: " + group1.sum_of_squared_deviations.to_s
      puts "trimmed_mean(2, 2): " + group1.trimmed_mean(2, 2).to_s
      puts "variance: " + group1.variance.to_s
      puts "winsorized mean: " + group1.winsorized_mean(1, 1).to_s
      
    end
=begin
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
