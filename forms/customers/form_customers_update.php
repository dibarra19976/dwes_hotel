<?php
include($_SERVER["DOCUMENT_ROOT"]. "/student041/dwes/db/customers/db_customers_update_select.php");

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
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content">
            <h1>Update customer</h1>

            <form class="row align-items-start" action="/student041/dwes/db/customers/db_customers_update.php" method="POST">

                <div class="mb-3 col-12">
                    <div class="row">
                        <div class="col">
                            <label class="form-label" for="name">Name</label>
                            <input class='form-control' type='text' name='name' id='name' required value="<?php echo $customer[0]['customer_fname']; ?>">
                        </div>
                        <div class="col">
                            <label class="form-label" for="name">Last name</label>
                            <input class="form-control" type="text" name="lname" id="lname" required value="<?php echo $customer[0]['customer_lname']; ?>">
                        </div>
                    </div>
                </div>
                <div class="mb-3 col-12">
                    <div class="row">
                        <div class="col">
                            <label class="form-label" for="dni">DNI</label>
                            <input class="form-control" type="text" name="dni" id="dni" required value="<?php echo $customer[0]['customer_dni']; ?>">
                        </div>
                        <div class="col">
                            <label class="form-label" for="birthdate">Date of birth</label>
                            <input class="form-control" type="date" name="birthdate" id="birthdate" required value="<?php echo $customer[0]['customer_birthdate']; ?>">
                        </div>
                    </div>
                </div>
                <div class="mb-3 col-12">
                    <div class="row">
                        <div class="col">
                            <label class="form-label" for="email">Email</label>
                            <input class="form-control" type="text" name="email" id="email" required value="<?php echo $customer[0]['customer_email']; ?>">

                        </div>
                        <div class="col">
                            <label class="form-label" for="password">Password</label>
                            <input class="form-control" type="password" name="password" id="password" required value="<?php echo $customer[0]['customer_password'] ? : "$customer[0]['customer_password'] "; ?>">
                        </div>
                    </div>
                    <div class="mb-3 col-12">
                        <div class="row">
                            <div class="col">
                                <label class="form-label" for="phone">Phone Number</label>
                                <input class="form-control" type="text" name="phone" id="phone" required value="<?php echo $customer[0]['customer_phone'] ?  $customer[0]['customer_phone'] : " "; ?>">
                            </div>
                            <div class="col">
                                <label class="form-label" for="status" required>User Status</label>
                                <select class="form-select" id="status" name="status">
                                    <option values="customer <?php if ($customer[0]['customer_status'] == "customer") echo "selected='selected'" ?>">customer</option>
                                    <option values="admin" <?php if ($customer[0]['customer_status'] == "admin") echo "selected='selected'" ?>>admin</option>
                                    <option values="disabled" <?php if ($customer[0]['customer_status'] == "disabled") echo "selected='selected'" ?>>disabled</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <input class="form-control" type="hidden" name="id" id="id" required value="<?php echo $customer[0]['customer_id']; ?>">



                    <button type="submit" class="col-12  btn btn-primary">Submit</button>
                </div>
            </form>
        </div>
    </div>

</body>

</html>