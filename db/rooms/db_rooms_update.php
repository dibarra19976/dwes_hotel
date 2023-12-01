<?php
include($_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/db/rooms/db_rooms_update_select.php");

$number = $_POST['number'];
$status = $_POST['status'];
$type = $_POST['type'];


$json =$room[0]['room_available_extras'];

$decoded = json_decode($json, true);
$i=1;
foreach ($decoded as $key => $value) {
  $a = 'json'.$i;
  $$a = $_POST[$a];
  $decoded[$key][0] = floatval($$a);
  $i++;
}

$json = json_encode($decoded);
$img_main = $_POST['img_main'];
$img_1 = $_POST['img_1'];
$img_2 = $_POST['img_2'];
$img_3 = $_POST['img_3'];
$room_id = $_POST['room_id'];

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");

$sql = 
"
UPDATE 041_rooms  
SET room_number='$number ', room_status='$status', room_available_extras='$json', room_img_main='$img_main', room_img_1='$img_1', room_img_2='$img_2', room_img_3='$img_3', room_type='$type'
WHERE room_id = '$room_id'
    
";

echo $sql;
$query = mysqli_query($mysqli, $sql);

header("Location: /student041/dwes/forms/rooms/form_rooms_update_call.php");     
