<?php
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"] . "/student041/dwes/functions/php/functions.php"); ?>
    <?php include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/header.php')  ?>
    <?php include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/db/rooms/db_room_type_select.php')  ?>
    <?php
    if (isset($_SESSION['message'])) {
        echo "
        <div class='padding-notification alert alert-primary alert-dismissible fade show position-absolute start-50 z-on-top translate-middle w-75' role='alert'>";
        echo $_SESSION['message'];
        echo "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
        </div>";
    }
    unset($_SESSION['message']);
    ?>
    <!-- Primero el buscador de reservas -->

    <!-- Mis reservas -->
    <!-- Solo si el usuario esta logeado -->
    <!-- Buscamos en reservations group by reservation_group and where customer_id = SESSION[customer_id] -->
    <!-- hacemos un div por cada una de los resultados -->
    <!-- hacemos un where reservation_group para las habitaciones individuales -->
    <!-- mostramos un subdiv de cada habitacion -->
    <!-- se vuelve a repeter con el resto de reservation groups -->


    ?>
    <div class="container-fluid   p-0">
        <div class="container-fluid room-search w-100 content">
            <div class="container">
                <h1>Search for a room</h1>
                <form class="row" action="/student041/dwes/db/rooms/db_rooms_select_availability.php" method="POST">
                    <form class="row align-items-start" action="/student041/dwes/db/rooms/db_rooms_select_availability.php" method="POST">
                        <div class="mb-3 col">
                            <label for="date_in" class="form-label">Check in</label>
                            <input min="<?php echo date("Y-m-d") ?>" required="true" type="date" class="form-control" name="date_in" value="<?php if (isset($_SESSION["date_in"])) {
                                                                                                                                                echo $_SESSION["date_in"];
                                                                                                                                            } ?>">
                        </div>
                        <div class="mb-3 col">
                            <label for="date_out" class="form-label">Check out</label>
                            <input min="<?php echo date("Y-m-d") ?>" required="true" type="date" class="form-control" name="date_out" value="<?php if (isset($_SESSION["date_out"])) {
                                                                                                                                                    echo $_SESSION["date_out"];
                                                                                                                                                } ?>">
                        </div>

                        <button type="submit" class=" btn btn-primary">Search Rooms</button>
                    </form>

            </div>
        </div>

        <?php

        if (isset($_SESSION["rooms_select"])) {
            $rooms = $_SESSION["rooms_select"];

        ?>

            <div class="">
                <div class="rooms-container">
                    <h1 class="w-100 text-center pb-5">Available rooms</h1>

                    <?php
                    foreach ($rooms as $room) {
                        displayRoom($room);
                    }


                    unset($_SESSION["rooms_select"]);
                    unset($_SESSION["date_in"]);
                    unset($_SESSION["date_out"]);
                    ?>

                </div>
            </div>
        <?php
        }


        ?>

    </div>
</body>

</html>

<?php

if (isset($_SESSION["rooms_select"])) {
    $rooms = $_SESSION["rooms_select"];
    unset($_SESSION["rooms_select"]);
    unset($_SESSION["date_in"]);
    unset($_SESSION["date_out"]);

    foreach ($rooms as $room) {
        print_r($room);
        echo "<br>";
    }
}


?>