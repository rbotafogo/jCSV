# coding: utf-8

##########################################################################################
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
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

require '../config'
require 'codewriter'
# require_relative '../../CodeWriter/lib/codewriter'
# include Writer

author("Rodrigo Botafogo")

body(<<-EOT)
Parse a CSV file the quick way with headers:

Reads all rows in memory and return and array of arrays. Each line is stored in one array.  
Headers are converted from string to symbol
EOT

code(<<-EOT)
require 'jcsv'

# Create a new reader by passing the filename to be parsed
reader = Jcsv.reader("customer.csv")

# now read the whole csv file and stores it in the 'content' variable
content = reader.read
EOT

body(<<-EOT)
The 'headers' instance variable from reader has the headers read from the file:
EOT

console(<<-EOT)
p reader.headers
EOT

body(<<-EOT)

EOT

console(<<-EOT)
content.each do |row|
  p row
end
EOT

console(<<-EOT)
reader = Jcsv.reader("customer.csv", strings_as_keys: true)

# now read the whole csv file
content = reader.read
p reader.headers
EOT
