<?php

/*
 *  canonicalise a url
 */
function c14n_url($url, $query_values = '') {

    # decode and parse
    $url = rawurldecode($url);
    $uri = parse_url($url);

    # path
    $path = $uri['path'];

    # remove trailing slashes
    $path = preg_replace('/\/*$/', '', $path);

    # escape all non-reserved characters
    $path = rawurlencode($path);

    # all our nginx location and map matches are case-insensitive
    # ordinarily a bad idea for resources, this removes a lot of duplicate mappings
    $path = strtolower($path);

    # unreserved: A-Za-z0-9-_.!~*()
    $path = str_replace('%2f', '/', $path);
    $path = str_replace('%3a', ':', $path);
    $path = str_replace('%21', '!', $path);
    $path = str_replace('%2a', '*', $path);
    $path = str_replace('%28', '(', $path);
    $path = str_replace('%29', ')', $path);

    # hostname should be lowercase
    if (!array_key_exists('host', $uri)) {
        $url = $path;
    } else {
        # protocol is always http
        $url = "http://" . strtolower($uri['host']) . $path;
    }

    # add canonicalised query string
    if ($query_values) {
        $query = c14n_query_string($uri['query'], $query_values);
        if ($query) {
            $url = "$url?$query";
        }
    }

    return $url;
}

function c14n_query_string($query, $query_values) {

    # don't c14n query-string
    if ($query_values == '-') {
        return $query;
    }

    $wildcard = $query_values == '*';

    # significant query values
    foreach (preg_split('/[:,\s]+/', $query_values) as $name) {
        $significant[$name] = 1;
    }

    $param = array();

    foreach (preg_split('/[&;]/', $query) as $pair) {
        $name = preg_replace('/=.*$/', '', $pair);

        # only keep significant query_string values
        if ($significant[$name] || $wildcard) {
            array_push($param, $pair);
        }
    }

    asort($param);
    return implode('&', $param);
}

/*
 *  convert url into a display form
 */
function display_url($url) {
    return preg_replace('/^https?:\/\//', '', $url);
}

?>
