

<?php

$delete_confirmation = $_POST['delete_confirmation'];
$id = $_POST['id'];

include ($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");

session_start();
if($delete_confirmation=='yes'){
    $sql = "UPDATE 041_customers SET customer_status='disabled' WHERE customer_id='$id';";
    $result = mysqli_query($mysqli, $sql);
    $_SESSION['deleted'] = "yes";
    
}
else{
    $_SESSION['deleted'] = "no";
}


header("Location: /student041/dwes/forms/customers/form_customers_delete_call.php");     
 


?>

