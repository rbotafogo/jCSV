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
# require 'codewriter'
require_relative '../../CodeWriter/lib/codewriter'
include Markdown

author("Rodrigo Botafogo")

section("Introduction")

body(<<-EOT)
The CSV file format is a common format for data exchange between diverse applications. It
is widely used; however, supresingly, there aren't that many good libraries for CSV 
reading and writing.  In Ruby there are a couple of well known libraries to accomplish
this task.  First, there is the standard Ruby CSV that comes with any Ruby implementation.
This library according to Smarter CSV (https://github.com/tilo/smarter_csv) has the 
following limitations: 

"Ruby's CSV library's API is pretty old, and it's processing of CSV-files returning 
Arrays of Arrays feels 'very close to the metal'. The output is not 
easy to use - especially not if you want to create database records from it. Another 
shortcoming is that Ruby's CSV library does not have good support for huge CSV-files, 
e.g. there is no support for 'chunking' and/or parallel processing of the 
CSV-content (e.g. with Resque or Sidekiq).

In order to eliminate those restrictions, smarter_csv was developed.  Although it does
remove those restrictions it removes support for Arrays of Arrays.  Altough such format 
is really 'very close to metal' in some cases this is actually what is needed.  This format
is less memory intensive than the 'hash' approach from smarter_csv and it might make it
easier to put the date in a simple table.  When reading scientific data, such as an matrix
or multidimensional array, it might also be better to remove headers and informational
columns and read the actual data as just a plain array.

jCSV was developed to be the "ultimate" CSV reader/writer.  It tries to merge all the good
features of standard Ruby CSV library, smarter_csv, and other CSV libraries from other 
languages.  jCSV is based on Super CSV (http://super-csv.github.io/super-csv/index.html), a 
java CSV library.  According to Super CSV web page its motivation is "for Super CSV is to be 
the foremost, fastest, and most programmer-friendly, free CSV package for Java". jCSV 
motivation is to add to bring this view to the Ruby world, and since we are in Ruby, make
it even easier and more programmer-friendly.

Again, from Super CSV website:

"My years in industry dealing with CSV files (among other things ;-), has enabled me to 
identify a number of limitations with existing CSV packages. These limitations led me to 
write Super CSV. My main criticism of existing CSV packages is that reading and writing 
operates on lists of strings. What you really need is the ability to operate on a range of 
different types of objects. Moreover, you often need to restrict input/output data with 
constraints such as minimum and maximum sizes, or numeric ranges. Or maybe you are reading 
image names, and want to ensure you do not read names contain the characters ":", " ", "/", 
"^", "%".

Super CSV deals with all these and many other issues. And should you have a constraint not 
readily expressible in the package, new cell processors can easily be constructed. Furthermore, 
you don't want to "CSV encode" strings you write. If they happen to contain characters that 
needs escaping, then the CSV package should take care of this automatically!

The underlying implementation of Super CSV has been written in an extensible fashion, hence 
new readers/writers and cell processors can easily be supported. The inversion of control 
implementation pattern has been enforced, eradicating long-lived mistakes such as using 
filenames as arguments rather than Reader and Writer objects. Design patterns such as chain 
of responsibility and the null object pattern can also be found in the code. Feel free to 
have a look!"

jCSV reading features are:
EOT

list(<<-EOT)
Reads data as lists (Array of Arrays)

Reads data as hashes

Reads multidimensional data to lists or hashes

Filter cells when reading to the proper format.  Predefined filters are: parse_big_decimal, 
parse_bool, parse_char, parse_date, parse_double, parse_enum, parse_int, parse_long, collector,
convert_null_to, hash_mapper, optional, str_replace, token, trim, truncate, d_min_max, 
equals, forbid_sub_str, is_element_of, is_included_in, l_min_max, not_null, 
require_hash_code, require_sub_str, str_len, str_min_max, str_not_null_or_empty, 
str_req_ex, unique, unique_hash_code, parse_date_time, parse_date_time_zone, 
parse_duration, parse_interval, parse_local_date, parse_local_date_time, 
parse_local_time, parse_period
EOT

section("Reading as Lists")

body(<<-EOT)
In this section we will read the following 'customer.csv' file.  Some things should be observed in the records
of this data:
EOT

list(<<-EOT)
It has a header;

4 rows of data, all with 10 columns;

Records can have line break in them;

The mailingAddress column contains data that spans multiple lines 

The favouriteQuote column contains data with escaped quotes.
EOT

comment_code(<<-EOT)
customerNo,firstName,lastName,birthDate,mailingAddress,married,numberOfKids,favouriteQuote,email,loyaltyPoints
1,John,Dunbar,13/06/1945,"1600 Amphitheatre Parkway
Mountain View, CA 94043
United States",,,"""May the Force be with you."" - Star Wars",jdunbar@gmail.com,0
2,Bob,Down,25/02/1919,"1601 Willow Rd.
Menlo Park, CA 94025
United States",Y,0,"""Frankly, my dear, I don't give a damn."" - Gone With The Wind",bobdown@hotmail.com,123456
3,Alice,Wunderland,08/08/1985,"One Microsoft Way
Redmond, WA 98052-6399
United States",Y,0,"""Play it, Sam. Play ""As Time Goes By."""" - Casablanca",throughthelookingglass@yahoo.com,2255887799
4,Bill,Jobs,10/07/1973,"2701 San Tomas Expressway
Santa Clara, CA 95050
United States",Y,3,"""You've got to ask yourself one question: ""Do I feel lucky?"" Well, do ya, punk?"" - Dirty Harry",billy34@hotmail.com,36
EOT

subsection("Simple Interface")

body(<<-EOT)
The simplest way of reading a csv file is as a list or an array of arrays. Reading in this way is a simple
call to Jcsv.reader with the filename, in this case the file is called 'customer.csv'. In the next
examples we will parse a CSV file and show all the features and options that can be 
applied for changing the parsing.  The file we are reading has headers.  Headers are converted from string 
to symbol.
EOT

code(<<-EOT)
require 'jcsv'

# Create a new reader by passing the filename to be parsed
reader = Jcsv.reader("customer.csv")

# now read the whole csv file and stores it in the 'content' variable
content = reader.read
EOT

body(<<-EOT)
When reading a file with headers, the 'headers' instance variable from reader has the 
headers read from the file.  Headers are converted to symbols:
EOT

console(<<-EOT)
p reader.headers
EOT

body(<<-EOT)
We now take a look at the content of the file and should note that line breaks were read 
as \\n and quotes are properly escaped with \".  The 'content' variable has an array of 
arrays and each line is an array.
EOT

console(<<-EOT)
content.each do |row|
  p row
end
EOT

subsection("Strings as Keys")

body(<<-EOT)
We will now see many of the options for reading files.  Options are passed to method reader.
First 'strings_as_key' when true will not convert headers to symbol. Note also, that we can read the
headers without reading the rest of the file:
EOT

console(<<-EOT)
reader = Jcsv.reader("customer.csv", strings_as_keys: true)
p reader.headers
EOT

subsection("Processing with a Block")

body(<<-EOT)
One very interesting feature of Ruby CSV libraries is the ability to give a block to the parser and
process the data as it is being read. In jCSV this can also be accomplished:
EOT

code(<<-EOT)
# read lines and pass them to a block for processing. The block receives line_no (last line 
# of the record),
# row_no, row and the headers.
# Read file 'customer.csv'.  File has headers (this is the default) and we keep the keys as string
reader = Jcsv.reader("customer.csv", headers: true, strings_as_keys: true)
EOT

comment_code(<<-EOT)
reader.read do |line_no, row_no, row, headers|
  puts "line number: \#{line_no}, row number: \#{row_no}"
  headers.each_with_index do |head, i|
    puts "\#{head}: \#{row[i]}"
  end
  puts
end
EOT

#console(<<-EOT)
reader = Jcsv.reader("customer.csv", strings_as_keys: true)
reader.read do |line_no, row_no, row, headers|
  puts "line number: #{line_no}, row number: #{row_no}"
  headers.each_with_index do |head, i|
    puts "#{head}: #{row[i]}"
  end
  puts
end
#EOT

subsection("Default Filter and Filters")

body(<<-EOT)
A powerful feature of jCSV is the ability to filter and transform data cells.  In the next example 
we define a default_filter for every cell in the dataset: 'default_filter: Jcsv.not_nil'.  With 
this filter, no cell can be nil.  Looking back at our data, we can see that row number 2 has 
an empty field for 'married' and 'number of kids".  So, we should expect this reading to fail.
EOT

console(<<-EOT)
parser = Jcsv.reader("customer.csv", default_filter: Jcsv.not_nil)
parser.read
EOT

body(<<-EOT)
As we can see, this parsing dies on record number 2 with a Constraint violation, since we have 
a default filter of not_nil and in this record two fields are nil.  In order to properly 
handle this issue, we will add filters to our parser.  First we make :numberofkids 
and :married as optional; however, if this field is filled, then :numberofkids should be and 
integer and :married should be a boolean.  In order to add this filters, we chain them 
with: Jcsv.optional(Jcsv.int) and Jcsv.optional(Jcsv.bool):
EOT

code(<<-EOT)
parser = Jcsv.reader("customer.csv", default_filter: Jcsv.not_nil)
# Add filters, so that we get 'objects' instead of strings for filtered fields

parser.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customerno => Jcsv.int,
                  :birthdate => Jcsv.date("dd/MM/yyyy")}

content = parser.read
EOT

body(<<-EOT)
Let's take a look at the second record.  We can see that :customerno is an integer, in this 
case 2, since we have selected the second record, :married is now true and the number of kids 
is the integer 0.
EOT

console(<<-EOT)
p content[1]
EOT

subsection("Chunking")

body(<<-EOT)
As with super_csv, jCSV also supports data chunking, by passing as argumento the chunk_size.
EOT

code(<<-EOT)
# Read chunks of the file.  In this case, we are breaking the file in chunks of 2
reader = Jcsv.reader("customer.csv", chunk_size: 2)

# Add filters, so that we get 'objects' instead of strings for filtered fields
reader.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customerno => Jcsv.int}

content = reader.read
EOT

console(<<-EOT)
p content[0]
EOT

body(<<-EOT)
Note now that content[0] is an array of array.  The external array is of size 2, the chunk 
size and each sub array is a row.  Note also, that the filters have properly converted 
strings into objects.  Remember that method read can receive a block.  Let's show an example
with chunk_size of 3.  In this example, the first chunk will be of size 3 and the second of
size 1, since there are no more records after that.  When reading chunks, in the given blocks,
 'line_no' and 'row_no' are the last line and row read respectively.
EOT

code(<<-EOT)
# Read chunks of the file.  In this case, we are breaking the file in chunks of 2
reader = Jcsv.reader("customer.csv", chunk_size: 3)

# Add filters, so that we get 'objects' instead of strings for filtered fields
reader.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customerno => Jcsv.int}

reader.read do |line_no, row_no, chunk, headers|
  puts "line number: \#{line_no}, row number: \#{row_no}"
  p chunk
  puts
end
EOT

subsection("Chunks as Enumerators")

body(<<-EOT)
Ruby has a very interesting feature called Enumerator.  jCSV supports the use of enumerators,
allowing for partial file read.  Let's first give an example of using enumerators, and then
we will show an example of partially reading a CSV file.  In order to get an enumerator on 
the reader we call method each without any blocks:
EOT

code(<<-EOT)
reader = Jcsv.reader("customer.csv", chunk_size: 2)

# Add filters, so that we get 'objects' instead of strings for filtered fields
reader.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customerno => Jcsv.int}

# Method each without a block returns an enumerator
enum = reader.each

# read the first chunk.  Chunk is of size 2
chunk = enum.next
EOT

body(<<-EOT)
The 'chunk' variable above is an array with the following elements: line_no, row_no, chunk data, 
and headers.  In this example, at this point we have read only two records.
EOT

console(<<-EOT)
p chunk
EOT

body(<<-EOT)
In order to read the other two records we need to call method 'next' again:
EOT

console(<<-EOT)
p enum.next
EOT

body(<<-EOT)
We now write a small script that will look for a record that has "Bob" on the :firstname.  
When this happens, the script terminates and no more reading needs to be done.  For large 
CSV files, breaking reading when the required data is read is a very useful feature. Remember
that row is an array with line_no, row_no, row data, and headers. So, to get :firstname
we need to read row[2][1].
EOT

code(<<-EOT)
reader = Jcsv.reader("customer.csv")

# Add filters, so that we get 'objects' instead of strings for filtered fields
reader.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customerno => Jcsv.int}

# Method each without a block returns an enumerator
enum = reader.each

begin
  row = enum.next
end while row[2][1] != "Bob"
p row

EOT

subsection("Skipping Columns")

body(<<-EOT)
Sometimes, a CSV file contains columns that are of no interest, and thus, reading them just
consumes memory without any benefit.  jCSV allows skipping such columns, by defining a 
mapping.  Bellow an example where the columns :customerno, :mailingaddress and
:favouritequote are not read:
EOT

code(<<-EOT)
reader = Jcsv.reader("customer.csv")

# Add mapping.  When column is mapped to false, it will not be retrieved from the
# file, improving time and speed efficiency
reader.mapping = {:customerno => false, :mailingaddress => false, :favouritequote => false}
EOT

body(<<-EOT)
Note that the headers in the block do not show any of the removed columns, although the
reader.headers still has all headers.
EOT

console(<<-EOT)
p reader.headers
EOT

console(<<-EOT)
reader.read do |line_no, row_no, row, headers|
  p headers
  p row
end
EOT

subsection("Column Reordering")

body(<<-EOT)
jCSV also allows for reordering the columns of the CSV file.  This is also done through a
mapping:
EOT

code(<<-EOT)
reader = Jcsv.reader("customer.csv")

# Add filters...
reader.filters = {:numberofkids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customerno => Jcsv.int}

# Mapping allows reordering of columns.  In this example, column 0 (:customerno)
# in the csv file will be loaded in position 2 (3rd column); column 1 (:firstname)
# in the csv file will be loaded in position 0 (1st column); column 2 on the csv file
# will not be loaded (false); column 4 (:birthdate) will be loaded on position 3,
# and so on.
# When reordering columns, care should be taken to get the mapping right or unexpected
# behaviour could result.
reader.mapping = {:customerno => 2, :firstname => 0, :lastname => false,
                  :birthdate => 3, :mailingaddress => false, :married => false,
                  :numberofkids => false, :favouritequote => false, :email => 1,
                  :loyaltypoints => 4}
EOT

console(<<-EOT)
reader.read do |line_no, row_no, row, headers|
  p headers
  p row
end
EOT
