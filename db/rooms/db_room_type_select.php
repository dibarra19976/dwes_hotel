<?php

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
$sql = 
"
SELECT * FROM 041_room_types; 
";  

 
$result = mysqli_query($mysqli, $sql);
$room_types  = mysqli_fetch_all($result, MYSQLI_ASSOC);
?>