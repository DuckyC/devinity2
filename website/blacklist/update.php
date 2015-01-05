<?php
	function savePlayers( $arr ) {
		file_put_contents( "blacklist.json", json_encode( $arr ) );
	}

	header( "Content-Type: application/json;charset=utf-8" );

	$password = $_POST[ "password" ];

	if ($password == "swagmasterx") {
		
		if (!isset( $_POST[ "action" ] ) || !isset( $_POST[ "steamid" ] )) {
			http_response_code( 500 );
			exit();
		}

		$action = $_POST[ "action" ];
		$steamid = $_POST[ "steamid" ];
		$nick = "";
		$faction = "";

		if (isset( $_POST[ "nick" ] )) {
			$nick = $_POST[ "nick" ];
		}
		if (isset( $_POST[ "faction" ] )) {
			$faction = $_POST[ "faction" ];
		}

		if ($steamid == "") {
			return;
		}

		$s = file_get_contents( "blacklist.json" );

		$arr = json_decode( $s, true );
		if (!array_key_exists( "players", $arr )) {
			$arr[ "players" ] = array();
		}

		$players = &$arr[ "players" ];

		if ($action == "remove") {
			if (array_key_exists( $steamid, $players )) {
				unset( $players[ $steamid ] );
			}
		}
		else if ($action == "set") {
			if (!array_key_exists( $steamid, $players )) {
				$players[ $steamid ] = array();
			}

			$plyTbl = &$players[ $steamid ];

			if ($nick != "") {
				$plyTbl[ "nick" ] = $nick;
			}
			if ($faction != "") {
				$plyTbl[ "faction" ] = $faction;
			}
		}

		savePlayers( $arr );
		echo json_encode( $arr );

		http_response_code( 200 );
	}
	else {
		http_response_code( 401 );
	}
?>