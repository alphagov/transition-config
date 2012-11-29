<?php

if ( isset( $location_suggested_links[$uri_without_slash] ) ) {
    $suggested_links = $location_suggested_links[$uri_without_slash];
}

preg_match( "/(item|topic)Id=\d+/", $uri_without_slash, $matches );
if ( isset($matches[0]) && isset($query_suggested_links[$matches[0]]) ) {
    $suggested_links = $query_suggested_links[$matches[0]];
}

preg_match( "/dg_\d+/i", $uri_without_slash, $matches );
if ( isset($matches[0]) ) {
    $match = strtolower($matches[0]);
    if ( isset( $location_suggested_links[$match] ) ) {
        $suggested_links = $location_suggested_links[$match];
    }
}

if ( isset($suggested_links) ) {
    echo "<p>For more information on this topic you may want to visit $suggested_links.</p>";
}

?>
