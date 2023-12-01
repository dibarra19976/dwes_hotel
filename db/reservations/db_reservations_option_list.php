<?php

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
$sql_query = 
"
SELECT reservation_id FROM `041_reservations` 
WHERE reservation_status NOT IN ('cancelled', 'check-out');
";  

 
$result = mysqli_query($mysqli, $sql_query);
$reservations  = mysqli_fetch_all($result, MYSQLI_NUM);
$i = 1;
foreach ($reservations as $reservation) {
    echo "<option class='datalistOptions' value='$reservation[0]' > $reservation[0]</option>" ;
    //"<option class="" value="' + $i +'">' + $customer+ '</option>';
    $i = $i +1;   
    
}
?>