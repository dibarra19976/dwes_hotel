

<?php

$delete_confirmation = $_POST['delete_confirmation'];
$id = $_POST['id'];

include ("./db_connection.php");

session_start();
if($delete_confirmation=='yes'){
    $sql = "UPDATE customers SET customer_status='disabled' WHERE customer_id='$id';";
    $result = mysqli_query($mysqli, $sql);
    $_SESSION['deleted'] = "yes";
    
}
else{
    $_SESSION['deleted'] = "no";
}


header("Location: /student041/dwes/forms/form_customers_delete_call.php");     
 


?>
