<?php
include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/functions/php/functions.php");

$name = validateInput($_POST['name']);
$lname =validateInput($_POST['lname']);
$dni = validateInput($_POST['dni']);
$password =validateInput($_POST['password']);
$birthdate = validateInput($_POST['birthdate']);
$email = validateInput($_POST['email']);
$number = validateInput($_POST['number  ']);
$status = validateInput($_POST['status']);


include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");

$sql = 
"INSERT INTO 041_customers 
(customer_fname, customer_lname, customer_dni , customer_email , customer_phone , customer_birthdate , customer_password, customer_status )	
VALUES (
'$name ', '$lname', '$dni', '$email', '$number', '$birthdate', '$password', '$status'
    );";
 
$query = mysqli_query($mysqli, $sql);



$sql_select = 
"
SELECT * FROM 041_customers ORDER BY customer_id DESC LIMIT 1;
";
$result = mysqli_query($mysqli, $sql_select);

$select  = mysqli_fetch_all($result, MYSQLI_ASSOC);
print_r($select);


header("Location: /student041/dwes/forms/customers/form_customers_insert.php");     
