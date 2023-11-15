<?php

include("db_connection.php");

$email = $_POST['email'];
$password = $_POST['password'];

$sql_query =
    "
SELECT * FROM 041_customers 
WHERE customer_email = '$email'
AND customer_password = '$password'; 
";


$result = mysqli_query($mysqli, $sql_query);
$result  = mysqli_fetch_all($result, MYSQLI_ASSOC);


if (count($result) == 0) {
    echo " es zero";
    header("Location: /student041/dwes/forms/form_log_in.php");     
} else if (count($result) > 1) {
    echo "\n mas de uno";
    header("Location: /student041/dwes/forms/form_log_in.php");     
} else if (count($result) == 1) {
    $id = $result[0]['customer_id'];

    $sql_query =
        "SELECT * 
        FROM 041_customers 
        WHERE customer_id = '$id'";

    $result = mysqli_query($mysqli, $sql_query);
    $result  = mysqli_fetch_all($result, MYSQLI_ASSOC);

    $fname =  $result[0]['customer_fname'];
    $lname = $result[0]['customer_lname'];
    $status = $result[0]['customer_status'];

    session_start();
    $_SESSION['login_id'] = $id;
    $_SESSION['login_fname'] =  $fname;
    $_SESSION['login_lname'] =  $lname;
    $_SESSION['login_status'] =  $status;
    header("Location: /student041/dwes/index.php");
}

?>