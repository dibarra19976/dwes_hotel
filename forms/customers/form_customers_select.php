<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select customers</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"].'/student041/dwes/header.php')  ?>
    <div class="container-fluid content">
    <h1 class="white ">Customers</h1>
    <?php 
    include($_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/db/customers/db_customers_select_table.php");
    ?>
    </div>

</body>

</html>