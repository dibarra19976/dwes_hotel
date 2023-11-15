<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include("../header.php") ?>
    <div class="container content">
    <h1>Select customers    </h1>
    <?php 
    include("../db/db_customers_select_table.php");
    ?>
    </div>

</body>

</html>