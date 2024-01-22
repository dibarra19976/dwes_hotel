<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Status</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/header.php');  
    if (isset($_SESSION['message'])) {
        echo "
        <div class='padding-notification alert alert-primary alert-dismissible fade show position-absolute start-50 z-on-top translate-middle w-75' role='alert'>";
        echo $_SESSION['message'];
        echo "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
        </div>";
    }
    unset($_SESSION['message']);
    ?>

    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content w-100 ">
            <h1>Reservation Status</h1>

            <form class="row align-items-start" action="/student041/dwes/db/reservations/db_reservations_status.php" method="POST">

                <div class="mb-3 col-12">
                    <div class="row">
                        <div class="col">
                            <label for="reservation_id" class="form-label">Select a reservation: </label>
                            <select class="form-select w-100" name="reservation_id">
                                <?php
                                include($_SERVER["DOCUMENT_ROOT"] . "/student041/dwes/db/reservations/db_reservations_option_list.php");

                                ?>
                            </select>

                        </div>
                        <div class="col">
                        <label for="reservation_id" class="form-label">Select a status: </label>
                            <select class="form-select w-100" name="status">
                                <option value="booked">booked</option>
                                <option value="check-in">check-in</option>
                                <option value="check-out">check-out</option>
                                <option value="cancelled">cancelled</option>
                            </select>
                        </div>
                    </div>
                </div>


                <button type="submit" class=" btn btn-primary">Submit</button>
        </div>
        </form>
    </div>
    </div>

</body>

</html>