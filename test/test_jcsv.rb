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
=begin
    should "parse a csv file the quick way" do

      # Reads all rows in memory and return and array of arrays. Each line is stored in
      # one array.  Data is stored in the 'rows' instance variable. 
      content = Jcsv.read("customer.csv", has_headers: true, comment_starts: "#")
      p content.rows
      p content.headers
      print("\n")

      # read lines and pass them to a block for processing. The block receives the row
      # and the headers.  If has_haders is false, then headers will be nil. Instead of
      # method foreach, one could also use method 'read' with a block.  'read' and
      # 'foreach' are identical. 
      content = Jcsv.foreach("customer.csv", has_headers: true,
                             comment_starts: "#") do |row, headers|
        p headers
        p row
      end

      # In this case, rows is nil, since the content is passed one row at a time for
      # processing.       
      assert_equal(nil, content.rows)
      
    end
=end
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file with processors" do

      # Creating a new parser, if has_headers is true, automatically reads the headers
      parser = Jcsv.new("example.csv", has_headers: true, comment_starts: "#")
      assert_equal(["Year", "Make", "Model", "Description", "Price"], parser.headers)

      parser = Jcsv.new("customer.csv", has_headers: true, comment_starts: "#")
      parser.filters = {"numberOfKids" => Jcsv.optional(Jcsv.int),
                        "married" => Jcsv.optional(Jcsv.bool)}

      parser.read do |row|
        p row
      end
      
    end
    

  end

end
