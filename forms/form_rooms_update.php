<?php
include("../db/db_room_type_select.php");
include("../db/db_rooms_update_select.php");

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
        <h1>Update room </h1>

        <form class="row" action="../db/db_rooms_update.php" method="POST">
            <div class=" col">
                <label for="number" class="form-label">Room Number</label>
                <input type="text" class="form-control" name="number" min="0" value="<?php echo $room[0]['room_number'] ?>">
            </div>
            <div class="col">
                <label class="form-label" for="status" required>Room Status</label>
                <select class="form-control" id="status" name="status">
                    <option values="ready">ready</option>
                    <option values="check-in">check-in</option>
                    <option values="check-out">check-out</option>
                    <option values="unavailable">unavailable</option>
                </select>
            </div>
            <div class=" col-12">
                <div class="d-flex justify-content-evenly">
                    <?php
                    $i = 0;
                    foreach ($room_types as $type) {
                        echo
                        '
                        <div class="">
                        <input class="form-check-input" type="radio"  required name="type" id="room', ($i + 1), '" value="', $type['type_id'], '">
                        <label class="form-check-label" for="room', ($i + 1), '">',
                        $type['type_name'], " (", $type['type_id'], ")",
                        '</label>
                        </div>
                        ';
                        $i++;
                    }

                    ?>
                </div>

            </div>
            <div class="col">
                <label for="img_main" class="form-label">Img Main (Route)</label>
                <input type="text" class="form-control" name="img_main" value="<?php echo $room[0]['room_img_main'] ?>">
            </div>
            <div class="col">
                <label for="img_1" class="form-label">Img 1 (Route)</label>
                <input type="text" class="form-control" name="img_1" value="<?php echo $room[0]['room_img_1'] ?>">
            </div>
            <div class="col">
                <label for="img_2" class="form-label">Img 2 (Route)</label>
                <input type="text" class="form-control" name="img_2" value="<?php echo $room[0]['room_img_2'] ?>">
            </div>
            <div class="col">
                <label for="img_3" class="form-label">Img 3 (Route)</label>
                <input type="text" class="form-control" name="img_3" value="<?php echo $room[0]['room_img_3'] ?>">
            </div>
            <div class="col-12">
                <h2>Extras</h2>
                <?php

                $json = $room[0]['room_available_extras'];

                $decoded = json_decode($json, true);

                $i = 1;
                foreach ($decoded as $key => $value) {
                    echo '<label for="json', $i, '" class="form-label">', $key, '</label>
                    ';
                    echo '<input min?"0" type="text" class="form-control" name="json', $i,'" value="', $value[0], ' ">';
                    $i++;
                }
                ?>
            </div>
            <div class="d-none">
                <input class="form-control" type="text" name="room_id" id="room_id" required value="<?php echo $room[0]['room_id']; ?>">
            </div>
            <button type="submit" class=" btn btn-primary">Submit</button>


    </div>
    </form>
    </div>

</body>

</html>