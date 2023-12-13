<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Insert Invoice</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"].'/student041/dwes/header.php')  ?>
    
    
    <?php
    if (isset($_SESSION['deleted'])) {
        echo "
        <div class='padding-notification alert alert-primary alert-dismissible fade show position-absolute start-50 z-on-top translate-middle w-75' role='alert'>";
        if ($_SESSION['deleted'] == "yes") {
            echo "Reservation was set as check-out and the invoice was created";
        } else {
            echo "Reservation set as cancelled and the invoice was created";
        }
        echo "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
        </div>";
    }
    unset($_SESSION['message']);
    ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content w-100 ">
            <h1>Insert Invoice</h1>

            <form class="row align-items-start" action="/student041/dwes/forms/invoices/form_invoices_insert.php" method="POST">

                <div class="mb-3 col-12">
                    <div class="row">
                        <div class="col">
                            <label for="reservation_id" class="form-label">Select a reservation: </label>
                            <select class="form-select w-100" name="reservation_id">
                                <?php
                                include($_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/db/reservations/db_reservations_option_list.php");

                                ?>
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