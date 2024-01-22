<?php
// include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/header.php');
session_start();

print_r($_POST);

$date_in = $_POST['date_in'];
$date_out = $_POST['date_out'];
$client = $_SESSION["login_id"];
$room = $_POST["room_id"];

$room_price = $_POST["room_price"];

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");


if ($date_in < $date_out) {
    $sql = "CALL `041_checkAvailableRooms`('$date_in', '$date_out');";
    $result = mysqli_query($mysqli, $sql);
    $rooms  = mysqli_fetch_all($result, MYSQLI_ASSOC);
    mysqli_free_result($result);
    mysqli_next_result($mysqli);
    $i = 0;
    $available = false;
    do {
        $available = $room == $rooms[$i]['room_id'];
        $i++;
    } while (!$available and  $i < count($rooms));


    if ($available == true) {
        $sql_select = "
        SELECT room_available_extras, r.type_price_per_day FROM 041_rooms 
        INNER JOIN `041_room_types` r ON r.`type_id` = `room_type`
        WHERE `room_id` = $room;";
        $result_select = mysqli_query($mysqli, $sql_select);
        $room_select  = mysqli_fetch_all($result_select, MYSQLI_ASSOC);
        mysqli_free_result($result_select);

        $room_extras = $room_select[0]['room_available_extras'];
        
        $decode = json_decode($room_extras);
        foreach ($decode as $key => &$value) {
          if(isset($_POST[$key])){
          }
          else{
            $value[0] = 0;
          }

        }
        
        print_r($decode);

        $room_extras = json_encode($decode);

        
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

        $sql_insert = "INSERT INTO `041_reservations`  
        (reservation_client, reservation_room, reservation_date_in, reservation_date_out, reservation_room_price, reservation_room_extras, reservation_services, reservation_status)
        VALUES
        ($client, $room, '$date_in', '$date_out', $room_price, '$room_extras', '$services_template', 'booked'  );
     ";

        $result_insert = mysqli_query($mysqli, $sql_insert);
        print_r($result_insert);
        $_SESSION["message"] = "Room booked succesfully!";
    }
}

header("Location: /student041/dwes/forms/form_reservations_client.php");
