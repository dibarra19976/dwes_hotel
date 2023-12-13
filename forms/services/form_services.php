<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Services</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/header.php')  ?>


    <?php
    if (isset($_SESSION['message'])) {
        echo "
        <div class='padding-notification alert alert-primary alert-dismissible fade show position-absolute start-50 z-on-top translate-middle w-75' role='alert'>";
        echo $_SESSION['message'];
        echo "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
        </div>";
    }
    unset($_SESSION['deleted']);
    ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content w-100 ">
            <h1>Services</h1>

            <form class="row align-items-start" action="/student041/dwes/db/services/db_services.php" method="POST">

                <div class="mb-3 col-12">
                    <div class="row">
                        <div class="col">
                            <label for="room_id" class="form-label">Select a room: </label>
                            <select class="form-select w-100" name="room_id">
                                <?php
                                include($_SERVER["DOCUMENT_ROOT"] . "/student041/dwes/db/services/db_rooms_option_list.php");

                                ?>
                            </select>
                        </div>
                        <div class="col">
                            <label for="service" class="form-label">Select a service: </label>
                            <select class="form-select w-100" name="service">
                                <option value="1">Bar</option>
                                <option value="2">DVD Renting</option>
                                <option value="3">Gym</option>
                                <option value="4">Spa</option>

                            </select>
                        </div>
                    </div>
                    <div class="row mt-4">
                    <div class="col">
                        <label for="description" class="form-label">Concept: </label>
                        <input type="text" class="form-control" name="description" id="description">
                    </div>
                    <div class="col">
                        <label for="price" class="form-label">Insert the price: </label>
                        <input type="number" min="1" step="any" class="form-control" name="price" id="price">
                    </div>
                </div>

                </div>
                <button type="submit" class=" btn btn-primary">Submit</button>

        </div>

    </div>
    </form>
    </div>
    </div>

</body>

</html>