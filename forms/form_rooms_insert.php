<?php
include("../db/db_room_type_select.php");

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Insert room</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include("../header.php") ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  " >
        <div class="float-content">        <h1>Insert room </h1>

        <form class="row" action="../db/db_rooms_insert.php" method="POST">
            <div class=" col">
                <label for="number" class="form-label">Room Number</label>
                <input type="text" class="form-control" name="number" min="0">
            </div>
            <div class="col">
                <label class="form-label" for="status" required>Room Status</label>
                <select class="form-select" id="status" name="status">
                    <option values="ready">ready</option>
                    <option values="check-in">check-in</option>
                    <option values="check-out">check-out</option>
                    <option values="unavailable">unavailable</option>
                </select>
            </div>
            <div class=" col-12">
            <label for="">Room Type</label>            

            <div class="d-flex justify-content-between">
                    <?php
                    $i = 0;
                    foreach ($room_types as $type) {
                        echo
                        '
                        <div class="">
                        <input class="form-check-input" type="radio" required name="type" id="room', ($i + 1), '" value="', $type['type_id'], '">
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
                <input type="text" class="form-control" name="img_main" >
            </div>
            <div class="col">
                <label for="img_1" class="form-label">Img 1 (Route)</label>
                <input type="text" class="form-control" name="img_1" >
            </div>
            <div class="col">
                <label for="img_2" class="form-label">Img 2 (Route)</label>
                <input type="text" class="form-control" name="img_2" >
            </div>
            <div class="col">
                <label for="img_3" class="form-label">Img 3 (Route)</label>
                <input type="text" class="form-control" name="img_3" >
            </div>
            
            <button type="submit" class=" btn btn-primary ">Submit</button>


    </div>
    </form>
    </div>
    </div>

</body>

</html>