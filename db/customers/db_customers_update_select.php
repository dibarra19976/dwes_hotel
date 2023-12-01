<?php

$customer_id = $_POST["customer_id"]; 
include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
$sql_query = 
"
SELECT * FROM 041_customers WHERE customer_id = '$customer_id';  
";  

 
$result = mysqli_query($mysqli, $sql_query);
$customer  = mysqli_fetch_all($result, MYSQLI_ASSOC);

?>  