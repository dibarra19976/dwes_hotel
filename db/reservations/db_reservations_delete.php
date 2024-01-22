

<?php

$delete_confirmation = $_POST['delete_confirmation'];
$id = $_POST['id'];

include($_SERVER["DOCUMENT_ROOT"] . "/student041/dwes/db/connection/db_connection.php");
session_start();
if ($delete_confirmation == 'yes') {
    $sql = "UPDATE 041_reservations SET reservation_status='cancelled' WHERE reservation_id='$id';";
    print $sql;
    $result = mysqli_query($mysqli, $sql);
    $sql = "CALL `041_checkOut`('$id'); ";
    print $sql;
    $result = mysqli_query($mysqli, $sql);
    $_SESSION['deleted'] = "yes";


    $sql = "SELECT * FROM 041_reservations WHERE reservation_id = $id";
    print $sql;
    $result = mysqli_query($mysqli, $sql);
    $reservation  = mysqli_fetch_all($result, MYSQLI_ASSOC);
    $room = $reservation[0]["reservation_room"];

    $sql = "UPDATE 041_rooms SET room_status='ready' WHERE room_id = $room_id";
    print $sql;
    $result = mysqli_query($mysqli, $sql);
    
} else {
    $_SESSION['deleted'] = "no";
}


header("Location: /student041/dwes/forms/reservations/form_reservations_delete_call.php");
