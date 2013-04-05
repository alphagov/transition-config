#
#  simple Test::More replacement
#
use strict;

my $tests = 0;
my $errors = 0;

sub fail {
    my ($message) = @_;
    $tests++;
    $errors++;
    print STDERR "\n";
    print STDERR "#  Failed test $message\n";
}

sub ok {
    #use Data::Dumper; print Dumper(\@_);
    my ($expr, $message) = @_;
    $tests++;
    unless ($message) {
        $message = $expr;
        $expr = 0;
    }
    return if ($expr);
    $errors++;
    print STDERR "\n";
    print STDERR "#  Failed test $message\n";
}

sub is {
    my ($expected, $got, $message) = @_;
    $tests++;
    return if ($expected eq $got);
    $errors++;
    print STDERR "\n";
    print STDERR "#  Failed test $message\n";
    print STDERR "#    expected: $expected\n";
    print STDERR "#         got: $got\n";
}

sub done_testing {
    print STDERR "$. lines, $tests tests, $errors errors.\n";
    if ($errors) {
        print STDERR "FAIL\n";
        exit(2);
    }
    exit(0);
}

1;
