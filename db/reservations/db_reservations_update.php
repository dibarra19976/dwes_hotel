<?php
include ("./db_connection.php");
include("../db/db_reservations_update_select.php");

$room = $_POST['room'];
$client = $_POST['client'];
$date_in = $_POST['date_in'];
$date_out = $_POST['date_out'];
$room_price = $_POST['room_price'];


$json =$reservation[0]['reservation_room_extras'];

$decoded = json_decode($json, true);
$i=1;
foreach ($decoded as $key => $value) {
  $a = 'json'.$i;
  $$a = $_POST[$a];
  $decoded[$key][0] = floatval($$a);
  $i++;
}

$json_extras = json_encode($decoded);

if ($date_in < $date_out) {
    $sql = "SELECT * 
    FROM 041_rooms 
    WHERE room_id NOT IN (
        SELECT reservation_room 
        FROM 041_reservations
        WHERE 
        $date_in < reservation_date_out AND $date_out > reservation_date_in
            AND reservation_status <> 'cancelled'
            AND reservation_id <> $reservation_id
    )         
    AND room_status <>'unavailable'";
    $result = mysqli_query($mysqli, $sql);
    $rooms  = mysqli_fetch_all($result, MYSQLI_ASSOC);
    mysqli_free_result($result);
    mysqli_next_result($mysqli);
    $i = 0;
    $available = false;
    do {
        $available = $room == $rooms[$i]['room_id'];
        $i++;
    } while (!$available and  $i < count($rooms));


    if ($available == true) {
       $sql = "UPDATE 041_reservations SET reservation_room = '$room', reservation_client = '$client', reservation_date_in = '$date_in', reservation_date_out = '$date_out', reservation_room_price = '$room_price', reservation_room_extras ='$json_extras' WHERE reservation_id = $reservation_id";
       print $sql;
       $result = mysqli_query($mysqli, $sql);

    }
}
header("Location: /student041/dwes/forms/form_reservations_update_call.php");     
?>