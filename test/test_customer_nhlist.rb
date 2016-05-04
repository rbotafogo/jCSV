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
    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file the quick way without headers" do
        
      # Setting headers to false, will read the header as a normal line
      reader = Jcsv.reader("../data/customer_nh.csv", headers: false)

      # read the whole file in one piece.
      content = reader.read
      # p content

      assert_equal(["1", "John", "Dunbar", "13/06/1945",
                    "1600 Amphitheatre Parkway\nMountain View, CA 94043\nUnited States",
                    nil, nil, "\"May the Force be with you.\" - Star Wars",
                    "jdunbar@gmail.com", "0"], content[0])
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "process headerless files with filters" do

      # Setting headers to false, will read the header as a normal line
      reader = Jcsv.reader("../data/customer_nh.csv", headers: false)

      # Filters need to match the column by position, since there is no header to allow
      # matching by names.  Columns indexed after the last filter will not be filtered
      # in any way.  In the example bellow, no filter will be applied on column 5 and
      # after
      reader.filters = [Jcsv.optional >> Jcsv.int, Jcsv.not_nil, Jcsv.not_nil,
                        Jcsv.optional >> Jcsv.date("dd/MM/yyyy")]
        
      # read the whole file in one piece.
      content = reader.read
      assert_equal(1, content[0][0])
      assert_equal(DateTime.parse("13/06/1945"), content[0][3])
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "allow adding custom headers to headerless files" do

      # Setting headers to false, will read the header as a normal line
      reader = Jcsv.reader("../data/customer_nh.csv", headers: false,
                           custom_headers:
                             ["customerNo", "firstName", "lastName", "birthDate",
                              "mailingAddress", "married", "numberOfKids",
                              "favouriteQuote", "email", "loyaltyPoints"])

      # Add filters, so that we get 'objects' instead of strings for filtered fields
      reader.filters = {:number_of_kids => Jcsv.optional >> Jcsv.int,
                        :married => Jcsv.optional >> Jcsv.bool,
                        :customer_no => Jcsv.int,
                        :birth_date => Jcsv.date("dd/MM/yyyy")}

      reader.read do |line_no, row_no, row, headers|

        # First field is customer number, which is converted to int
        assert_equal(1, row[0]) if row_no == 1
        assert_equal("John", row[1]) if row_no == 1
        # Field 5 is :married.  It is optional, so leaving it blank (nil) is ok.
        assert_equal(nil, row[5]) if row_no == 1

        # notice that field married that was "Y" is now true. Number of kids is not "0",
        # but 0, customerNo is also and int
        assert_equal(true, row[5]) if row_no == 2
        
      end
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Read headerless files with map if given custom_headers" do

      # Setting headers to false, will read the header as a normal line
      reader = Jcsv.reader("../data/customer_nh.csv", headers: false, format: :map,
                           custom_headers:
                             ["customerNo", "firstName", "lastName", "birthDate",
                              "mailingAddress", "married", "numberOfKids",
                              "favouriteQuote", "email", "loyaltyPoints"],
                           default_filter: Jcsv.not_nil)
      
      # Set numberOfKids and married as optional, otherwise an exception will be raised
      reader.filters = {:number_of_kids => Jcsv.optional >> Jcsv.int,
                        :married => Jcsv.optional >> Jcsv.bool,
                        :loyalty_points => Jcsv.long,
                        :customer_no => Jcsv.int,
                        :birth_date => Jcsv.date("dd/MM/yyyy")}

      # When parsing to map, it is possible to make a mapping. If column name is :false
      # the column will be removed from the returned row
      reader.mapping = {:number_of_kids => :numero_criancas,
                        :married => "casado",
                        :loyalty_points => "pontos fidelidade",
                        :customer_no => false}

      reader.read do |line_no, row_no, row, headers|
        if (row_no == 5)
          assert_equal(nil, row[:customer_no])
          assert_equal("Bill", row[:first_name])
          assert_equal(true, row["casado"])
          assert_equal("1973-07-10T00:00:00+00:00", row[:birth_date].to_s)
          assert_equal("2701 San Tomas Expressway\nSanta Clara, CA 95050\nUnited States",
                       row[:mailing_address])
          assert_equal(3, row[:numero_criancas])
        end
        
      end

    end
    
  end

end
