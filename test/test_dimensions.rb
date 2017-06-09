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
    # Read data into a flat map.  Allows random access to the data by use of the map
    # 'key'.  The 'key' is a string that concatenates the values of the dimensions's
    # labels with a '.'.
    #-------------------------------------------------------------------------------------

    should "read data into flat map" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :map,
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)

      # reader.filters = {:treatment => Jcsv.string}
      
      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}
      
      # read all the data into a flat map (hash) with keys the dimensions values
      # concatenated with '.'.
      treatment = reader.read
      # p treatment

      assert_equal(11, treatment["placebo.1.1"][:base])
      assert_equal(31, treatment["placebo.1.1"][:age])
      assert_equal(5, treatment["placebo.1.1"][:"seizure.rate"])
      
      assert_equal(31, treatment["Progabide.35.2"][:base])
      assert_equal(30, treatment["Progabide.35.2"][:age])
      assert_equal(17, treatment["Progabide.35.2"][:"seizure.rate"])
      
    end
#=begin
    #-------------------------------------------------------------------------------------
    # Read data into a flat map in chunks
    #-------------------------------------------------------------------------------------

    should "read data into flat map in chunks" do

      # paramenter deep_map: is not passed.  By default it is false
      reader = Jcsv.reader("../data/epilepsy.csv", format: :map, chunk_size: 20,
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}
      treatment = reader.read
      # p treatment

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
      
      # we now need to access the first chunk [0] to get to the desired element
      assert_equal(11, treatment[0]["placebo.1.1"][:base])
      assert_equal(31, treatment[0]["placebo.1.1"][:age])
      assert_equal(5, treatment[0]["placebo.1.1"][:"seizure.rate"])

      # chunk [0] does not have key "Progabide.35.2"
      assert_equal(nil, treatment[0]["Progabide.35.2"])

      assert_equal(10, treatment[6]["Progabide.32.3"][:base])
      assert_equal(30, treatment[6]["Progabide.32.3"][:age])
      assert_equal(1, treatment[6]["Progabide.32.3"][:"seizure.rate"])

    end

    #-------------------------------------------------------------------------------------
    # 
    #-------------------------------------------------------------------------------------

    should "read to map in enumerable chunks" do

      # paramenter deep_map: is not passed.  By default it is false
      reader = Jcsv.reader("../data/epilepsy.csv", format: :map, chunk_size: 20,
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)

      # Method each without a block returns an enumerator
      enum = reader.each

      # read the first chunk.  Chunk is of size 20
      chunk = enum.next
      data = chunk[2]

      # in this case, only the first 20 rows were read, so only one treatment and six
      # subjects were read until this point
      assert_equal(1, reader.dimensions[:treatment].size)
      # assert_equal(6, reader.dimensions[:subject].size)

      assert_equal(8, data["placebo.4.4"][:base])
      assert_equal(36, data["placebo.4.4"][:age])
      assert_equal(4, data["placebo.4.4"][:"seizure.rate"])
      
      # read the next chunk.  Chunk is of size 20
      chunk = enum.next

      # read the next chunk... not interested in the second chunk for some reason...
      chunk = enum.next
      data = chunk[2]
      
      # As we read new chunks of data, the dimensions labels accumulate, i.e., they are
      # not erased between reads of every chunk (call to the next function).  Dimensions
      # are variables from the reader and not the chunk.
      assert_equal(1, reader.dimensions[:treatment].size)
      assert_equal(16, reader.dimensions[:subject].size)

      assert_equal(33, data["placebo.12.2"][:base])
      assert_equal(24, data["placebo.12.2"][:age])
      assert_equal(6, data["placebo.12.2"][:"seizure.rate"])
      
    end
    
    #-------------------------------------------------------------------------------------
    # 
    #-------------------------------------------------------------------------------------

    should "read to map and pass to block with dimensions" do

      # paramenter deep_map: is not passed.  By default it is false
      reader = Jcsv.reader("../data/epilepsy.csv", format: :map,
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)
      
      reader.read do |line_no, row_no, row|
        assert_equal(1, row.keys.size)
      end
      
    end
    
    #-------------------------------------------------------------------------------------
    # 
    #-------------------------------------------------------------------------------------

    should "read to map and pass to block with dimensions, chunk_size > 1" do

      # paramenter deep_map: is not passed.  By default it is false
      reader = Jcsv.reader("../data/epilepsy.csv", format: :map, chunk_size: 20,
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)
      
      reader.read do |line_no, row_no, row|
        assert_equal(20, row.keys.size) if line_no < 230
      end
      
    end

    #-------------------------------------------------------------------------------------
    # 
    #-------------------------------------------------------------------------------------

    should "raise error if mapping a column to true" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :map, chunk_size: :all,
                           dimensions: [:subject, :period],
                           default_filter: Jcsv.int)

      # Raises an error, since mapping to true is not defined
      assert_raise ( ArgumentError ) { reader.mapping =
                                       {:treatment => false, :patient => true} }

    end
#=end    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------
=begin
    should "raise exception when dimensions are out of order (slower moving to the left)" do

      reader = Jcsv.reader("epilepsy.csv", format: :map, dimensions: [:period, :subject],
                           default_filter: Jcsv.int)

      reader.mapping = {:treatment => false, :patient => false}

      assert_raise ( RuntimeError ) { treatment = reader.read[0] }
      # p treatment["1"]
      # p treatment["2"]
      
    end
=end    

  end

end
