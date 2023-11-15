<?php
session_start();
header("Location: /student041/dwes/forms/form_reservations_client.php");     

$date_in = $_POST['date_in'];
$date_out = $_POST['date_out'];

if($date_in < $date_out){
    
include ("db_connection.php");

$sql = "CALL `041_checkAvailableRooms`('$date_in', '$date_out'); ";
$result = mysqli_query($mysqli, $sql);
$rooms  = mysqli_fetch_all($result, MYSQLI_ASSOC);




 
print_r($rooms);
print_r($_POST);

$_SESSION["rooms_select"] = $rooms;
$_SESSION["date_in"] = $date_in;
$_SESSION["date_out"] = $date_out;
}

?>