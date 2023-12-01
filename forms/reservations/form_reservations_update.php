<?php
include($_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/db/reservations/db_reservations_update_select.php");

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation update</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"].'/student041/dwes/header.php')  ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content">
            <h1>Update reservation</h1>

            <form class="row align-items-start" action="/student041/dwes/db/reservations/db_reservations_update.php" method="POST">
                <input type="hidden" name="reservation_id" value="<?php echo $reservation_id ?>">
                <div class="mb-3 col-12">
                    <div class="row">
                        <div class="col">
                            <label class="form-label" for="room">Room</label>
                            <select class="form-select" name="room">
                                <?php

                                include($_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/db/reservations/db_reservations_update_room_list.php");

                                ?>
                            </select>
                        </div>
                        <div class="col">
                            <label class="form-label" for="client">Customer</label>
                            <select class="form-select" id="client" name="client">
                                <?php
                                include($_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/db/reservations/db_reservations_update_customers_list.php")
                                ?>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="mb-3 col-12">
                    <div class="row">

                        <div class="col">
                            <label class="form-label" for="date_in">Date IN</label>
                            <input class="form-control" type="date" name="date_in" id="date_in" required value="<?php echo $reservation[0]['reservation_date_in'] ?>">
                        </div>
                        <div class="col">
                            <label class="form-label" for="date_out">Date OUT</label>
                            <input class="form-control" type="date" name="date_out" id="date_out" required value="<?php echo $reservation[0]['reservation_date_out'] ?>">
                        </div>
                    </div>
                </div>
                <div class="col-12">
                    <label for="room_price" class="form_label">Room Price</label>
                    <input type="text" class="form-control" name="room_price" id="room_price" value="<?php echo $reservation[0]['reservation_room_price']?>">
                </div>
                <div class="col-12">
                    <label for="">Room extras</label><br>
                    <?php

                    $json = $reservation[0]['reservation_room_extras'];

                    $decoded = json_decode($json, true);

                    $i = 1;
                    foreach ($decoded as $key => $value) {
                        echo '<label for="json', $i, '" class="form-label">', $key, '</label>
                    ';
                        echo '<input min?"0" type="text" class="form-control" name="json', $i, '" value="', $value[0], ' ">';
                        $i++;
                    }
                    ?>
                </div>

                <button type="submit" class=" btn btn-primary">Submit</button>

            </form>
        </div>
    </div>

</body>

</html>