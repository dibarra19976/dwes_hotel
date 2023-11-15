<?php
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>

</head>

<body>
    <?php include("../header.php") ?>
    <div class="container content">
        <form class="row align-items-start" action="../db/db_log_in.php" method="POST">
            <div class="mb-3 col">
                <label for="email" class="form-label">Email</label>
                <input type="email" class="form-control" name="email" placeholder="example@domain.com">
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

</body>

</html>