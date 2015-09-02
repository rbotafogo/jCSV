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

    should "parse a csv file to map" do

      # type is :map. Rows are hashes. Set the default filter to not_nil. That is, all
      # fields are required unless explicitly set to optional.
      parser = Jcsv.reader("customer.csv", type: :map, default_filter: Jcsv.not_nil,
                        headers: true)

      # Set numberOfKids and married as optional, otherwise an exception will be raised
      parser.filters = {:numberOfKids => Jcsv.optional(Jcsv.int),
                        :married => Jcsv.optional(Jcsv.bool),
                        :loyaltyPoints => Jcsv.long,
                        :customerNo => Jcsv.int,
                        "birthDate" => Jcsv.date("dd/mm/yyyy")}

      # When parsing to map, it is possible to make a mapping. If column name is :false
      # the column will be removed from the returned row
      parser.mapping = {"numberOfKids" => :numero_criancas,
                        "married" => "casado",
                        "loyaltyPoints" => "pontos fidelidade",
                        "customerNo" => :false}
      
      parser.read do |line_no, row_no, row, headers|
        assert_equal({"customerNo"=>4, "firstName"=>"Bill", "lastName"=>"Jobs",
                      "birthDate"=>"1973-01-10 00:07:00 -0300",
                      "mailingAddress"=>"2701 San Tomas Expressway\nSanta Clara, CA 95050\nUnited States",
                      "married"=>true, "numberOfKids"=>3,
                      "favouriteQuote"=>"\"You've got to ask yourself one question: \"Do I feel lucky?\" Well, do ya, punk?\" - Dirty Harry",
                      "email"=>"billy34@hotmail.com", "loyaltyPoints"=>36}, row) if row == 5

      end

      # Will raise an exception as reading a file as map requires the header
      assert_raise ( RuntimeError ) { Jcsv.reader("customer.csv", type: :map) }

      parser = Jcsv.reader("customer.csv", type: :map, default_filter: Jcsv.not_nil,
                           headers: true)
      
      # Set numberOfKids and married as optional, otherwise an exception will be raised
      parser.filters = {"numberOfKids" => Jcsv.optional(Jcsv.int),
                        "loyaltyPoints" => Jcsv.long,
                        "customerNo" => Jcsv.int,
                        "birthDate" => Jcsv.date("dd/mm/yyyy")}

      parser.read { |line_no, row_no, row, headers| }
      # Will raise an exception, as the default_filter is not_nil and there is a record
      # in which field 'married' is nil
      # assert_raise ( RuntimeError ) { parser.read { |line_no, row_no, row, headers| } }
      
    end

  end
  
end
