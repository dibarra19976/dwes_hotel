<?php

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select customers</title>
    <link rel="stylesheet" href="../css/style.css">

</head>

<body>
    <?php include($_SERVER["DOCUMENT_ROOT"] . '/student041/dwes/header.php')  ?>
    <div class="container-fluid content">
        <div>
            <h1 class="white ">Weather.
            </h1>

        </div>
        <div id="demo"></div>
    </div>

    <script>
        let apikey = "Jf8GXnTKOKPxT35yD8RHA8MvgubaE26G";
        let locale = "madrid";

        // console.log(getlocation(apikey, locale));

        function getlocation(apikey, location) {
            const xhttp = new XMLHttpRequest();
            xhttp.onload = function() {
                document.getElementById("demo").innerHTML =
                    this.responseText;
                    let json = JSON.parse(this.responseText);
                    let code = json[0]["Key"];
                    
                    callback(code);
            }
            xhttp.open("GET", "http://dataservice.accuweather.com/locations/v1/cities/search?apikey=" + apikey + "&q=" + location, true);
            xhttp.send();

        }
    </script>
</body>

</html>