<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Rooms</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include("../header.php") ?>
    <div class="container-fluid content">
        <h1>Rooms</h1>
    <?php
    include("../db/db_rooms_select_table.php");
    ?>
    </div>

</body>

</html>