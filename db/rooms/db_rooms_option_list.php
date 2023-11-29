<?php

include ("../db/db_connection.php");
$sql_query = 
"
SELECT room_number, room_id FROM 041_rooms WHERE !( room_status = 'unavailable'); 
";  

 
$result = mysqli_query($mysqli, $sql_query);
$rooms  = mysqli_fetch_all($result, MYSQLI_NUM);
$i = 1;
foreach ($rooms as $room) {
    echo "<option class='datalistOptions' value='$room[1]' > $room[1] Room $room[0]</option>" ;
    $i = $i +1;   
    
}
?>