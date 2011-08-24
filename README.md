# Lucene Query Parser

## Synopsis

This library provides a basic parser that implements the majority of the
[Lucene Query Syntax](http://lucene.apache.org/java/2_9_1/queryparsersyntax.html)
"specification". Additionally, it includes a `check_lucene_query` script
to check for errors in a given query.

## Requirements

* Ruby 1.8.7 (hasn't been tested elsewhere)
* [parslet](http://kschiess.github.com/parslet/)
* [rainbow](https://github.com/sickill/rainbow)
* Rspec 2 for development

## Install

    gem install lucene_query_parser

## Usage

    check_lucene_query --help

    check_lucene_query query.txt

    pbpaste | check_lucene_query -

## Development

    bundle
    rake

## Contributing

Fork, patch, test, and send a pull request.

