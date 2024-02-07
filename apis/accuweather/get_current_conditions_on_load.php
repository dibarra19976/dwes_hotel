<?php 
$weather_file = "http://dataservice.accuweather.com/currentconditions/v1/3544090/?apikey=Jf8GXnTKOKPxT35yD8RHA8MvgubaE26G&details=true";
    
$weather_json = file_get_contents($weather_file);

$weather = json_decode($weather_json, true);

// print_r($weather);

copy($weather_file, $_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/apis/accuweather/files/current_conditions.json");

$date = date("Y-m-d");

copy($weather_file, $_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/apis/accuweather/files/current_conditions_".$date.".json");
// i want to save the json in a local file

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");


$sql = "INSERT INTO `041_api_weather`  
(weather_json)	
VALUES ('$weather_json')";

$query = mysqli_query($mysqli, $sql);


//then i want to save the json inside the database

?>