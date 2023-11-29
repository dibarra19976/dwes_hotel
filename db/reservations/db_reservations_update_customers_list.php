<?php

include ("../db/db_connection.php");
$sql_query = 
"
SELECT 041_fullName(customer_fname, customer_lname), customer_id FROM 041_customers; 
";  

$result = mysqli_query($mysqli, $sql_query);
$customers  = mysqli_fetch_all($result, MYSQLI_NUM);
foreach ($customers as $customer) {
    $id = $customer[1];
    $name = $customer[0];
    echo "<option value='$id' ";
    if ($customer_id == $id) {
        echo "selected='selected'";
    }
    echo " class='datalistOptions' >" . $id . " " .$name . "</option>";

}

?>

