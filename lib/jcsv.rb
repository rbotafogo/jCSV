# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
# Copyright © 2015 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
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

require_relative '../config'

module JavaIO
  include_package "java.io"
end

##########################################################################################
#
##########################################################################################

class Jcsv
  include_package "com.univocity.parsers.csv"

  
  def self.open(filename, *options, &block)
    Jcsv.new(filename)
  end

  
  def initialize(filename)
    @filename = filename
    
    @settings = CsvParserSettings.new

    newfile = JavaIO::File.new(filename)
    
    # the file used in the example uses '\n' as the line separator sequence.
    # the line separator sequence is defined here to ensure systems such as MacOS and Windows
    # are able to process this file correctly (MacOS uses '\r'; and Windows uses '\r\n').
    @settings.getFormat().setLineSeparator("\n");

    # creates a CSV parser
    parser = CsvParser.new(@settings);

    # parses all rows in one go.
    allRows = parser.parseAll(newfile);
    p allRows

  end
  
end
