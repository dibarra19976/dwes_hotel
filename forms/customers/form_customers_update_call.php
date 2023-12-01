<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update customer</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"].'/student041/dwes/header.php')  ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  " >
        <div class="float-content w-100">
    <h1>Update customer</h1>

        <form class="row align-items-start" action="/student041/dwes/forms/customers/form_customers_update.php" method="POST">
        
            <div class="mb-3 col-12">
                <div class="row">
                    <div class="col">
                        <label for="customer_id"  class="form-label">Select a customer: </label>
                        <select class="form-select w-100" name="customer_id">
                            <?php 
                           include($_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/db/customers/db_customers_option_list.php");
                           
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