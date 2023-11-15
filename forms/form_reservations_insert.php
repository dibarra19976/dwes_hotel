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
        <h1>Insert reservation</h1>

        <form class="row align-items-start" action="../db/db_reservations_insert.php" method="POST">

            <div class="mb-3 col-12">
                <div class="row">
                    <div class="col">
                        <label class="form-label" for="room">Room</label>
                        <select class="form-control" name="room">
                            <?php 
                           include("../db/db_rooms_option_list.php");
                           
                            ?>
                        </select>
                    </div>
                    <div class="col">
                        <label class="form-label" for="client">Customer</label>
                        <select class="form-control" id="client" name="client">
                            <?php
                            include("../db/db_customers_option_list.php")
                            ?>
                        </select>
                    </div>
                </div>
            </div>
            <div class="mb-3 col-12">
                <div class="row">
                    <!-- <div class="col">
                        <label class="form-label" for="date_in">Date IN</label>
                        <input class="form-control" type="date" name="date_in" id="date_in" required>
                    </div>
                    <div class="col">
                        <label class="form-label" for="date_out">Date OUT</label>
                        <input class="form-control" type="date" name="date_out" id="date_out" required>
                    </div> -->
                    <div class="col">
                        <label class="form-label" for="date_in">Date IN</label>
                        <input class="form-control" type="date" name="date_in" id="date_in" required
                        min="<?php echo date("Y-m-d") ?>">
                    </div>
                    <div class="col">
                        <label class="form-label" for="date_out">Date OUT</label>
                        <input class="form-control" type="date" name="date_out" id="date_out" required 
                        min="<?php echo date("Y-m-d") ?>">
                    </div>
                </div>
            </div>
        
            <button type="submit" class=" btn btn-primary">Submit</button>

        </form>
    </div>

</body>

</html>