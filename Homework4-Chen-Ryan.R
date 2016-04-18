
================ STATISTICS 470/503/770, 2016A, HOMEWORK 4 ================

                 YOUR NAME:  Ryan Chen   <<<<<< (fill in!!!)

================================================================


INSTRUCTIONS:

- Due date and time:     MONDAY, APRIL 19, 11PM

- Rename this file "Homework4-Lastname-Firstname.R" and upload
  it with your solutions to Canvas.

- Edit this file in RStudio and insert your solutions below between
the dashed lines.  Answer only what is asked for:
'... # Yourcode'    - replace it with code but no explanations;
'... # Results'     - replace it with the results from R.
Your code lines should be ready for execution, not cause errors,
and produce correct results.
You may of course use multiple lines for code and results.


================================================================
           EDIT YOUR SOLUTIONS BETWEEN DASHED LINES
================================================================


(0) PRELIMINARIES:

    The following webpages contain currency exchange rates:

      http://www.x-rates.com/historical/?from=USD&amount=1&date=2016-04-09
      http://www.x-rates.com/historical/?from=USD&amount=1000

    One can play with three parameters:
    - the 'from' currency, "USD" in this case;
    - the 'amount', 1 and 1000, respectively;
    - the date, "2016-04-09" and the present, respectively.

    View these pages by executing
      browseURL("http://www.x-rates.com/historical/?from=USD&amount=1&date=2016-04-09")
      browseURL("http://www.x-rates.com/historical/?from=USD&amount=1000")

    Acquaint yourself with the underlying HTML code by executing
      edit(readLines("http://www.x-rates.com/historical/?from=USD&amount=1&date=2016-04-09"))
      edit(readLines("http://www.x-rates.com/historical/?from=USD&amount=1000"))
    Search in the editor for "<td" to learn where table material is located
    and how it is formatted.
    [Firefox users can just type 'ctrl-U' into the browser to see the HTML code.]


================================================================


(1)  Write a function that creates the URLs for these webpages
     with arguments for the 'from' currency, the amount, and the date.
     The format of the function is given below.
     You only need to fill in the body.

     Handle the date correctly:
     If  date="", append "".
     If  date="2016-04-09" (e.g.), append "&date=2016-04-09".
     Use 'if() {} else {}' or 'ifelse()'; either works.

----------------------------------------------------------------
currURL <- function(from="USD", amount=1, date="") {
  library(stringr)
  from.field <- str_c("from", from, sep = "=")
  amount.field <- str_c("amount", amount, sep = "=")
  date.field <- str_c("date", date, sep = "=")
  all.fields <- str_c(from.field, amount.field, date.field, sep = "&")
  url <- str_c("http://www.x-rates.com/historical/", all.fields, sep = "?")
  url
}
----
# Show the results from executing the following:
currURL()
[1] "http://www.x-rates.com/historical/?from=USD&amount=1&date="
from <- "EUR";  amount <- 10;  date <- "2016-04-09"
currURL(from=from, amount=amount, date=date)
[1] "http://www.x-rates.com/historical/?from=EUR&amount=10&date=2016-04-09"
----------------------------------------------------------------


================================================================


(2) Use the function 'readHTMLTable()' from package 'XML'
    to scrape the table material from the exchange rate
    webpages.

    In the case of our exchange rate webpage, the result
    is two data frames with 3 columns each:
    one data frame for the 10 most important currencies,
    one for the remaining 55 currencies.

    Write a function 'currTable()' according to the format
    given below:
    - Use 'currURL()' from (1) to create the proper URL.
    - Pipe the URL into 'readHTMLTable()'.
    - Assign the result with '-> curr.lst' at the end of the pipe.
    - Use 'rbind()' on the two elements of 'curr.lst'
      to stack the two data frames.
    - Remove the 3rd column (the reverse exchange rate).
    - Return the resulting data frame.

----------------------------------------------------------------
currTable <- function(from="USD", amount=1, date="") {
  library(XML)
  URL <- currURL(from, amount, date)
  URL %>% readHTMLTable() -> curr.lst
  df.exchange <- rbind(curr.lst[[1]], curr.lst[[2]])[,-3]
  df.exchange
}
----
# Show the result of:
currTable(amount=100, from="EUR", date="2016-04-09") %>% head(5)
               Euro  100.00 EUR
1         US Dollar  113.979598
2     British Pound   80.672103
3      Indian Rupee 7585.285234
4 Australian Dollar  150.916382
5   Canadian Dollar  148.005357
----------------------------------------------------------------


================================================================


(3) The solution of (2) is missing the currency codes!
    If we had to use the table in subsequent algorithms,
    currencies would probably be referred to by codes,
    not full names.

    This is a general problem: High-level tools may
    drop important information on the floor.
    In the following approach we get down to the knitty-gritty
    of HTML markup, looking for the "<td" lines, and
    extracting the desired information the hard way,
    and shaping the result into a useful data frame.


----------------------------------------------------------------


(3a) Before we start the real work, lets store the HTML webpage in R.
     Write a pipe that re-uses the code of (1) and passes the resulting
     string to 'readLines()'.
     Store the result in 'curr.html';
     use '-> curr.html' for assignment at the end of the pipe.

     [If you print 'curr.html', you should see 905 lines with lots of
      HTML markup.  Do not print the whole thing; it might choke RStudio.
      Use these to check:
        length(curr.html)
        head(curr.html)
        tail(curr.html)
     ]

----------------------------------------------------------------
from <- "EUR";  amount <- 10;  date <- "2016-04-09"
# Your pipe code, with the above args to 'currURL()', ending with '-> curr.html'.
currURL(from, amount, date) %>% readLines() -> curr.html
----------------------------------------------------------------


(3b) Write a new pipe starting from 'curr.html' that does the
     following:

     - Use 'str_subset()' to select the lines that contain a table
       datum, "<td".

     - Use 'str_extract_all()' to get at the full target currency
       name, the three-letter codes for the from- and target
       currencies, and the converted amount.  To this end you
       will have to develop three different patterns:

       . a pattern for the full target currency names:
         allow inclusion of ">" at the beginning and "<" at the end of
         the currency names to simplify the task (we can remove these
         characters later);

       . a pattern for the 3-letter currency codes:
         three consecutive capital letters;

       . a pattern for the converted amounts:
         digits, a period, more digits.

       Connect these three patterns with the OR operator "|".

     - The result of 'str_extract_all()' is a list; pipe it into
       'unlist()' and assign it with '-> curr.vec' at the end.

     [You can build up the pipe in stages and debug by printing the
      results at each stage.  Printing will not clog up RStudio,
      unlike for larger webpages.]

----------------------------------------------------------------
curr.html %>% str_subset("<td") %>% 
         str_extract_all('(to=[A-Z]{3})|([0-9]+[.][0-9])')
----
# Show the result of the following line:
cbind(head(curr.vec, 14))
... # The result
----------------------------------------------------------------


(3c) Reformatting: 'curr.vec' is of length 455 = 7*65.
     For each target currency, there are 7 fields:
     - Full name
     - From-code
     - To-code
     - Converted amount as a string
     and three more fields which we will get rid of.

     Tasks: Do NOT use pipes this time!
     - Transform 'curr.vec' into a matrix with 7 columns,
       named 'curr.mat'.  Fill the matrix properly such that
       the columns have the meanings just described.
     - Remove the last 3 columns.
     - Clean the first column of "<" and ">" characters.

     - Using 'data.frame()' form a data frame named 'curr.df'
       with 4 columns:
       . the full target currency name, named "To.Currency";
       . two columns called "From" and "To" for the currency codes;
       . the converted amount in atomic type 'numeric'.

----------------------------------------------------------------
... # Your code
----
# Show the result of:
tail(curr.df)
...
----------------------------------------------------------------


(3d) --- NOT MANDATORY !!! ---
       FOR BONUS POINTS ONLY

     If you still have the stamina, package the
     code of (3a)-(3c) in a single function.
     It is really just a matter of gathering
     the code from these three sections
     and returning 'curr.df'.
     It is going to be a powerful function!

----------------------------------------------------------------
currTable2 <- function(from="USD", amount=1, date="") {
  ... # Your code
}
----
# Show the result of:
head(currTable2(date="2016-04-09"))
... # The result
----------------------------------------------------------------


================================================================
