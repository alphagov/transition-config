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

is(c14n_url("http://www.example.com/commas,and-\"quotes\"-make-CSV-harder-to-'awk'"), 'http://www.example.com/commas%2cand-%22quotes%22-make-csv-harder-to-%27awk%27', "commas and quotes");
is(c14n_url("http://www.example.com/problematic-in-curl[]||[and-regexes]"), "http://www.example.com/problematic-in-curl%5b%5d%7c%7c%5band-regexes%5d", "square brackets and pipes");

is(c14n_url("https://www.example.com"), "http://www.example.com", "protocol should be http");

is(c14n_url("http://www.example.com/%7eyes%20I%20have%20now%20read%20%5brfc%203986%5d%2C%20%26%20I%27m%20a%20%3Dlot%3D%20more%20reassured%21%21"),
            'http://www.example.com/~yes%20i%20have%20now%20read%20%5brfc%203986%5d%2c%20%26%20i%27m%20a%20%3dlot%3d%20more%20reassured!!',
            "non-reserved character percent decoding");

is(c14n_url("https://www.example.com/pound-sign-£"), "http://www.example.com/pound-sign-%c2%a3", "pound sign");

done_testing();
