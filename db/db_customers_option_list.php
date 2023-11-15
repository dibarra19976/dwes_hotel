<?php

include ("../db/db_connection.php");
$sql_query = 
"
SELECT 041_fullName(customer_fname, customer_lname), customer_id FROM 041_customers WHERE !( customer_status = 'disabled'); 
";  

//CALL `checkAvailableRooms`('$date_in', '$date_out', '$room_type', 100); 
 
$result = mysqli_query($mysqli, $sql_query);
$customers  = mysqli_fetch_all($result, MYSQLI_NUM);
$i = 1;
foreach ($customers as &$customer) {
    echo "<option class='datalistOptions' values='$customer[1]' > $customer[1] $customer[0]</option>" ;
    //"<option class="" value="' + $i +'">' + $customer+ '</option>';
    $i = $i +1;   
    
}
?>