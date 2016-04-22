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

require 'pp'
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

    should "parse multi-dimension csv into a critbit, alphabetical order" do
      
      reader = Jcsv.reader("../data/customer.csv", format: :critbit,
                           dimensions: [:last_name, :first_name])

      customers = reader.read
      assert_equal("Down.Bob", customers.keys[0])
      assert_equal("Dunbar.John", customers.keys[1])
            
      reader = Jcsv.reader("../data/customer.csv", format: :critbit,
                           dimensions: [:first_name, :last_name])

      customers = reader.read
      assert_equal("Alice.Wunderland", customers.keys[0])
      assert_equal("Bill.Jobs", customers.keys[1])

    end

    #-------------------------------------------------------------------------------------
    # Read data into a flat map.  Allows random access to the data by use of the map
    # 'key'.  The 'key' is a string that concatenates the values of the dimensions's
    # labels with a '.'.
    #-------------------------------------------------------------------------------------

    should "read data into flat critbit" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit,
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)

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

    #-------------------------------------------------------------------------------------
    # Read data into a flat map in chunks
    #-------------------------------------------------------------------------------------

    should "read data into flat critbit in chunks" do

      # paramenter deep_map: is not passed.  By default it is false
      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: 20,
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

    should "read to critbit in enumerable chunks" do

      # paramenter deep_map: is not passed.  By default it is false
      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: 20,
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

    should "read to critbit and pass to block with dimensions" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit,
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)
      
      reader.read do |line_no, row_no, row|
        assert_equal(1, row.keys.size)
      end
      
    end

    #-------------------------------------------------------------------------------------
    # 
    #-------------------------------------------------------------------------------------

    should "read to critbit and pass to block with dimensions, chunk_size > 1" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: 20,
                           dimensions: [:treatment, :subject, :period],
                           default_filter: Jcsv.int)
      
      reader.read do |line_no, row_no, row|
        assert_equal(20, row.keys.size) if line_no < 230
      end
      
    end

    #-------------------------------------------------------------------------------------
    # 
    #-------------------------------------------------------------------------------------

    should "raise error if mapping a column to true in critbit" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: :all,
                           dimensions: [:subject, :period],
                           default_filter: Jcsv.int)

      # Raises an error, since mapping to true is not defined
      assert_raise ( RuntimeError ) { reader.mapping =
                                      {:treatment => false, :patient => true} }

    end

    #-------------------------------------------------------------------------------------
    # When reading the CSV file in one big chunk and selecting deep_map: true, then each
    # dimension will be hashed across all rows.
    #-------------------------------------------------------------------------------------

    should "parse multi-dimension csv file to critbit, chuk_size all and deep_map true" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: :all,
                           dimensions: [:treatment, :subject, :period], deep_map: true)

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # since we are reading with chunk_size = :all, then we will only get one chunk back.
      # Then we can get the first chunk by indexing read with 0: reader.read[0]
      treatment = reader.read[0]
      # p treatment
      
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
      
      assert_equal("14", treatment["placebo"]["10"]["1"][:"seizure.rate"])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "read data with dimensions, mapping and filters into a critbit" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: :all,
                           dimensions: [:treatment, :subject, :period], deep_map: true,
                           default_filter: Jcsv.int)
      
      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}
      reader.filters = {:"seizure.rate" => Jcsv.float}

      # will raise an exception as :period is not a key.  Will break as soon as we read the
      # first period for the second user
      treatment = reader.read[0]
      # p treatment

      assert_equal(14.0, treatment["placebo"]["10"]["1"][:"seizure.rate"])
      assert_equal(19.0, treatment["Progabide"]["45"]["1"][:"seizure.rate"])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "read data with deep_map in critbit but chunk_size not all" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: 20,
                           dimensions: [:treatment, :subject, :period], deep_map: true,
                           default_filter: Jcsv.int)
      
      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}
      reader.filters = {:"seizure.rate" => Jcsv.float}

      # will raise an exception as :period is not a key.  Will break as soon as we read the
      # first period for the second user
      treatment = reader.read
      
      assert_equal(3.0, treatment[0]["placebo"]["2"]["1"][:"seizure.rate"])
      # since only 20 rows read per chunk, there is no Progabide row yet. Note that there
      # was data in the test above
      assert_equal(nil, treatment[0]["Progabide"])

      # chunk 10, has Progabide as a dimension
      assert_equal(6.0, treatment[10]["Progabide"]["51"]["2"][:"seizure.rate"])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "raise exception if key is repeated in critbit" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: :all,
                           dimensions: [:period], deep_map: true)

      # will raise an exception as :period is not a key.  Will break as soon as we read the
      # first period for the second user
      assert_raise ( RuntimeError ) { reader.read[0] }

    end

    #-------------------------------------------------------------------------------------
    # When reading the CSV file in one big chunk and selecting deep_map: true, then each
    # dimension will be hashed across all rows.  [This is not clear at all!!! IMPROVE.]
    #-------------------------------------------------------------------------------------

    should "Show errors when dimensions are not in order or missing in critbit" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: :all, 
                           dimensions: [:period, :treatment, :subject], deep_map: true)

      p "LOTS OF ERROR MESSAGES EXPECTED FROM HERE..."
      
      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # since we are reading with chunk_size = :all, then we will only get one chunk back.
      # Then we can get the first chunk by indexing read with 0: reader.read[0]
      treatment = reader.read[0]

      p "... TO HERE.  If no error messages, then something is wrong!"
      
    end

    #-------------------------------------------------------------------------------------
    # When reading the CSV file in one big chunk and selecting deep_map: true, then each
    # dimension will be hashed across all rows.  [This is not clear at all!!! IMPROVE.]
    #-------------------------------------------------------------------------------------

    should "Suppress warnings when dimensions are not in order or missing in critbit" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: :all, 
                           dimensions: [:period, :treatment, :subject], deep_map: true,
                           suppress_warnings: true)

      p "No warning messages should be seen from here..."
      
      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # since we are reading with chunk_size = :all, then we will only get one chunk back.
      # Then we can get the first chunk by indexing read with 0: reader.read[0]
      treatment = reader.read
      # p treatment

      p "... to here.  If there are any warning messages then there is something wrong!"
      
    end

    #-------------------------------------------------------------------------------------
    # There is a large difference when parsing multidimensional CSV files with chunks and
    # no chunks.  When no chunks are selected, this is identical to normal dimension
    # reading.
    #-------------------------------------------------------------------------------------

    should "parse multi-dimension csv file to critbit no chunk" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit,
                           dimensions: [:treatment, :subject, :period], deep_map: true)

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # since we are reading with chunk_size = :all, then we will only get one chunk back.
      # Then we can get the first chunk by indexing read with 0: reader.read[0]
      treatment = reader.read
      # p treatment
      
      assert_equal("11", treatment["placebo.1.1"][:base])
      assert_equal("31", treatment["placebo.1.1"][:age])
      assert_equal("5", treatment["placebo.1.1"][:"seizure.rate"])
      
      assert_equal("11", treatment["placebo.1.2"][:base])
      assert_equal("31", treatment["placebo.1.2"][:age])
      assert_equal("3", treatment["placebo.1.2"][:"seizure.rate"])

    end

    #-------------------------------------------------------------------------------------
    # All examples until now had chunk_size :all, but they can have smaller size.  In this
    # example, chunk_size is 20 and it is processed by a block
    #-------------------------------------------------------------------------------------

    should "read with dimension and given a block in critbit" do

      reader = Jcsv.reader("../data/epilepsy.csv", format: :critbit, chunk_size: 20,
                           dimensions: [:treatment, :subject, :period], deep_map: true, 
                           default_filter: Jcsv.int)

      reader.mapping = {:patient => false}

      reader.read do |line_no, row_no, chunk|
        p line_no
        p row_no
        p chunk 
      end

    end

  end
  
end
