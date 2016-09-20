AV--ESaaS-Textbook-Index-Parsing
================================

A parser to read the textbook index .xml file and return a .csv file

To run the program, clone the repo using:

    git clone https://github.com/yggie/AV--ESaaS-Textbook-Index-Parsing.git

`cd` into the cloned directory and run the script:

~~~
cd AV--ESaaS-Textbook-Index-Parsing
bundle install          # installs required gems
ruby generate_csv.rb    # runs the program
~~~

This will create two output files, `output_index.csv` and `output_xref.csv` containing an ordered table of indices and a table of section references
