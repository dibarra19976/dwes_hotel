<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Insert customer</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"].'/student041/dwes/header.php')  ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  " >
        <div class="float-content">
        <h1>Insert customer</h1>
        <form class="row align-items-start" action="/student041/dwes/db/customers/db_customers_insert.php" method="POST">
            
            <div class="mb-3 col-12">
                <div class="row">
                    <div class="col">
                        <label class="form-label" for="name">Name</label>
                        <input class="form-control" type="text" name="name" id="name" required>
                    </div>
                    <div class="col">
                        <label class="form-label" for="name">Last name</label>
                        <input class="form-control" type="text" name="lname" id="lname" required>
                    </div>
                </div>
            </div>
            <div class="mb-3 col-12">
                <div class="row">
                    <div class="col">
                        <label class="form-label" for="dni">DNI</label>
                        <input class="form-control" type="text" name="dni" id="dni" required>
                    </div>
                    <div class="col">
                        <label class="form-label" for="birthdate">Date of birth</label>
                        <input class="form-control" type="date" name="birthdate" id="birthdate" required>
                    </div>
                </div>
            </div>
            <div class="mb-3 col-12">
                <div class="row">
                    <div class="col">
                        <label class="form-label" for="email">Email</label>
                        <input class="form-control" type="text" name="email" id="email" required>
                    </div>
                    <div class="col">
                    <label class="form-label" for="password">Password</label>
                        <input class="form-control" type="password" name="password" id="password" required>
                    </div>
                </div>
                <div class="mb-3 col-12">
                <div class="row">
                    <div class="col">
                        <label class="form-label" for="number">Phone Number</label>
                        <input class="form-control" type="text" name="number" id="number" required>
                    </div>
                    <div class="col">
                            <label class="form-label" for="status" required>User Status</label>
                            <select class="form-select" id="status" name="status">
                                <option values="customer">customer</option>
                                <option values="admin">admin</option>
                                <option values="disabled">disabled</option>
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