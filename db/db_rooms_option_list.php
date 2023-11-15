<?php

include ("../db/db_connection.php");
$sql_query = 
"
SELECT room_number, room_id FROM rooms WHERE !( room_status = 'unavailable'); 
";  

//CALL `checkAvailableRooms`('$date_in', '$date_out', '$room_type', 100); 
 
$result = mysqli_query($mysqli, $sql_query);
$rooms  = mysqli_fetch_all($result, MYSQLI_NUM);
$i = 1;
foreach ($rooms as $room) {
    echo "<option class='datalistOptions' values='$room[1]' > $room[1] Room $room[0]</option>" ;
    //"<option class="" value="' + $i +'">' + $customer+ '</option>';
    $i = $i +1;   
    
}
?>