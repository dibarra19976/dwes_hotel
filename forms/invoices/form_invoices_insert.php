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
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content">
            <h1>Insert Invoice</h1>

            <form class="row align-items-start" action="/student041/dwes/db/invoices/db_invoices_insert.php" method="POST">

                <div class="mb-3 col-12">
                    <div class="row">
                        <h2>Was the reservation finished?</h2>
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
        <input class="form-control" type="hidden" name="id" id="id" required value="<?php echo $_POST['reservation_id']; ?>">
        </form>
    </div>
    </div>

</body>

</html>