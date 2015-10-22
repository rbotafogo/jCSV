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
require 'mdarray'

require_relative '../config'

require 'jcsv'

class CSVTest < Test::Unit::TestCase

  context "CSV test" do

    setup do

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse multi-dimension csv file to map" do

      reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all,
                           dimensions: [:treatment, :subject, :period])

      # remove the :patient field from the data, as this field is already given by the
      # :subject field.
      reader.mapping = {:patient => false}

      # since we are reading with chunk_size = :all, then we will only get one chunk back.
      # Then we can get the first chunk by indexing read with 0: reader.read[0]
      treatment = reader.read[0]

      # get the dimensions
      treatment_type = reader.dimensions[:treatment]
      subject = reader.dimensions[:subject]
      period = reader.dimensions[:period]

      p treatment_type.labels
      p subject.labels
      p period.labels
      
      # p treatment
      p treatment["placebo"]["10"]
      p treatment["placebo"]["10"]["1"][:"seizure.rate"]
      p treatment["Progabide"]["31"]
      
    end

=begin
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "parse a csv file to a vector" do

      reader = Jcsv.reader("epilepsy.csv", headers: true, format: :vector, type: :double,
                           dimensions: ["subject", :period])
      reader.mapping = {:treatment => false}
      vector = reader.read

      # p vector
      array = MDArray.int([59, 4, 4], vector)
      array.print
      
    end

=end
    
  end

end
