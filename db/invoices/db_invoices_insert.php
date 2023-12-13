

<?php

$delete_confirmation = $_POST['delete_confirmation'];
$id = $_POST['id'];

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
session_start();
if($delete_confirmation=='yes'){
    $sql = "UPDATE 041_reservations SET reservation_status='check-out' WHERE reservation_id='$id';";
    print $sql;
    $result = mysqli_query($mysqli, $sql);
    $sql = "CALL `041_checkOut`('$id'); ";
    print $sql;
    $result = mysqli_query($mysqli, $sql);
    $_SESSION['deleted'] = "yes";
    
}
else{
    $sql = "UPDATE 041_reservations SET reservation_status='cancelled' WHERE reservation_id='$id';";
    print $sql;
    $result = mysqli_query($mysqli, $sql);
    $sql = "CALL `041_checkOut`('$id'); ";
    print $sql;
    $result = mysqli_query($mysqli, $sql);
    $_SESSION['deleted'] = "no";

}


header("Location: /student041/dwes/forms/invoices/form_invoices_insert_call.php");     
