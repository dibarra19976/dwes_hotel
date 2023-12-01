<?php

$room_id = $_POST["room_id"]; 
include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
$sql_query = 
"
SELECT * FROM 041_rooms WHERE room_id = '$room_id';  
";  

 
$result = mysqli_query($mysqli, $sql_query);
$room  = mysqli_fetch_all($result, MYSQLI_ASSOC);

?>  