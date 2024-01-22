<?php
include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/reservations/db_reservations_update_select.php");

$reservation_id = $_POST['reservation_id'];
$status = $_POST['status'];

$sql = "SELECT * FROM 041_reservations WHERE reservation_id = $reservation_id";
print $sql;
$result = mysqli_query($mysqli, $sql);
$reservation  = mysqli_fetch_all($result, MYSQLI_ASSOC);
$room = $reservation[0]["reservation_room"];

$sql = "UPDATE 041_reservations SET reservation_status='$status' WHERE reservation_id = $reservation_id";
print $sql;
$result = mysqli_query($mysqli, $sql);

if($status=="check-in"){
    $sql = "UPDATE 041_rooms SET room_status='check-in' WHERE room_id = $room_id";
    print $sql;
    $result = mysqli_query($mysqli, $sql);
}
elseif($status=="check-out" || $status=="cancelled"){
    $sql = "UPDATE 041_rooms SET room_status='check-out' WHERE room_id = $room_id";
    print $sql;
    $result = mysqli_query($mysqli, $sql);

    if($status=="check-out" ){
        $sql = "CALL `041_checkOut`('$reservation_id'); ";
        print $sql;
        $result = mysqli_query($mysqli, $sql);
    }

    if($status=="cancelled" ){

        $sql = "CALL `041_checkOut`('$reservation_id'); ";
        print $sql;
        $result = mysqli_query($mysqli, $sql);
    }


}



$_SESSION['message'] = "Room and reservation updated!";
header("Location: /student041/dwes/forms/reservations/form_reservations_status.php");     
?>