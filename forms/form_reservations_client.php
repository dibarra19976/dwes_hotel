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
    <?php include("../header.php") ?>

    <!-- Primero el buscador de reservas -->

    <!-- Mis reservas -->
    <!-- Solo si el usuario esta logeado -->
    <!-- Buscamos en reservations group by reservation_group and where customer_id = SESSION[customer_id] -->
    <!-- hacemos un div por cada una de los resultados -->
    <!-- hacemos un where reservation_group para las habitaciones individuales -->
    <!-- mostramos un subdiv de cada habitacion -->
    <!-- se vuelve a repeter con el resto de reservation groups -->


    ?>
    <div class="container-fluid content content">
        <div class="container ">
            <form class="row" action="../db/db_rooms_select_availability.php" method="POST">
                <form class="row align-items-start" action="db/db_rooms_select_availability.php" method="POST">
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

                    <button type="submit" class=" btn btn-primary">Submit</button>
        </div>
        </form>

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