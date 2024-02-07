<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Reservations</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/header.php')  ?>
    <div class="container-fluid content">
        <div>
            <h1 class="white ">Reservations </h1>
            <input type="text" name="" id="search" class="form-control" oninput="loadDoc()" placeholder="Search... (Search by the first name)">
        </div>
        <div id="demo"></div>
    </div>
    <script>
        loadDoc();

        function loadDoc() {
            let str = document.getElementById("search").value;
            const xhttp = new XMLHttpRequest();
            xhttp.onload = function() {
                document.getElementById("demo").innerHTML =
                    this.responseText;
            }
            xhttp.open("GET"    , "/student041/dwes/db/reservations/ajax_get_db_reservations_select_table.php?text=" + str, true);
            xhttp.send();
        }
    </script>
</body>

</html>