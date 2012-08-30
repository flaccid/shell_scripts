<?php

include 'rs-api-creds.php';

$rs_api['login_url'] = $rs_api['url']."/login?api_version=".$rs_api['version'];

$ch = curl_init($rs_api['login_url']);

curl_setopt($ch, CURLOPT_COOKIEJAR, $rs_api['cookie_file']);
curl_setopt($ch, CURLOPT_USERPWD,$rs_api['username'].':'.$rs_api['password']);

curl_exec($ch);
curl_close($ch);

?>