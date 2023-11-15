<?php

$customer_id = $_POST["customer_id"]; 
include ("../db/db_connection.php");
$sql_query = 
"
SELECT * FROM customers WHERE customer_id = '$customer_id';  
";  

 
$result = mysqli_query($mysqli, $sql_query);
$customer  = mysqli_fetch_all($result, MYSQLI_ASSOC);

?>  