use strict;
use Test::More;
require 'lib/c14n.pl';

is(c14n_url("http://www.EXAMPLE.COM/Foo/Bar/BAZ"), "http://www.example.com/foo/bar/baz", "lower-case");

is(c14n_url("http://www.example.com/"), "http://www.example.com", "trailing slash");
is(c14n_url("http://www.example.com////"), "http://www.example.com", "trailing slashes");
is(c14n_url("http://www.example.com#foobar"), "http://www.example.com", "fragid");
is(c14n_url("http://www.example.com/#foobar"), "http://www.example.com", "fragid");
is(c14n_url("http://www.example.com?q=foo"), "http://www.example.com", "query-string");
is(c14n_url("http://www.example.com/?q=foo"), "http://www.example.com", "query-string");
is(c14n_url("http://www.example.com/?q=foo#bar"), "http://www.example.com", "query-string with fragid");

is(c14n_url("http://www.example.com/commas,and-\"quotes\"-make-CSV-harder-to-'awk'"), 'http://www.example.com/commas%2Cand-%22quotes%22-make-csv-harder-to-%27awk%27', "commas and quotes");
is(c14n_url("http://www.example.com/problematic-in-curl[]||[and-regexes]"), "http://www.example.com/problematic-in-curl%5B%5D%7C%7C%5Band-regexes%5D", "square brackets and pipes");

is(c14n_url("https://www.example.com"), "http://www.example.com", "protocol should be http");

done_testing();
