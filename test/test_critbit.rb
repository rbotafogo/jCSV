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

    should "parse multi-dimension csv into a critbit" do
      
      reader = Jcsv.reader("critbit.csv", format: :critbit, col_sep: ";",
                           dimensions: [:city, :neighborhood, :street],
                           default_filter: Jcsv.int)

      cities = reader.read
      p cities

      reader = Jcsv.reader("customer.csv", format: :critbit,
                           dimensions: [:last_name, :first_name])

      customers = reader.read
      p customers
      
      reader = Jcsv.reader("customer.csv", format: :critbit,
                           dimensions: [:first_name, :last_name])

      customers = reader.read
      p customers

    end

  end

end
