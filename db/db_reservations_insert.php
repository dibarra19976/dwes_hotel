<?php

$room = $_POST['room'];
$client = $_POST['client'];
$date_in = $_POST['date_in'];
$date_out = $_POST['date_out'];

include("./db_connection.php");


if ($date_in < $date_out) {
    $sql = "CALL `041_checkAvailableRooms`('$date_in', '$date_out');";
    $result = mysqli_query($mysqli, $sql, MYSQLI_STORE_RESULT);
    $rooms  = mysqli_fetch_all($result, MYSQLI_ASSOC);

    $i = 0;
    $available = false;
    do {
        $available = $room == $rooms[$i]['room_id'];
        $i++;
    } while (!$available AND  $i < count($rooms));
    

    if($available == true){
        $sql_select = "SELECT * FROM 041_rooms WHERE $room = room_id";
        $result_select = mysqli_query($mysqli, $sql_select, MYSQLI_STORE_RESULT);
        $room_select  = mysqli_fetch_all($result_select, MYSQLI_ASSOC);
   
        $room_price =  $room_select[0]['room_price'];
        $room_extras = $room_select[0]['room_available_extras'];
        $services_template = '{
            "prices":{
                "bar":[],
                "dvdRenting":[],
                "gym":[],
                "spa":[]
            },
            "dates":{
                "bar":[],
                "dvdRenting":[],
                "gym":[],
                "spa":[]
            },
            "descriptions":{
                "bar":[],
                "dvdRenting":[],
                "gym":[],
                "spa":[]
            }
        }';

        $sql_insert = "INSERT INTO 041_reservations  
        (reservation_client, reservation_room, reservation_date_in, reservation_date_out, reservation_room_price, reservation_room_extras, reservation_services, reservation_status)
        VALUES
        ($client, $room, '$date_in', '$date_out', $room_price, '$room_extras', '$services_template', 'booked'  );
        ";
    }
}

// $sql_select = 
// "
// SELECT * FROM 041_customers ORDER BY customer_id DESC LIMIT 1;
// ";
// $result = mysqli_query($mysqli, $sql_select);

// $select  = mysqli_fetch_all($result, MYSQLI_ASSOC);
// print_r($select);
