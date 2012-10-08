<?php

if ( isset( $location_suggested_links[$_SERVER['REQUEST_URI']] ) ) {
    $suggested_links = $location_suggested_links[$_SERVER['REQUEST_URI']];
}

preg_match( "/(item|topic)Id=\d+/", $_SERVER['REQUEST_URI'], $matches );
if ( isset($matches[0]) && isset($query_suggested_links[$matches[0]]) ) {
    $suggested_links = $query_suggested_links[$matches[0]];
}

if ( isset($suggested_links) ) {
    echo "<h2>Suggested Links</h2><ul>$suggested_links</ul>";
}

?>
