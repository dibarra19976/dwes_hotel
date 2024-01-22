<?php

function validateInput($text)
{
    $text = htmlspecialchars($text);
    return $text;
}

function displayRoom($room)
{
?>
    <?php include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/db/rooms/db_room_type_select.php')  ?>

    <div class="room-card ">
        <h2>Room <?php echo $room["room_number"] ?></h2>
        <img class="img-fluid py-3 " src="<?php echo "/student041/dwes" . $room["room_img_main"] ?>" alt="">
        <h4>Type: <?php echo $room_types[$room["room_type"]]["type_name"] ?></h4>
        <h4>Price: <?php echo $room_types[$room["room_type"]]["type_price_per_day"] ?>€</h4>
        <h4>Extras</h4>
        <ul>
            <?php
            $decode = json_decode($room['room_available_extras']);
            foreach ($decode as $key => $value) {
                echo "<li>" . $key  . " ";
                if ($value[0] == 0) {
                    echo '<i class="bi bi-square"></i>';
                } else {
                    echo '<i class="bi bi-check-square-fill"></i>';
                }
                echo "</li>";
            }
            ?>
        </ul>
        <form action="/student041/dwes/forms/form_reservations_client_room_extras.php" method="POST">
            <input type="hidden" name="room_price" value="<?php echo $room_types[$room["room_type"]]["type_price_per_day"] ?>">
            <input type="hidden" name="date_out" value="<?php echo $_SESSION["date_out"]; ?>">
            <input type="hidden" name="date_in" value="<?php echo $_SESSION["date_in"]; ?>">
            <input type="hidden" name="room_id" value="<?php echo $room["room_id"] ?>">
            <input type="submit" value="Reserve Room" class="btn btn-primary">
        </form>
    </div>
<?php
}

?>