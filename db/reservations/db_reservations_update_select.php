<?php

$reservation_id = $_POST["reservation_id"]; 
include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
$sql_query = 
"
SELECT * FROM 041_reservations WHERE reservation_id = '$reservation_id';  
";  

 
$result = mysqli_query($mysqli, $sql_query);
$reservation  = mysqli_fetch_all($result, MYSQLI_ASSOC);

$customer_id = $reservation[0]["reservation_client"];
$room_id = $reservation[0]["reservation_room"];
?>  