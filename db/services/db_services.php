

<?php

$room_id = $_POST['room_id'];
$description = $_POST['description'];
$service = $_POST['service'];
$price = $_POST['price'];

$description = random_int(100000, 999999) . " - " . $description;

include($_SERVER["DOCUMENT_ROOT"] . "/student041/dwes/db/connection/db_connection.php");
session_start();

$sql = "CALL `041_serviceAdd`('$service', '$description', '$room_id', '$price'); ";
$result = mysqli_query($mysqli, $sql);
if($result){
    $_SESSION['message'] = "Service added succesfully";


}
else{
    $_SESSION['message'] = "There was an error. Please try again.";
}

header("Location: /student041/dwes/forms/services/form_services.php");
