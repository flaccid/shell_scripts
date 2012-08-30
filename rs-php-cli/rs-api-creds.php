<?php

$rs_api = array(
	'version' => '1.0',
	'account_id' => 1234,
	'username' => "foo@bar.suf",
	'password' => "ubersecurepassword",
	'cookie_file' => '/tmp/rs_api_cookie.txt',
	//'cookie_file' => tempnam("/tmp", "rs_api"),
);

$rs_api['url'] = "https://my.rightscale.com/api/acct/".$rs_api['account_id'];

?>