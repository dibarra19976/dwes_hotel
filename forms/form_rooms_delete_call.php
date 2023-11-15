<?php


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
    
    <?php include("../header.php"); 
    ?>
    <div class="container position-relative content">
        <?php 
        
        if (isset($_SESSION['deleted'])){
            echo"
        <div class='alert alert-primary alert-dismissible fade show position-absolute start-50 z-on-top translate-middle w-75' role='alert'>"
        ;
        if($_SESSION['deleted']=="yes"){
            echo "Room was deleted";
        }
        else{
            echo "Room was not deleted";
        }
        echo"<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
        </div>";
        }
        unset($_SESSION['deleted']);

        ?>
        <h1>Delete room</h1>
        <form class="row align-items-start" action="./form_rooms_delete.php" method="POST">
        
            <div class="mb-3 col-12">
                <div class="row">
                    <div class="col">
                        <label for="room_id"  class="form-label">Select a room: </label>
                        <select class="form-input w-100" name="room_id">
                            <?php 
                           include("../db/db_rooms_option_list.php");
                           
                            ?>
                        </select>
                    </div>

                </div>
              
            </div>


            <button type="submit" class=" btn btn-primary">Submit</button>
    </div>
    </form>
    </div>

</body>

</html>