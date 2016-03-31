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
require 'pp'

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

parser.filters = {:number_of_kids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customer_no => Jcsv.int,
                  :birth_date => Jcsv.date("dd/MM/yyyy")}

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
reader.filters = {:number_of_kids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customer_no => Jcsv.int}

content = reader.read
EOT

console(<<-EOT)
pp content[0]
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
reader.filters = {:number_of_kids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customer_no => Jcsv.int}
EOT

console(<<-EOT)
reader.read do |line_no, row_no, chunk, headers|
  puts "line number: \#{line_no}, row number: \#{row_no}"
  pp chunk
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
reader.filters = {:number_of_kids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customer_no => Jcsv.int}

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
pp chunk
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
reader.filters = {:number_of_kids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customer_no => Jcsv.int}

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
reader.filters = {:number_of_kids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :customer_no => Jcsv.int}

# Mapping allows reordering of columns.  In this example, column 0 (:customerno)
# in the csv file will be loaded in position 2 (3rd column); column 1 (:firstname)
# in the csv file will be loaded in position 0 (1st column); column 2 on the csv file
# will not be loaded (false); column 4 (:birthdate) will be loaded on position 3,
# and so on.
# When reordering columns, care should be taken to get the mapping right or unexpected
# behaviour could result.
reader.mapping = {:customer_no => 2, :first_name => 0, :last_name => false,
                  :birth_date => 3, :mailing_address => false, :married => false,
                  :number_of_kids => false, :favourite_quote => false, :email => 1,
                  :loyalty_points => 4}
EOT

console(<<-EOT)
reader.read do |line_no, row_no, row, headers|
  p headers
  p row
end
EOT

section("Read to Map")

body(<<-EOT)
In this section we show how to read data into an array of maps (hashes) instead as into 
an array of arrays.  Reading to map is very easy and only requires passing one argument: 
'format: :map'.
EOT

code(<<-EOT)
reader = Jcsv.reader("customer.csv", format: :map)

# map is an array of hashes
map = reader.read
EOT

body(<<-EOT)
In order to get the :loyalty_points for the second customer we do:
EOT

console(<<-EOT)
p map[1][:loyalty_points]
EOT

body(<<-EOT)
Reading to maps support most of the same arguments as reading to lists.  Bellow we read
with chunk_size 2, and strings as key:
EOT

code(<<-EOT)
reader = Jcsv.reader("customer.csv", format: :map, chunk_size: 2, strings_as_keys: true)
map = reader.read
EOT

body(<<-EOT)
With chunk_size 2, we have in variable map two chunks, each of size 2.  Let's take a look
at the first element of the second chunk, i.e., the third row of data:
EOT

console(<<-EOT)
pp map[1][0]
EOT

body(<<-EOT)
Filters and mappings are also supported for maps.  Note that we introduce some new filters:
Jcsv.long and Jcsv.date.  We also show how to rename columns by using a mapping, for instance,
we want column :numberofkids to be mapped to :numero_criancas which is the same label but in
portuguese.  Note also that we map :loyaltypoints to the string with white spaces 
"pontos fielidade".  Finally, columns :customerno, :mailingaddress and :favouritequote are
also droped.
EOT

code(<<-EOT)
# type is :map. Rows are hashes. Set the default filter to not_nil. That is, all
# fields are required unless explicitly set to optional.
reader = Jcsv.reader("customer.csv", format: :map, default_filter: Jcsv.not_nil)

# Set numberOfKids and married as optional, otherwise an exception will be raised
reader.filters = {:number_of_kids => Jcsv.optional(Jcsv.int),
                  :married => Jcsv.optional(Jcsv.bool),
                  :loyalty_points => Jcsv.long,
                  :customerno => Jcsv.int,
                  :birth_date => Jcsv.date("dd/MM/yyyy")}

# When parsing to map, it is possible to make a mapping. If column name is :false
# the column will be removed from the returned row
reader.mapping = {:number_of_kids => :numero_criancas,
                  :married => "casado",
                  :loyalty_points => "pontos fidelidade",
                  :customer_no => false,
                  :mailing_address => false,
                  :favourite_quote => false}

reader.read do |line_no, row_no, row|
  pp row
end
EOT

body(<<-EOT)
Reading as map also supports reading as enumerator:
EOT

code(<<-EOT)
reader = Jcsv.reader("customer.csv", chunk_size: 2, format: :map)

# Add filters, so that we get 'objects' instead of strings for filtered fields
reader.filters = {"numberOfKids" => Jcsv.optional(Jcsv.int),
                  "married" => Jcsv.optional(Jcsv.bool),
                  "customerNo" => Jcsv.int}

enum = reader.each
chunk = enum.next
EOT

console(<<-EOT)
pp chunk[2][1]
EOT

section("Dimensions")

body(<<-EOT)
From Wikipedia:  

"A dimension is a structure that categorizes facts and measures in order to enable users 
to answer business questions. Commonly used dimensions are people, products, 
place and time.

In a data warehouse, dimensions provide structured labeling information to otherwise 
unordered numeric measures. The dimension is a data set composed of individual, 
non-overlapping data elements. The primary functions of dimensions are threefold: 
to provide filtering, grouping and labelling."

Data often has dimensions, but they are just treated as labels for the data in a column of
the CSV file.

The following excerpt shows data from an experiment in which patients with epilepsy were 
given either a placebo or Progabide to check the effect of this medicament in their 
seizure rate during a four week treatment period (data from R). 

Clearly, treatment is a 
dimension in this data, as a patient is either given a placebo or Progabide. The patient id
(first column) can also be considered a dimension. In this experiment there were 59 patients,
during a 4 week period, thus this dataset has 236 rows.
EOT

comment_code(<<-EOT)
"patient","treatment","base","age","seizure.rate","period","subject"
"1","placebo",11,31,5,"1","1"
"110","placebo",11,31,3,"2","1"
"112","placebo",11,31,3,"3","1"
"114","placebo",11,31,3,"4","1"
"29","Progabide",76,18,11,"1","29"
"291","Progabide",76,18,14,"2","29"
"292","Progabide",76,18,9,"3","29"
"293","Progabide",76,18,8,"4","29"
"30","Progabide",38,32,8,"1","30"
EOT

body(<<-EOT)
Let's now read this dataset and see how dimensions can help understand this data and organize
it.  Four dimensions are set for this dataset: patient, subject, treatment and period and it
will be read as an array of maps:
EOT

code(<<-EOT)
reader = Jcsv.reader("epilepsy.csv", format: :map, 
                     dimensions: [:patient, :subject, :treatment, :period])
treatment = reader.read
EOT

console(<<-EOT)
treatment.first(5).each do |row|
  pp row
end
EOT

body(<<-EOT)
Observe that the :key hashkey has an array with all the element's dimensions and the other
columns are still processed as in a regular map reader.  At this point it might not be
clear what the benefit of dimensions are, but let's move a little bit forward.
EOT

subsection("Deep Map")

body(<<-EOT)
In the next
example we will add some new directives to the reader: chunk_size :all and deep_map true.
The patient field will be ignored, since this is redundant information that can be
obtained from the subject: 
EOT

code(<<-EOT)
reader = Jcsv.reader("epilepsy.csv", format: :map, chunk_size: :all,
                     dimensions: [:treatment, :subject, :period], deep_map: true)

# remove the :patient field from the data, as this field is already given by the
# :subject field.
reader.mapping = {:patient => false}

treatment = reader.read[0]
EOT

body(<<-EOT)
First let's understand the directive chunk_size :all: this indicates that the file 
should be read in one large chunk.  When reading chunks, each chunk is an array, of
arrays of the given chunk size.  When reading chunk_size all, the returned data
is in an array that has an array with all row, this is why we have treatment 
above to be reader.read[0].

The attentive reader might ask: "why do we need chunc_size :all, since when no
chunk size is given the whole file is read anyway?".  This has to do with the
directive deep_map true.  When deep_map is used, the first dimension's elements 
are keys to the second dimensions element's and so on.  In order to be able to
make deep maps chunks of data need to be read.  

The treatment variable above is a hash that has two entries: 'placebo' and 
'Progabide'.  The placebo entry has as entries the elements from the second 
dimension, which is subject.  So treatment["placebo"]["1"] shows the data
for all four periods os treatment for subject "1".
EOT

console(<<-EOT)
pp treatment["placebo"]["1"]
EOT

body(<<-EOT)
As we can see, on the first period, subject "1" had base = "11", age = "31", 
seizure.rate = "5".  On the second period it's seizure.rate was "3".  We can
get this from our treatment variable with:
EOT

console(<<-EOT)
p treatment["placebo"]["1"]["2"][:"seizure.rate"]
EOT

body(<<-EOT)
Let's take a look at another entry: a subject 38 that uses Progabide.  One aspect to be
noted in the subject's dimensions on is that it would be better for subjects to be 
numbered 1, 2, 3, etc. for treatment with 'placebo' and also, 1, 2, 3, etc. for treatment
with 'Progabide'.  If this were the case then the first patient treated with placebo 
would be accessed with 'treatment["placebo"]["1"]' and the first patient treated with
Progabide would be accessed with 'treatment["Progabide"]["1"]'.  In the current 
forms, we need to know that patient "38" was treated with Progabide. 
EOT

console(<<-EOT)
pp treatment["Progabide"]["38"]
EOT

body(<<-EOT)
Dimensions' elements can be accessed by accessing reader's 'dimensions' instance
variable and getting the labels:
EOT

console(<<-EOT)
pp reader.dimensions[:treatment].labels
pp reader.dimensions[:period].labels
EOT

subsection("Dimensions Ordering")

body(<<-EOT)
Dimensions should be read from slowest to fast changing in the file.  The example bellow
shows a CSV file and the proper way of organizing dimensions:
EOT

comment_code(<<-EOT)
# File GoodOrder.csv
Dim 1	Dim 2	Dim 3	Data
A	X	K	1
A	X	J	2
A	Y	H	3
A	Y	G	4
B	X	K	5
B	X	J	6
B	Y	H	7
B	Y	G	8
C	X	K	9
C	X	J	10
C	Y	H	11
C	Y	G	12
EOT

code(<<-EOT)
reader = Jcsv.reader("GoodOrder.csv", format: :map, chunk_size: :all, col_sep: ";",
                     dimensions: [:dim_1, :dim_2, :dim_3], deep_map: true)

table = reader.read[0]
EOT

console(<<-EOT)
pp table
EOT

body(<<-EOT)
Changing the order of reading dimensions will generate errors:
EOT

code(<<-EOT)
reader = Jcsv.reader("GoodOrder.csv", format: :map, chunk_size: :all, col_sep: ";",
                     dimensions: [:dim_2, :dim_1, :dim_3], deep_map: true)
table = reader.read[0]

EOT

body(<<-EOT)
In this example we get a message saying that dimension 'dim_1' is frozen.  What does that 
mean? As we explained above, the CSV reader expects slower changing dimensions to be read
first.  The proper order of reading dimensions is thus, dim_1, dim_2, dim_3.  A dimension
becomes frozen whenever it cycles back to its first element.  In this example, dim_2 is
X, X, Y, Y when it cycles back to X it becomes frozen indicating that X and Y are the
only two elements in this dimension.  When a dimension if frozen all dimensions after
it are also frozen.  In this case, dim_1 and dim_3 also become frozen.

When dim_2 cycles back to X the values of dim_1 that were read are A and B.  When it 
becomes frozen, no other element can be added to this dimension.  When label C is
read form dim_1, it generates the error saying that label C cannot be added to
dim_1.

We will now read the file bellow, BadOrder.csv.  It contains the same data as above
but dimension dim_2 is the first column:
EOT

comment_code(<<-EOT)
# File BadOrder.csv
Dim_2	Dim_1	Dim_3	Data
X	A	K	1
X	A	J	2
Y	A	H	3
Y	A	G	4
X	B	K	5
X	B	J	6
Y	B	H	7
Y	B	G	8
X	C	K	9
X	C	J	10
Y	C	H	11
Y	C	G	12
EOT

code(<<-EOT)
reader = Jcsv.reader("BadOrder.csv", format: :map, chunk_size: :all, col_sep: ";",
                     dimensions: [:dim_2, :dim_1, :dim_3], deep_map: true)
table = reader.read[0]

EOT

body(<<-EOT)
Note now that the error happens earlier in the file.  Again, as we read dim_2 we get 
X, X, Y, Y.  When we cycle back to X, dim_2 is frozen, freezing dim_1 and dim_3 in 
the sequence.  Now when the first B is read, dim_1 is already frozen and an error is
issued.

Even though an error is issued, reading continues normally and the table can be 
printed:
EOT

console(<<-EOT)
pp table
EOT

body(<<-EOT)
If reading continues normally, why is an error issued?  For large datasets, when 
data is organized with the slowest changing dimension first, it becomes easier to
identify missing or duplicated data.  It is also a necessary condition for reading
data into a vector, as we will show in the the next section ("Reading into a Vector").

We now show a data file in which there is missing data. Note that we removed the 
fourth line from the file, and note also that this is not easily identified.  In a
larger dataset, seeing this would be very hard.  
EOT

comment_code(<<-EOT)
# File missing_data.csv
Dim_1	Dim_2	Dim_3	Data
A	X	K	1
A	X	J	2
A	Y	H	3
B	X	K	5
B	X	J	6
B	Y	H	7
B	Y	G	8
C	X	K	9
C	X	J	10
C	Y	H	11
C	Y	G	12
EOT

code(<<-EOT)
reader = Jcsv.reader("missing_data.csv", format: :map, chunk_size: :all, col_sep: ";",
                     dimensions: [:dim_1, :dim_2, :dim_3], deep_map: true)
table = reader.read[0]

EOT

body(<<-EOT)
Again, we get an error with dimension frozen.  This happens when reading the 8th row.
Dimension 3 was frozen after reading element K, since this dimension cycled from H 
back to K.  When reaching the 8th row a new element G is seen and indicates that
something is wrong in the file.

Let's again take a look at what was read:
EOT

console(<<-EOT)
pp table
EOT

body(<<-EOT)
Bellow we show another CSV file.  Note that there is a missing row in this data.
Can you quickly see it? Which row is it?
EOT

comment_code(<<-EOT)
# File missing_data2.csv
Dim_1	Dim_2	Dim_3	Data
A	X	K	1
A	X	J	2
A	Y	H	3
A	Y	G	4
A	Z	F	5
A	Z	D	6
B	X	K	7
B	X	J	8
B	Y	H	9
B	Z	F	10
B	Z	D	11
EOT

code(<<-EOT)
reader = Jcsv.reader("missing_data2.csv", format: :map, chunk_size: :all, col_sep: ";",
                     dimensions: [:dim_1, :dim_2, :dim_3], deep_map: true)
table = reader.read[0]

EOT

body(<<-EOT)
This last example shows how dimensions can help identify duplicate data.  A set of
dimensions should be unique, as a key in a database.  If the key is duplicate, an
error is issued.  The same missing_data2.csv file is read, but passing only two
dimensions, dim_1 and dim2:
EOT

code(<<-EOT)
reader = Jcsv.reader("missing_data2.csv", format: :map, chunk_size: :all, col_sep: ";",
                     dimensions: [:dim_1, :dim_2], deep_map: true)
table = reader.read[0]

EOT

subsection("Hidding Errors")

body(<<-EOT)
Since errors are shown but data is still read, if the user knows she doesn't want to be
notified of errors, she could add the suppress_errors directive:
EOT

code(<<-EOT)
reader = Jcsv.reader("missing_data2.csv", format: :map, chunk_size: :all, col_sep: ";",
                     dimensions: [:dim_1, :dim_2, :dim_3], deep_map: true,
                     suppress_errors: true)
table = reader.read[0]

EOT

body(<<-EOT)
As can be seen, the code above does not generate any errors.
EOT

subsection("Dimensions to Lists")

body(<<-EOT)
Reading data with dimensions to lists is also possible, and will generate arrays of arrays:
EOT

#code(<<-EOT)
reader = Jcsv.reader("GoodOrder.csv", chunk_size: :all, col_sep: ";",
                     dimensions: [:dim_1, :dim_2, :dim_3])
table = reader.read

#EOT

console(<<-EOT)
pp table
EOT




body(<<-EOT)
This text was Markup formated with CodeWriter: 
  * gem install CodeWriter
  * jruby -S gem install CodeWriter
  * https://github.com/rbotafogo/CodeWriter
EOT
