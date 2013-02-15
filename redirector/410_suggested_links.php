<?php

if ( isset( $location_suggested_link[$uri_without_slash] ) ) {
    $suggested_link = $location_suggested_link[$uri_without_slash];
}

preg_match( "/(item|topic)id=\d+/i", $uri_without_slash, $matches );
if ( isset($matches[0]) && isset($query_suggested_link[$matches[0]]) ) {
    $suggested_link = $query_suggested_link[$matches[0]];
}

preg_match( "/dg_\d+/i", $uri_without_slash, $matches );
if ( isset($matches[0]) ) {
    $match = strtolower($matches[0]);
    if ( isset( $location_suggested_link[$match] ) ) {
        $suggested_link = $location_suggested_link[$match];
    }
}

if ( isset($suggested_link) ) {
    echo "<p>For more information on this topic you may want to visit $suggested_link.</p>";
}

?>
