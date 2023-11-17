<?php

$number = $_POST['number'];
$status = $_POST['status'];
$type = $_POST['type'];
$json = '
{
  "streamingServicesOnTV": [0],
  "airConditioner": [0],
  "tvPremiumSoundbar": [0]
}
';
$img_main = $_POST['img_main'];
$img_1 = $_POST['img_1'];
$img_2 = $_POST['img_2'];
$img_3 = $_POST['img_3'];


include ("./db_connection.php");

$sql = 
"
INSERT INTO 041_rooms 
(room_number, room_status, room_available_extras , room_img_main , room_img_1 , room_img_2 , room_img_3, room_type )	
VALUES (
'$number ', '$status', '$json', '$img_main', '$img_1', '$img_2', '$img_3', '$type'
    )
";

 
$query = mysqli_query($mysqli, $sql);

header("Location: /student041/dwes/forms/form_rooms_insert.php");     
