

<?php

$delete_confirmation = $_POST['delete_confirmation'];
$id = $_POST['room_id'];

include ("./db_connection.php");
session_start();
if($delete_confirmation=='yes'){
    $sql = "UPDATE 041_rooms SET room_status='unavailable' WHERE room_id='$id';";
    $result = mysqli_query($mysqli, $sql);
    $_SESSION['deleted'] = "yes";
    
}
else{
    $_SESSION['deleted'] = "no";

}


header("Location: /student041/dwes/forms/form_rooms_delete_call.php");     
