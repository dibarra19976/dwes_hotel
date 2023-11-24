<?php
if($_SERVER["REQUEST_METHOD"] == "POST"){
    echo "das";
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>

<body>
    <?php //include("../../header.php") ?>
    <div class="container vh-100 d-flex flex-column align-items-center justify-content-center  ">
        <div class="float-content">
            <h1>Image test</h1>
            <div class="row">
                <form class="row align-items-start" action="" method="POST" enctype="multipart/form-data">
                    <label for="formFile" class="form-label">File input</label>
                    <input class="form-control" type="file" id="formFile">
                    <button type="submit" class=" btn btn-primary m-3">Submit</button>
            </div>
            </form>
        </div>
    </div>
</body>

</html>