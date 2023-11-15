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
    <?php include("./header.php") ?>

    <div class="container-fluid vh-100 content w-100 " >

        <div class="row h-50 banner">
            <div class="col-xl-4 col-lg-4 col-sm-12 h-100 p-0">
                <div id="carouselExample" class="carousel slide h-100">
                    <div class="carousel-inner h-100" >
                        <div class="carousel-item active h-100 w-100">
                            <img src="./img/placeholders/ex1.webp" class="d-block object-fit-cover  w-100 h-100" alt="...">
                        </div>
                        <div class="carousel-item active h-100 w-100">
                            <img src="./img/placeholders/ex3.webp" class="d-block object-fit-cover  h-100 w-100" alt="...">
                        </div>
                        <div class="carousel-item active h-100 w-100">
                            <img src="./img/placeholders/ex2.jpg" class="d-block object-fit-cover h-100 w-100" alt="...">
                        </div>
                    </div>
                    <button class="carousel-control-prev" type="button" data-bs-target="#carouselExample" data-bs-slide="prev" >
                        <span class="carousel-control-prev-icon" aria-hidden="true" ></span>
                        <span class="visually-hidden">Previous</span>
                    </button>
                    <button class="carousel-control-next" type="button" data-bs-target="#carouselExample" data-bs-slide="next">
                        <span class="carousel-control-next-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">Next</span>
                    </button>
                </div>
            </div>
            <div class="col banner">
                <h1>Lorem, ipsum dolor sit amet consectetur adipisicing elit. Hic, illo.</h1>
                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Sapiente dolorem saepe ipsa fugit culpa adipisci harum, reprehenderit dolor odit velit maiores, necessitatibus quia dict   a, minima consequuntur accusamus perferendis asperiores pariatur? </p>
            </div>
        </div>
    </div>

    <!-- <div class="container">
        <form class="row align-items-start" action="db/db_rooms_select_availability.php" method="POST">
            <div class="mb-3 col">
                <label for="date_in" class="form-label">Check in</label>
                <input type="date" class="form-control" name="date_in">
            </div>
            <div class="mb-3 col">
                <label for="date_out" class="form-label">Check out</label>
                <input type="date" class="form-control" name="date_out">
            </div>
            <div class="mb-3 col-12">
                <label for="room_type" class="form-label">Room type</label>
                <div class="row">
                    <div class="form-check col">
                        <input class="form-check-input" type="radio" name="room_type" id="room1" value="1">
                        <label class="form-check-label" for="room1">
                        Single Room (1)	
                        </label>
                    </div>
                    <div class="form-check col">
                        <input class="form-check-input" type="radio" name="room_type" id="room2" value="2">
                        <label class="form-check-label" for="room2">
                        Double Room (2)
                        </label>
                    </div>
                    <div class="form-check col">
                        <input class="form-check-input" type="radio" name="room_type" id="room3" value="3">
                        <label class="form-check-label" for="room3">
                        Suite (3)
                        </label>
                    </div>
                    <div class="form-check col">
                        <input class="form-check-input" type="radio" name="room_type" id="room4" value="4">
                        <label class="form-check-label" for="room4">
                        Family Room (4)
                        </label>
                    </div>
                    <div class="form-check col">
                        <input class="form-check-input " type="radio" name="room_type" id="room5" value="5">
                        <label class="form-check-label" for="room5">
                        Executive Suite (5)
                        </label>
                    </div>
                </div>
            </div>
            <button type="submit" class=" btn btn-primary">Submit</button>
    </div>
    </form>
    </div> -->

</body>

</html>