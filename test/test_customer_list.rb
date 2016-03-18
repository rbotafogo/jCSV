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

require_relative '../config'
require 'jcsv'

class CSVTest < Test::Unit::TestCase

  context "CSV test" do

    setup do

    end

#=begin
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file the quick way with headers" do

      # Reads all rows in memory and return and array of arrays. Each line is stored in
      # one array.  Data is stored in the 'rows' instance variable.
      # Create the reader with all default parameters.  Headers are converted from string
      # to symbol
      reader = Jcsv.reader("customer.csv")
            
      # now read the whole csv file
      content = reader.read

      # Headers are converted to symbol
      assert_equal([:customerno, :firstname, :lastname, :birthdate, :mailingaddress,
                    :married, :numberofkids, :favouritequote, :email, :loyaltypoints],
                   reader.headers)
      
      assert_equal(["1", "John", "Dunbar", "13/06/1945",
                    "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States",
                    nil, nil, "\"May the Force be with you.\" - Star Wars",
                    "jdunbar@gmail.com", "0"], content[0])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "leave headers as string" do

      # Reads all rows in memory and return and array of arrays. Each line is stored in
      # one array.  Data is stored in the 'rows' instance variable.
      # Headers are kept as strings instead of symbol
      reader = Jcsv.reader("customer.csv", strings_as_keys: true)

      # now read the whole csv file
      content = reader.read

      assert_equal(["customerNo", "firstName", "lastName", "birthDate", "mailingAddress",
                    "married", "numberOfKids", "favouriteQuote", "email", "loyaltyPoints"],
                   reader.headers)
      
    end
    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file passing a block" do
      
      # read lines and pass them to a block for processing. The block receives the
      # line_no (last line of the record), row_no, row and the headers.  If has_haders is
      # false, then headers will be nil. Instead of
      # method foreach, one could also use method 'read' with a block.  'read' and
      # 'foreach' are identical. 
      reader = Jcsv.reader("customer.csv", headers: true, strings_as_keys: true)
      
      reader.read do |line_no, row_no, row, headers|
        assert_equal(4, line_no) if row_no == 2
        assert_equal(7, line_no) if row_no == 3
        assert_equal(10, line_no) if row_no == 4
        assert_equal(13, line_no) if row_no == 5
        
        assert_equal(["customerNo", "firstName", "lastName", "birthDate",
                      "mailingAddress", "married", "numberOfKids", "favouriteQuote",
                      "email", "loyaltyPoints"], headers)

        # Since the file has a header, the third record is row_no = 4
        assert_equal(["3", "Alice", "Wunderland",
                      "08/08/1985", "One Microsoft Way\nRedmond, WA 98052-6399\nUnited States",
                      "Y", "0", "\"Play it, Sam. Play \"As Time Goes By.\"\" - Casablanca",
                      "throughthelookingglass@yahoo.com", "2255887799"], row) if row_no == 4
      end
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file with filters" do

      # Add filters, to filter the columns according to given rules. numberOfKids is
      # optional and should be converted to and int.  married is optional and should be
      # converted to a boolean
      parser = Jcsv.reader("customer.csv", default_filter: Jcsv.not_nil)

      # Add filters, so that we get 'objects' instead of strings for filtered fields
      parser.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                        :married => Jcsv.optional(Jcsv.bool),
                        :customerno => Jcsv.int,
                        :birthdate => Jcsv.date("dd/MM/yyyy")}
      
      parser.read do |line_no, row_no, row, headers|

        # First field is customer number, which is converted to int
        assert_equal(1, row[0]) if row_no == 2
        assert_equal("John", row[1]) if row_no == 2
        # Field 5 is :married.  It is optional, so leaving it blank (nil) is ok.
        assert_equal(nil, row[5]) if row_no == 2

        # notice that field married that was "Y" is now true. Number of kids is not "0",
        # but 0, customerNo is also and int
        assert_equal(true, row[5]) if row_no == 3
        
      end
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file in chunks passing a block" do
      
      # Read chunks of the file.  In this case, we are breaking the file in chunks of 2
      reader = Jcsv.reader("customer.csv", chunk_size: 2)

      # Add filters, so that we get 'objects' instead of strings for filtered fields
      reader.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                        :married => Jcsv.optional(Jcsv.bool),
                        :customerno => Jcsv.int}

      reader.each do |line_no, row_no, chunk, headers|

        # line_no and row_no are the last read line_no and row_no of the chunk.  Since we
        # have headers and are reading in chunks of two, the first chunk has row_no = 3
        assert_equal([[1, "John", "Dunbar", "13/06/1945",
                       "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States",
                       nil, nil, "\"May the Force be with you.\" - Star Wars",
                       "jdunbar@gmail.com", "0"],
                      [2, "Bob", "Down", "25/02/1919",
                       "1601 Willow Rd.\nMenlo Park, CA 94025\nUnited States",
                       true, 0, "\"Frankly, my dear, I don't give a damn.\" - Gone With The Wind",
                       "bobdown@hotmail.com", "123456"]], chunk) if row_no == 3
      end

    end

    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file in chunks, last chunk smaller" do

      # Read chunks of the file.  In this case, we are breaking the file in chunks of 3.
      # Since we only have 4 rows, the first chunk will have 3 rows and the second chunk
      # will have 1 row
      reader = Jcsv.reader("customer.csv", chunk_size: 3)

      enum = reader.each do |line_no, row_no, chunk, headers|
        assert_equal([["1", "John", "Dunbar", "13/06/1945",
                       "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States",
                       nil, nil,
                       "\"May the Force be with you.\" - Star Wars", "jdunbar@gmail.com", "0"],
                      ["2", "Bob", "Down", "25/02/1919",
                       "1601 Willow Rd.\nMenlo Park, CA 94025\nUnited States",
                       "Y", "0", "\"Frankly, my dear, I don't give a damn.\" - Gone With The Wind",
                       "bobdown@hotmail.com", "123456"],
                      ["3", "Alice", "Wunderland", "08/08/1985",
                       "One Microsoft Way\nRedmond, WA 98052-6399\nUnited States", "Y", "0",
                       "\"Play it, Sam. Play \"As Time Goes By.\"\" - Casablanca",
                       "throughthelookingglass@yahoo.com", "2255887799"]], chunk) if row_no == 4

        assert_equal([["4", "Bill", "Jobs", "10/07/1973",
                       "2701 San Tomas Expressway\nSanta Clara, CA 95050\nUnited States", "Y", "3",
                       "\"You've got to ask yourself one question: \"Do I feel lucky?\" Well, do ya, punk?\" - Dirty Harry",
                       "billy34@hotmail.com", "36"]], chunk) if row_no == 5

      end

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file in chunks as enumerator" do
      
      reader = Jcsv.reader("customer.csv", chunk_size: 2)

      # Add filters, so that we get 'objects' instead of strings for filtered fields
      reader.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                        :married => Jcsv.optional(Jcsv.bool),
                        :customerno => Jcsv.int}

      # Method each without a block returns an enumerator
      enum = reader.each

      # read the first chunk.  Chunk is of size 2
      chunk = enum.next

      assert_equal(7, chunk[0])
      assert_equal(3, chunk[1])
      assert_equal([[1, "John", "Dunbar", "13/06/1945",
                     "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States", nil, nil,
                     "\"May the Force be with you.\" - Star Wars", "jdunbar@gmail.com", "0"],
                    [2, "Bob", "Down", "25/02/1919",
                     "1601 Willow Rd.\nMenlo Park, CA 94025\nUnited States",
                     true, 0, "\"Frankly, my dear, I don't give a damn.\" - Gone With The Wind",
                     "bobdown@hotmail.com", "123456"]], chunk[2])
      
      # read second chunk
      c = enum.next

      # trying to read another chunk will raise StopIteration
      assert_raise ( StopIteration ) { enum.next }

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file in chunks as enumerator... last chunk smaller" do
      
      # Same test with a chunk_size of 3
      reader = Jcsv.reader("customer.csv", chunk_size: 3)
      
      # Method each without a block returns an enumerator
      enum = reader.each
      
      # read first chunk.  Does nothing with the data.
      enum.next
      
      
      # read second chunk... only one row will be returned
      chunk = enum.next
      
      # assert_equal()
      assert_equal([["4", "Bill", "Jobs", "10/07/1973",
                     "2701 San Tomas Expressway\nSanta Clara, CA 95050\nUnited States", "Y", "3",
                     "\"You've got to ask yourself one question: \"Do I feel lucky?\" Well, do ya, punk?\" - Dirty Harry",
                     "billy34@hotmail.com", "36"]], chunk[2])
      
      # trying to read another chunk will raise StopIteration
      assert_raise ( StopIteration ) { enum.next }

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file skipping columns" do
      
      reader = Jcsv.reader("customer.csv")

      # Add mapping.  When column is mapped to false, it will not be retrieved from the
      # file, improving time and speed efficiency
      reader.mapping = {:customerno => false, :numberofkids => false, :loyaltypoints => false}
        
      reader.read do |line_no, row_no, chunk, headers|
        assert_equal([:firstname, :lastname, :birthdate, :mailingaddress, :married,
                      :favouritequote, :email], headers)
        if (row_no == 2)
          assert_equal("John", chunk[0])
          assert_equal("Dunbar", chunk[1])
        end
      end

    end
#=end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file skipping columns, with headers as string" do
      
      reader = Jcsv.reader("customer.csv", strings_as_keys: true)

      # Add mapping.  When column is mapped to false, it will not be retrieved from the
      # file, improving time and speed efficiency
      reader.mapping = {"customerNo" => false, "numberOfKids" => false,
                        "loyaltyPoints" => false}
        
      reader.read do |line_no, row_no, chunk, headers|
        assert_equal(["firstName", "lastName", "birthDate", "mailingAddress", "married",
                      "favouriteQuote", "email"], headers)
        if (row_no == 2)
          assert_equal("John", chunk[0])
          assert_equal("Dunbar", chunk[1])
        end
      end

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file reordering columns" do

      # Here we are setting headers to false, so the first line will not be considere
      # a header.
      reader = Jcsv.reader("customer.csv", chunk_size: 2)
      # reading the headers returns false
      # assert_equal(false, reader.headers)

      reader.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                        :married => Jcsv.optional(Jcsv.bool),
                        :customerno => Jcsv.int}

      # Mapping allows reordering of columns.  In this example, column 0 (:customerno)
      # in the csv file will be loaded in position 2 (3rd column); column 1 (:firstname)
      # in the csv file will be loaded in position 0 (1st column); column 2 on the csv file
      # will not be loaded (false); column 4 (:birthdate) will be loaded on position 3,
      # and so on.
      # When reordering columns, care should be taken to get the mapping right or unexpected
      # behaviour could result.
      reader.mapping = {:customerno => 2, :firstname => 0, :lastname => false,
                        :birthdate => 3, :mailingaddress => false, :married => false,
                        :numberofkids => false, :favouritequote => false, :email => 1,
                        :loyaltypoints => 4}
        
      reader.read do |line_no, row_no, chunk, headers|
        assert_equal([:firstname, :email, :customerno, :birthdate, :loyaltypoints],
                     headers)
        assert_equal("John", chunk[0][0]) if row_no == 3
        assert_equal("Alice", chunk[0][0]) if row_no == 5
      end

    end
    
  end

end


=begin

      # When there are no headers setting filters and mapping needs to be done 
      # using the columns position in the file.  Note that we can have specify fewer
      # filters or mapping.
      # Filters for the first 4 columns, the other columns will not be filtered
      reader.filters = [Jcsv.optional, Jcsv.optional, Jcsv.int, Jcsv.date("dd/MM/yyyy")]


    #-------------------------------------------------------------------------------------
    # JRuby fiber seems to have a bug.  Don't know if only JRuby fiber or fibers in 
    # general.  When returning the first element the second is also retrieved (look
    # forward: might be a reason, but prevents changing the behaviour in between calls to
    # next.
    #-------------------------------------------------------------------------------------

    should "allow changing parameters in between reads" do
      
      # Start with chunk_size 1
      reader = Jcsv.reader("customer.csv", headers: true, chunk_size: 1)
      
      # Method each without a block returns an enumerator
      enum = reader.each
      
      # read first chunk.  Does nothing with the data. Got only one line of data
      p enum.next

      # change chunk_size to 2
      reader.chunk_size = 2
      
      # read second chunk... only one row will be returned
      chunk = enum.next
      p chunk
      # assert_equal()

      p enum.next
      
    end
=end
