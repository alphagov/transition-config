<?php

#
#  simple unit testing
#
$tests = 0;
$errors = 0;

function fail($message) {
    global $tests, $errors;
    $tests++;
    $errors++;
    fwrite(STDERR, "\n");
    fwrite(STDERR, "#  Failed test $message\n");
}

function ok($expr, $message) {
    global $tests, $errors;
    $tests++;
    if (!$expr) {
        $errors++;
        fwrite(STDERR, "\n");
        fwrite(STDERR, "#  Failed test $message\n");
    }
}

function is($got, $expected, $message) {
    global $tests, $errors;
    $tests++;
    if ($expected == $got) {
        return;
    }
    $errors++;
    fwrite(STDERR, "\n");
    fwrite(STDERR, "#  Failed test $message\n");
    fwrite(STDERR, "#         got: $got\n");
    fwrite(STDERR, "#    expected: $expected\n");
}

function plural($count, $word) {
    return "$count $word" . ($count == 1 ? " " : "s ");
}

function done_testing() {
    global $tests, $errors;
    fwrite(STDERR, plural($tests, "test") . plural($errors, "error") . "\n");
    if ($errors) {
        fwrite(STDERR, "FAIL\n");
        exit(2);
    }
    fwrite(STDERR, "PASS\n");
    exit(0);
}

?>
