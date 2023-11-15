<?php

include ("../db/db_connection.php");
$sql = 
"
SELECT * FROM 041_room_types; 
";  

 
$result = mysqli_query($mysqli, $sql);
$room_types  = mysqli_fetch_all($result, MYSQLI_ASSOC);
?>