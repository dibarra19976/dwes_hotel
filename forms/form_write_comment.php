 <?php include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/header.php')  ?>
<?php

if (!isset($_SESSION["login_id"])) {
    $_SESSION['message'] = "You need an account ";
    header("Location: /student041/dwes/forms/login/form_register.php");
}
include($_SERVER["DOCUMENT_ROOT"] . "/student041/dwes/db/rooms/db_rooms_update_select.php");


$customer_id = $_SESSION["login_id"];
$room_id = $_POST["room_id"];
$room_price = $_POST["room_price"];
$date_in = $_POST["date_in"];
$date_out = $_POST["date_out"];

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room extras</title>
</head>

<body>

    ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content">

            <div class="">
                <div class="rooms-container">
                    <form action="/student041/dwes/db/db_reservations_client_book.php" method="POST">

                        <h1>Room <?php echo $room[0]["room_number"] ?></h1>
                        <h3>Select the extras you want with your room</h3>
                        <p>If you want none, just continue</p>
                        <?php
                        $check = false;
                        $decode = json_decode($room[0]['room_available_extras']);
                        foreach ($decode as $key => $value) {
                            if (!$value[0] == 0) {
                                $check = true;
                                echo "<li class='list'>";
                                echo "<label for='" . $key  . "'></label>" . $key  . "</label>";
                                echo "<input type='checkbox' name='";
                                echo $key;
                                echo "' >
                                </li>";
                            }
                        }
                        if ($check == false) {
                            echo "<h5 class='text-center' style='  padding-block: 40px;'>There are no extras available for this room...</h5>";
                        }

                        ?>
                        <input type="hidden" name="room_price" value="<?php echo $room_price ?>">
                        <input type="hidden" name="date_out" value="<?php echo $date_out; ?>">
                        <input type="hidden" name="date_in" value="<?php echo $date_in; ?>">
                        <input type="hidden" name="room_id" value="<?php echo $room_id ?>">
                        <input type="hidden" name="customer_id" value="<?php echo $customer_id; ?>">
                        <input type="submit" value="Book Room" class="w-100 btn btn-primary">
                    </form>

                </div>
            </div>
        </div>
    </div>

</body>

</html>