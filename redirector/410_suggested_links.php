<?php

if ( isset( $location_suggested_links[$_SERVER['REQUEST_URI']] ) ) {
    $suggested_links = $location_suggested_links[$_SERVER['REQUEST_URI']];
}

preg_match( "/(item|topic)Id=\d+/", $_SERVER['REQUEST_URI'], $matches );
if ( isset($matches[0]) && isset($query_suggested_links[$matches[0]]) ) {
    $suggested_links = $query_suggested_links[$matches[0]];
}

preg_match( "/dg_\d+/i", $_SERVER['REQUEST_URI'], $matches );
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
