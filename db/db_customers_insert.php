<?php

$name = $_POST['name'];
$lname = $_POST['lname'];
$dni = $_POST['dni'];
$password = $_POST['password'];
$birthdate = $_POST['birthdate'];
$email = $_POST['email'];
$number = $_POST['number'];
$status = $_POST['status'];


include ("./db_connection.php");

$sql = 
"
INSERT INTO customers 
(customer_fname, customer_lname, customer_dni , customer_email , customer_phone , customer_birthdate , customer_password, customer_status )	
VALUES (
'$name ', '$lname', '$dni', '$email', '$number', '$birthdate', '$password', '$status'
    )
";

//CALL `checkAvailableRooms`('$date_in', '$date_out', '$room_type', 100); 
 
$query = mysqli_query($mysqli, $sql);



$sql_select = 
"
SELECT * FROM customers ORDER BY customer_id DESC LIMIT 1;
";
$result = mysqli_query($mysqli, $sql_select);

$select  = mysqli_fetch_all($result, MYSQLI_ASSOC);
print_r($select);

