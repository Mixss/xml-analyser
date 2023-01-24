# Simple XML parser

This is the simple XML parser that was implemented using `flex` and `bison`. 

This parser checks if the XML document is valid by:
- checking if all comments are closed
- checking if tags do match
- checking spelling mistakes

It also prints all the tags detected in the order they were read.

## Compilation

The program can be compiled using `make`