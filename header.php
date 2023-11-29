<?php
session_start();
?>

<!doctype html>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="/student041/dwes/css/style.css">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
</head>

<body>
  <!-- NAVBAR -->
  <nav class="navbar navbar-expand-lg bg-body-tertiary fixed-top">
    <div class="container-fluid">
      <a class="navbar-brand" href="#">
        <img src="/student041/dwes/img/temp_logo.png" alt="Bootstrap" width="50" height="50">
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarSupportedContent">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li class="nav-item">
            <a class="nav-link" aria-current="page" href="/student041/dwes/index.php">Home</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/student041/dwes/forms/form_reservations_client.php">Reservations</a>
          </li>

          <?php
          if (!isset($_SESSION["login_id"])) {
          ?>
            <li class="nav-item">
              <a href="/student041/dwes/forms/login/form_log_in.php"><button class="btn btn-primary">Log In</button></a>
              <a href="/student041/dwes/forms/login/form_log_in.php"><button class="btn btn-secondary">Register</button></a>
            </li> <?php
                } else {
                  ?>
            <li class="nav-item">
              <a href="/student041/dwes/forms/login/form_log_out.php"><button class="btn btn-primary">Log Out</button></a>
            </li> <?php
                }
                  ?>

        </ul>

        <?php

        if (isset($_SESSION["login_id"])) {
          if ($_SESSION["login_status"] == "admin") {

        ?>

            <hr>
            <ul class="navbar-nav ml-auto mb-2 mb-lg-0">
              <li class="nav-item dropstart">
                <a class="nav-link " href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                  Customers
                </a>
                <ul class="dropdown-menu">
                  <li><a class="dropdown-item" href="/student041/dwes/forms/customers/form_customers_select.php">Select Customer</a></li>
                  <li><a class="dropdown-item" href="/student041/dwes/forms/customers/form_customers_insert.php">Insert Customer</a></li>
                  <li><a class="dropdown-item" href="/student041/dwes/forms/customers/form_customers_update_call.php">Update Customer</a></li>
                  <li><a class="dropdown-item" href="/student041/dwes/forms/customers/form_customers_delete_call.php">Delete Customer</a></li>
                </ul>
              </li>
              <li class="nav-item dropstart">
                <a class="nav-link " href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                  Rooms
                </a>
                <ul class="dropdown-menu">
                  <li><a class="dropdown-item" href="/student041/dwes/forms/rooms/form_rooms_select.php">Select Rooms</a></li>
                  <li><a class="dropdown-item" href="/student041/dwes/forms/rooms/form_rooms_insert.php">Insert Rooms</a></li>
                  <li><a class="dropdown-item" href="/student041/dwes/forms/rooms/form_rooms_update_call.php">Update Rooms</a></li>
                  <li><a class="dropdown-item" href="/student041/dwes/forms/rooms/form_rooms_delete_call.php">Delete Rooms</a></li>
                </ul>
              </li>
              <li class="nav-item dropstart">
                <a class="nav-link " href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                  Reservations
                </a>
                <ul class="dropdown-menu">
                  <li><a class="dropdown-item" href="/student041/dwes/forms/reservations/form_reservations_select.php">Select Reservation</a></li>
                  <li><a class="dropdown-item" href="/student041/dwes/forms/reservations/form_reservations_insert.php">Insert Reservation</a></li>
                  <li><a class="dropdown-item" href="/student041/dwes/forms/reservations/form_reservations_update_call.php">Update Reservation</a></li>
                  <li><a class="dropdown-item" href="/student041/dwes/forms/rooms/form_rooms_select.php">Delete Reservation</a></li>
                </ul>
              </li>
              <li class="nav-item dropstart">
                <a class="nav-link " href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                  Invoices
                </a>
                <ul class="dropdown-menu">
                  <li><a class="dropdown-item" href="#">Select Invoices</a></li>
                  <li><a class="dropdown-item" href="#">Insert Invoice</a></li>
                  <li><a class="dropdown-item" href="#">Update Invoice</a></li>

                </ul>
              </li>
              <li class="nav-item">
                <a class="nav-link" aria-current="page" href="#">Services</a>
              </li>
            </ul>
        <?php
          }
        }
        ?>
        <h5 class="navbar-nav ml-auto mb-2 mb-lg-0 d-none d-lg-block d-xl-block d-xxl-block mw-5">
          Welcome, <?php
                    $name =  ($_SESSION['login_fname'] ?? "Guest ") . " " . ($_SESSION['login_lname'] ?? "");
                    echo $name;
                    ?>
        </h5>
      </div>
    </div>
  </nav>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
</body>

</html>