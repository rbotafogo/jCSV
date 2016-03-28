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

require_relative '../config'

require 'jcsv'

class CSVTest < Test::Unit::TestCase

  context "CSV test" do

    setup do

    end
        
    #-------------------------------------------------------------------------------------
    # When reading the CSV file in one big chunk and selecting deep_map: true, then each
    # dimension will be hashed across all rows.  [This is not clear at all!!! IMPROVE.]
    #-------------------------------------------------------------------------------------

    should "parse multi-dimension csv file to map, chuk_size all and deep_map true" do

      reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all,
                           dimensions: [:treatment, :subject, :period], deep_map: true)

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # since we are reading with chunk_size = :all, then we will only get one chunk back.
      # Then we can get the first chunk by indexing read with 0: reader.read[0]
      treatment = reader.read[0]

      # get the dimensions
      treatment_type = reader.dimensions[:treatment]
      subject = reader.dimensions[:subject]
      period = reader.dimensions[:period]

      # variable labels has all dimension labels
      assert_equal(0, treatment_type.labels["placebo"])
      assert_equal(1, treatment_type.labels["Progabide"])
      assert_equal(1, subject.labels["2"])
      assert_equal(13, subject.labels["14"])
      assert_equal(58, subject.labels["59"])
      assert_equal(0, period.labels["1"])
      assert_equal(3, period.labels["4"])
      
      # p treatment
      # p treatment["placebo"]
      # p treatment["placebo"]["10"]
      assert_equal("14", treatment["placebo"]["10"]["1"][:"seizure.rate"])
      # p treatment["Progabide"]["31"]
      
    end

    #-------------------------------------------------------------------------------------
    # There is a large difference when parsing multidimensional CSV files with chunks and
    # no chunks.  When no chunks are selected, then each row is an independent row and
    # there is no way to get deep maps.
    #-------------------------------------------------------------------------------------

    should "parse multi-dimension csv file to map no chunk" do

      reader = Jcsv.reader("epilepsy.csv", format: :map,
                           dimensions: [:treatment, :subject, :period], deep_map: true)

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # since we are reading with chunk_size = :all, then we will only get one chunk back.
      # Then we can get the first chunk by indexing read with 0: reader.read[0]
      treatment = reader.read

      # p treatment

    end

    #-------------------------------------------------------------------------------------
    # There is a large difference when parsing multidimensional CSV files with chunks and
    # no chunks.  When no chunks are selected, then each row is an independent row and
    # there is no way to get deep maps.
    #-------------------------------------------------------------------------------------

    should "parse multi-dimension csv file to map, deep false" do

      reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all,
                           dimensions: [:treatment, :subject, :period])

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # since we are reading with chunk_size = :all, then we will only get one chunk back.
      # Then we can get the first chunk by indexing read with 0: reader.read[0]
      treatment = reader.read

      # p treatment

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "read data with dimensions and filters" do

      reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all,
                           dimensions: [:treatment, :subject, :period], deep_map: true,
                           default_filter: Jcsv.int)
      
      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # will raise an exception as :period is not a key.  Will break as soon as we read the
      # first period for the second user
      treatment = reader.read[0]
      
      # p treatment
      assert_equal(14, treatment["placebo"]["10"]["1"][:"seizure.rate"])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "read data with dimensions, filters and minimun dimensions" do

      reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all,
                           dimensions: [:subject, :period], deep_map: true,
                           default_filter: Jcsv.int)

      # reader.filters = {:treatment => Jcsv.string}
      
      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      # :treatment should be filtered by string.  Not yet implemented.... CHANGE!!
      reader.mapping = {:treatment => false, :patient => false}
      treatment = reader.read[0]
      # p treatment["1"]
      # p treatment["31"]
      
    end
    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------
=begin
    should "raise exception if key is repeated" do

      reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all,
                           dimensions: [:period], deep_map: true)

      # will raise an exception as :period is not a key.  Will break as soon as we read the
      # first period for the second user
      assert_raise ( RuntimeError ) { reader.read[0] }

    end
=end      
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "read data into flat map" do

      # paramenter deep_map: is not passed.  By default it is false
      reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all,
                           dimensions: [:subject, :period],
                           default_filter: Jcsv.int)

      # reader.filters = {:treatment => Jcsv.string}
      
      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      # :treatment should be filtered by string.  Not yet implemented.... CHANGE!!
      reader.mapping = {:treatment => false, :patient => false}
      treatment = reader.read[0]
      # p treatment[0]
      # p treatment[1]      

    end
    
    #-------------------------------------------------------------------------------------
    # When reading the CSV file in one big chunk and selecting deep_map: true, then each
    # dimension will be hashed across all rows.  [This is not clear at all!!! IMPROVE.]
    #-------------------------------------------------------------------------------------

    should "Show errors when dimensions are not in order or missing" do

      reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all, 
                           dimensions: [:period, :treatment, :subject], deep_map: true,
                           suppress_errors: true)

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # since we are reading with chunk_size = :all, then we will only get one chunk back.
      # Then we can get the first chunk by indexing read with 0: reader.read[0]
      treatment = reader.read[0]

      # get the dimensions
      treatment_type = reader.dimensions[:treatment]
      subject = reader.dimensions[:subject]
      period = reader.dimensions[:period]

      p treatment["1"]["placebo"]
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------
=begin
    should "raise execption when dimensions are out of order (slower moving to the left)" do

      # paramenter deep_map: is not passed.  By default it is false
      reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all,
                           dimensions: [:period, :subject], deep_map: true,
                           default_filter: Jcsv.int)

      reader.mapping = {:treatment => false, :patient => false}

      assert_raise ( RuntimeError ) { treatment = reader.read[0] }
      # p treatment["1"]
      # p treatment["2"]
      
    end
=end    

    
=begin

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file to a vector" do

      reader = Jcsv.reader("epilepsy.csv", headers: true, format: :vector, type: :double,
                           dimensions: ["subject", :period])
      reader.mapping = {:treatment => false}
      vector = reader.read

      # p vector
      array = MDArray.int([59, 4, 4], vector)
      array.print
      
    end

=end
    
  end

end
