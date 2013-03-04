use strict;
use Test::More;
require 'lib/c14n.pl';

#
#  case
#
is(c14n_url("http://www.EXAMPLE.COM/Foo/Bar/BAZ"), "http://www.example.com/foo/bar/baz", "c14n URL is lower-case");

#
#  protocol
#
is(c14n_url("https://www.example.com"), "http://www.example.com", "translates protocol to http");

#
#  slashes
#
is(c14n_url("http://www.example.com/"), "http://www.example.com", "drops trailing slash");
is(c14n_url("http://www.example.com////"), "http://www.example.com", "drops multiple trailing slashes");

#
#  encoding
#
is(c14n_url("http://www.example.com/commas,and-\"quotes\"-make-CSV-harder-to-'awk'"), 'http://www.example.com/commas%2cand-%22quotes%22-make-csv-harder-to-%27awk%27', "commas and quotes");
is(c14n_url("http://www.example.com/problematic-in-curl[]||[and-regexes]"), "http://www.example.com/problematic-in-curl%5b%5d%7c%7c%5band-regexes%5d", "square brackets and pipes");
is(c14n_url("http://www.example.com/%7eyes%20I%20have%20now%20read%20%5brfc%203986%5d%2C%20%26%20I%27m%20a%20%3Dlot%3D%20more%20reassured%21%21"),
            'http://www.example.com/~yes%20i%20have%20now%20read%20%5brfc%203986%5d%2c%20%26%20i%27m%20a%20%3dlot%3d%20more%20reassured!!',
            "non-reserved character percent decoding");
is(c14n_url("https://www.example.com/pound-sign-£"), "http://www.example.com/pound-sign-%c2%a3", "pound sign");

#
#  query_strings
#
is(c14n_url("http://www.example.com?q=foo"), "http://www.example.com", "drops disallowed query-string");
is(c14n_url("http://www.example.com/?q=foo"), "http://www.example.com", "drops disallowed query-string after slash");
is(c14n_url("http://www.example.com/?q=foo#bar"), "http://www.example.com", "drops disallowed query-string after a slash with fragid");

is(c14n_url("http://www.example.com?a=1&c=3&b=2", '*'), "http://www.example.com?a=1&b=2&c=3", "query string wildcard value");

is(c14n_url("http://www.example.com/?q=foo", "q"), "http://www.example.com?q=foo", "allow named query_string parameter");

is(c14n_url("http://www.example.com?c=23&d=1&b=909&e=33&a=1", "b,e,c,d,a"), "http://www.example.com?a=1&b=909&c=23&d=1&e=33", "sorts query_string values");
is(c14n_url("http://www.example.com?c=23&d=1&b=909&e=33&a=1", "  b e,c:d, a  "), "http://www.example.com?a=1&b=909&c=23&d=1&e=33", "accept colon and space separated allowed values");
is(c14n_url("http://www.example.com?c=23;d=1;b=909;e=33;a=1", "b,e,c,d,a"), "http://www.example.com?a=1&b=909&c=23&d=1&e=33", "converts matrix URI to query_string");

is(c14n_url("http://www.example.com?a=2322sdfsf&topic=334499&q=909&item=23444", "topic,item"), "http://www.example.com?item=23444&topic=334499", "allows cherry-picked  query_string");
is(c14n_url("http://www.example.com?a=2322sdfsf&topic=334499&q=909&item=23444", "foo,bar,baz"), "http://www.example.com", "no ? for empty query_string values");


done_testing();
