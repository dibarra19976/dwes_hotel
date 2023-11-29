<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete room</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include("../header.php") ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center position-relative ">
        <div class="float-content ">        <h1>Delete room</h1>

        <form class="row align-items-start" action="../db/db_rooms_delete.php" method="POST">

            <div class="mb-3 col-12">
                <div class="row">
                    <h2>Are you sure you want to delete this room?</h2>
                    <div class="col">

                        <input class="form-check-input" type="radio" name="delete_confirmation" id="yes" value="yes">
                        <label class="form-check-label" for="yes">
                            Yes
                        </label>

                    
                        <input class="form-check-input" type="radio" name="delete_confirmation" id="no" value="no" checked>
                        <label class="form-check-label" for="no">
                            No
                        </label>


                    </div>

                </div>
            </div>

            <button type="submit" class=" btn btn-primary">Submit</button>
    </div>
    <input class="form-control" type="hidden" name="id" id="id" required value="<?php echo $_POST['room_id']; ?>">
    </form>
    </div>
    </div>

</body>

</html>