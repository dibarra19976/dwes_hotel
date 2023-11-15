<?php

$room_id = $_POST["room_id"]; 
include ("../db/db_connection.php");
$sql_query = 
"
SELECT * FROM 041_rooms WHERE room_id = '$room_id';  
";  

 
$result = mysqli_query($mysqli, $sql_query);
$room  = mysqli_fetch_all($result, MYSQLI_ASSOC);

?>  