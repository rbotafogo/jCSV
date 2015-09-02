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
=begin
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file the quick way with headers" do

      # Reads all rows in memory and return and array of arrays. Each line is stored in
      # one array.  Data is stored in the 'rows' instance variable.
      # Create the reader with the necessary parameters
      reader = Jcsv.reader("customer.csv", headers: true)

      # now read the whole csv file
      content = reader.read
      
      assert_equal(["1", "John", "Dunbar", "13/06/1945",
                    "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States",
                    nil, nil, "\"May the Force be with you.\" - Star Wars",
                    "jdunbar@gmail.com", "0"], content[0])

    end
    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file the quick way without headers" do
        
      # Setting headers to false, will read the header as a normal line
      reader = Jcsv.reader("customer.csv", headers: false)

      # read the whole file in one piece.
      content = reader.read

      # The first line now is the header, since we've set 
      assert_equal(["customerNo", "firstName", "lastName", "birthDate",
                    "mailingAddress", "married", "numberOfKids", "favouriteQuote",
                    "email", "loyaltyPoints"], content[0])

      assert_equal(["1", "John", "Dunbar", "13/06/1945",
                    "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States",
                    nil, nil, "\"May the Force be with you.\" - Star Wars",
                    "jdunbar@gmail.com", "0"], content[1])
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
      reader = Jcsv.reader("customer.csv", headers: true)
      
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
      parser = Jcsv.reader("customer.csv", headers: true)

      # Add filters, so that we get 'objects' instead of strings for filtered fields
      parser.filters = {"numberOfKids" => Jcsv.optional(Jcsv.int),
                        "married" => Jcsv.optional(Jcsv.bool),
                        "customerNo" => Jcsv.int,
                        "birthDate" => Jcsv.date("dd/MM/yyyy")}
      
      
      
      parser.read do |line_no, row_no, row, headers|
        # p row
        # notice that field married that was "Y" is now true. Number of kids is not "0",
        # but 0, customerNo is also and int
        #assert_equal([3, "Alice", "Wunderland",
        #              "08/08/1985", "One Microsoft Way\nRedmond, WA 98052-6399\nUnited States",
        #              true, 0, "\"Play it, Sam. Play \"As Time Goes By.\"\" - Casablanca",
        #              "throughthelookingglass@yahoo.com", "2255887799"], row) if row_no == 4
      end
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file in chunks passing a block" do
      
      # Read chunks of the file.  In this case, we are breaking the file in chunks of two
      reader = Jcsv.reader("customer.csv", headers: true, chunk_size: 2)

      # Add filters, so that we get 'objects' instead of strings for filtered fields
      reader.filters = {"numberOfKids" => Jcsv.optional(Jcsv.int),
                        "married" => Jcsv.optional(Jcsv.bool),
                        "customerNo" => Jcsv.int}
      
      reader.each do |line_no, row_no, chunk, headers|

        # line_no and row_no are the last read line_no and row_no of the chunk.  Since we
        # have headers and are reading in chunks of two, the first chunk has row_no = 3
        assert_equal([[1, "John", "Dunbar", "13/06/1945",
                       "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States",
                       nil, nil, "\"May the Force be with you.\" - Star Wars",
                       "jdunbar@gmail.com", "0"],
                      [2, "Bob", "Down", "25/02/1919", "1601 Willow Rd.\nMenlo Park, CA 94025\nUnited States",
                       true, 0, "\"Frankly, my dear, I don't give a damn.\" - Gone With The Wind",
                       "bobdown@hotmail.com", "123456"]], chunk) if row_no == 3
      end

      # Read chunks of the file.  In this case, we are breaking the file in chunks of 3.
      # Since we only have 4 rows, the first chunk will have 3 rows and the second chunk
      # will have 1 row
      reader = Jcsv.reader("customer.csv", headers: true, chunk_size: 3)

      enum = reader.each do |line_no, row_no, chunk, headers|
        assert_equal([["1", "John", "Dunbar", "13/06/1945",
                       "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States", nil, nil,
                       "\"May the Force be with you.\" - Star Wars", "jdunbar@gmail.com", "0"],
                      ["2", "Bob", "Down", "25/02/1919", "1601 Willow Rd.\nMenlo Park, CA 94025\nUnited States",
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
      
      reader = Jcsv.reader("customer.csv", headers: true, chunk_size: 2)

      # Add filters, so that we get 'objects' instead of strings for filtered fields
      reader.filters = {"numberOfKids" => Jcsv.optional(Jcsv.int),
                        "married" => Jcsv.optional(Jcsv.bool),
                        "customerNo" => Jcsv.int}

      # Method each without a block returns an enumerator
      enum = reader.each

      # read the first chunk
      chunk = enum.next

      assert_equal(7, chunk[0])
      assert_equal(3, chunk[1])
      assert_equal([[1, "John", "Dunbar", "13/06/1945",
                     "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States", nil, nil,
                     "\"May the Force be with you.\" - Star Wars", "jdunbar@gmail.com", "0"],
                    [2, "Bob", "Down", "25/02/1919", "1601 Willow Rd.\nMenlo Park, CA 94025\nUnited States",
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
      reader = Jcsv.reader("customer.csv", headers: true, chunk_size: 3)
      
      # Method each without a block returns an enumerator
      enum = reader.each
      # read first chunk
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
=end
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file skipping columns" do
      
      reader = Jcsv.reader("customer.csv", headers: true)

      # Add filters, so that we get 'objects' instead of strings for filtered fields
      #reader.filters = {"numberOfKids" => Jcsv.optional(Jcsv.int),
       #                 "married" => Jcsv.optional(Jcsv.bool),
        #                "customerNo" => Jcsv.int}

      reader.mapping = [false, 0, 1, false, 2, false, false, false, false, 4]
      # reader.mapping = {:numberOfKids => false, :married => false}
        
      reader.read do |line_no, row_no, chunk, headers|
        p chunk
      end


    end

  end

end