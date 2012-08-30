<?php

include 'rs-api-creds.php';

$url = $rs_api['url']."/servers?api_version=".$rs_api['version'];

$ch = curl_init($url);

curl_setopt($ch, CURLOPT_COOKIEFILE, $rs_api['cookie_file']);

$output = curl_exec($ch);
curl_close($ch);

echo $output;

?>