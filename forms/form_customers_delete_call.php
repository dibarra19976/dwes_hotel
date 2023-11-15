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
            echo "User was deleted";
        }
        else{
            echo "User was not deleted";
        }
        echo"<button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
        </div>";
        }
        unset($_SESSION['deleted']);
        ?>
        <h1>Delete customer</h1>
        <form class="row align-items-start" action="./form_customers_delete.php" method="POST">
        
            <div class="mb-3 col-12">
                <div class="row">
                    <div class="col">
                        <label for="customer_id"  class="form-label">Select a customer: </label>
                        <select class="form-input w-100" name="customer_id">
                            <?php 
                           include("../db/db_customers_option_list.php");
                           
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