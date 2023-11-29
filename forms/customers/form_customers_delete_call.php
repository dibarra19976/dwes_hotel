<?php


?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete customer</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>

    <?php include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/header.php') ?>
    
    <?php
    if (isset($_SESSION['deleted'])) {
        echo "
        <div class='padding-notification alert alert-primary alert-dismissible fade show position-absolute start-50 z-on-top translate-middle w-75' role='alert'>";
        if ($_SESSION['deleted'] == "yes") {
            echo "User was deleted";
        } else {
            echo "User was not deleted";
        }
        echo "<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
        </div>";
    }
    unset($_SESSION['deleted']);
    ?>

    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content w-100">
            <h1>Delete customer</h1>
            <form class="row align-items-start" action="/student041/dwes/forms/customers/form_customers_delete.php" method="POST">
                <div class="mb-3 col-12">
                    <div class="row">
                        <div class="col">
                            <label for="customer_id" class="form-label">Select a customer: </label>
                            <select class="form-select w-100" name="customer_id">
                            <?php include($_SERVER["DOCUMENT_ROOT"].'/student041/dwes/db/customers/db_customers_option_list.php') ?>

                                
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