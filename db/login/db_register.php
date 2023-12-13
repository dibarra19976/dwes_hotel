<?php
session_start();


$name = $_POST['name'];
$lname = $_POST['lname'];
$dni = " ";
$password = $_POST['password'];
$birthdate = $_POST['birthdate'];
$email = $_POST['email'];
$number = $_POST['number'];
$status = $_POST['status'];


include($_SERVER["DOCUMENT_ROOT"] . "/student041/dwes/db/connection/db_connection.php");

try {
    $sql =
        "INSERT INTO 041_customers 
(customer_fname, customer_lname, customer_dni , customer_email , customer_phone , customer_birthdate , customer_password, customer_status )	
VALUES (
'$name ', '$lname', '$dni', '$email', '$number', '$birthdate', '$password', '$status'
    );";

    $query = mysqli_query($mysqli, $sql);
} catch (mysqli_sql_exception  $e) {
    $_SESSION['message'] =  "ERROR - Email ya usado";
    header("Location: /student041/dwes/forms/login/form_register.php");
}
if ($query) {

    $sql_select =
        "
SELECT * FROM 041_customers ORDER BY customer_id DESC LIMIT 1;
";
    $result = mysqli_query($mysqli, $sql_select);

    $select  = mysqli_fetch_all($result, MYSQLI_ASSOC);
    $id = $select[0]['customer_id'];
    $fname =  $select[0]['customer_fname'];
    $lname = $select[0]['customer_lname'];
    $status = $select[0]['customer_status'];

    $_SESSION['login_id'] = $id;
    $_SESSION['login_fname'] =  $fname;
    $_SESSION['login_lname'] =  $lname;
    $_SESSION['login_status'] =  $status;
    header("Location: /student041/dwes/index.php");
}
print_r($select);
