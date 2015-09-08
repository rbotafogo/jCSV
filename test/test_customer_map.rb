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

require_relative '../config'

require 'jcsv'

class CSVTest < Test::Unit::TestCase

  context "CSV test" do

    setup do

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------
#=begin
    should "parse a csv file to map the quick way" do

      reader = Jcsv.reader("customer.csv", type: :map, headers: true)
      # map is an array of hashes
      map = reader.read
      # get customerNo of second row
      assert_equal("2", map[1]["customerNo"])
      # loyaltyPoints from 4th row
      assert_equal("36", map[3]["loyaltyPoints"])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file to map without filters nor mappings in chunks" do

      # type is :map. Rows are hashes. Set the default filter to not_nil. That is, all
      # fields are required unless explicitly set to optional.
      reader = Jcsv.reader("customer.csv", type: :map, headers: true, chunk_size: 2)
      map = reader.read
      # since chunk_size = 2, but we didn't pass a block to reader, we will get back
      # 1 array, with 2 arrays each with a chunk.  Every element of the internal arrays
      # are maps (hashes)
      # Bellow we are looking at the second chunk, element 0.  Since our chunks are of
      # size 2, the second chunk, element 0 is the third row.
      assert_equal("2255887799", map[1][0]["loyaltyPoints"])

    end
#=end
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------
#=begin
    should "parse a csv file to map" do

      # type is :map. Rows are hashes. Set the default filter to not_nil. That is, all
      # fields are required unless explicitly set to optional.
      reader = Jcsv.reader("customer.csv", type: :map, default_filter: Jcsv.not_nil,
                           headers: true)

      # Set numberOfKids and married as optional, otherwise an exception will be raised
      reader.filters = {:numberOfKids => Jcsv.optional(Jcsv.int),
                        :married => Jcsv.optional(Jcsv.bool),
                        :loyaltyPoints => Jcsv.long,
                        :customerNo => Jcsv.int,
                        "birthDate" => Jcsv.date("dd/MM/yyyy")}

      # When parsing to map, it is possible to make a mapping. If column name is :false
      # the column will be removed from the returned row
      reader.mapping = {"numberOfKids" => :numero_criancas,
                        "married" => "casado",
                        "loyaltyPoints" => "pontos fidelidade",
                        "customerNo" => :false}

      reader.read do |line_no, row_no, row, headers|
        if (row_no == 5)
          assert_equal("Bill", row["firstName"])
          assert_equal(true, row["casado"])
          assert_equal("1973-07-10 00:00:00 -0300", row["birthDate"].to_s)
          assert_equal("2701 San Tomas Expressway\nSanta Clara, CA 95050\nUnited States",
                       row["mailingAddress"])
          assert_equal(3, row[:numero_criancas])
        end
        
      end

    end

#=begin
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "raise exception if no header when reading map" do

      # Will raise an exception as reading a file as map requires the header
      assert_raise ( RuntimeError ) { Jcsv.reader("customer.csv", type: :map) }

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "raise exception when filters are invalid" do

      reader = Jcsv.reader("customer.csv", type: :map, default_filter: Jcsv.not_nil,
                           headers: true)
      
      # Set numberOfKids and married as optional, otherwise an exception will be raised
      reader.filters = {"numberOfKids" => Jcsv.optional(Jcsv.int),
                        "loyaltyPoints" => Jcsv.long,
                        "customerNo" => Jcsv.int,
                        "birthDate" => Jcsv.date("dd/mm/yyyy")}

      # reader.read { |line_no, row_no, row, headers| }
      # Will raise an exception, as the default_filter is not_nil and there is a record
      # in which field 'married' is nil
      assert_raise ( RuntimeError ) { reader.read { |line_no, row_no, row, headers| } }
      
    end
#=end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read file in chunks passing a block as iterator" do
      
      # Read chunks of the file.  In this case, we are breaking the file in chunks of two
      reader = Jcsv.reader("customer.csv", headers: true, chunk_size: 2, type: :map)

      # Add filters, so that we get 'objects' instead of strings for filtered fields
      reader.filters = {"numberOfKids" => Jcsv.optional(Jcsv.int),
                        "married" => Jcsv.optional(Jcsv.bool),
                        "customerNo" => Jcsv.int}
      
      iter = reader.each
      chunk1 = iter.next
      # 3rd item in the chunk1 array is the data.  1st item is the line_no and 2nd item
      # row_no.  Chunks are of size 2, so chunk1[2][1] is the second element of the first
      # chunk
      assert_equal(2, chunk1[2][1]["customerNo"])
      assert_equal("Down", chunk1[2][1]["lastName"])       
      
      chunk2 =  iter.next

    end

  end
  
end
