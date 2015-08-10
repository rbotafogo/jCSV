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

    should "parse a csv file the quick way" do

      #Jcsv.processors(:customerNo => :not_null, :firstName => :not_null,
      #                :lastName => :not_null) 
        
      # Reads all rows in memory and return and array of arrays. Each line is stored in
      # one array
      p Jcsv.read("customer.csv", headers: true, comment_starts: "#")

      Jcsv.read("customer.csv", headers: true, comment_starts: "#") { |row| p row }

      Jcsv.read("example.csv", comment_starts: "#") do |row|
        p row
      end
      
      # p Jcsv.read("customer.csv", type: :map)
=begin
      # Processes each line.
      Jcsv.foreach("example.csv", row_sep: "\n") do |row|
        p row
      end

      # field_size_limit limits the number of characters in a column to prevent out of
      # memory errors
      # Jcsv.foreach("example.csv", row_sep: "\n", field_size_limit: 3)

      # Lines that start with comment_char are treated as comment and discarted
      p Jcsv.read("sleep.csv", row_sep: "\n", col_sep: ";", comment_char: "#")
=end      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------
=begin
    should "parse a csv file the powerful way" do

      parser = Jcsv.new("example.csv")
      settings = parser.settings
      
    end
=end    
  end

end
