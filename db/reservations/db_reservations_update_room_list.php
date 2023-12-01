<?php

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
$sql_query = 
"
SELECT room_number, room_id FROM 041_rooms WHERE !( room_status = 'unavailable'); 
";  

 
$result = mysqli_query($mysqli, $sql_query);
$rooms  = mysqli_fetch_all($result, MYSQLI_NUM);
foreach ($rooms as $room) {
    $id = $room[1];
    $number = $room[0];
    echo "<option value='$id' ";
    if ($room_id == $id) {
        echo "selected='selected'";
    }
    echo " class='datalistOptions' >" . $id . " - Room " . $number . "</option>"; 
}
?>