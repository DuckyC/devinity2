<?php
	header( "Content-Type: application/json;charset=utf-8" );
	$password = $_GET[ "password" ];

	if ($password == "swagmasterx") {
		$s = file_get_contents( "blacklist.json" );
		echo $s;

		http_response_code( 200 );
	}
	else {
		http_response_code( 401 );
	}
?>