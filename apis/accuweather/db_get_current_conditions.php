<?php
    $weather_info = "http://dataservice.accuweather.com/currentconditions/v1/3544090/?apikey=Jf8GXnTKOKPxT35yD8RHA8MvgubaE26G&details=true";
    
    echo $weather_info;
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
        let locale = "3544090";
        // 3544090
        // getlocation(apikey, locale);

        function getlocation(apikey, location) {
            const xhttp = new XMLHttpRequest();
            xhttp.onload = function() {
                document.getElementById("demo").innerHTML =
                    this.responseText;
                    let json = JSON.parse(this.responseText);
                    console.log(this.responseText);
                    
            }
            xhttp.open("GET", "http://dataservice.accuweather.com/currentconditions/v1/"+ location +"/?apikey=" + apikey, true);
            xhttp.send();

        }

        function saveToFile(json){
            
        }
    </script>
</body>

</html>