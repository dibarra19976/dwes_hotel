<?php

$name = $_POST['name'];
$lname = $_POST['lname'];
$dni = $_POST['dni'];
$password = $_POST['password'];
$birthdate = $_POST['birthdate'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$id = $_POST['id'];
$status = $_POST['status'];

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");

$sql = 
"
UPDATE 041_customers 
SET customer_fname='$name ', customer_lname='$lname', customer_dni='$dni', customer_email='$email', customer_phone='$phone', customer_birthdate='$birthdate', customer_password= '$password', customer_status ='$status'
WHERE customer_id = '$id';
";

 
$query = mysqli_query($mysqli, $sql);



$sql_select = 
"
SELECT * FROM 041_customers WHERE customer_id = '$id';
;
";
$result = mysqli_query($mysqli, $sql_select);

$select  = mysqli_fetch_all($result, MYSQLI_ASSOC);
print_r($select);


header("Location: /student041/dwes/forms/customers/form_customers_update_call.php");     
