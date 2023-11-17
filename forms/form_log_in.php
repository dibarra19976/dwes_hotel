<?php
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log In</title>

</head>

<body>
    <?php include("../header.php") ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content">
            <h1>Log In</h1>
            <form class="row align-items-start" action="../db/db_log_in.php" method="POST">
                <div class="mb-3 col">
                    <label for="email" class="form-label">Email</label>
                    <input type="text" class="form-control" name="email" placeholder="example@domain.com">
                </div>
                <div class="mb-3 col">
                    <label for="email" class="form-label">Password</label>
                    <input type="password" class="form-control" name="password">
                </div>
                <a href="">Have you forgotten your password?</a>
                <button type="submit" class=" btn btn-primary">Submit</button>
        </div>
        </form>
    </div>
    </div>

</body>

</html>