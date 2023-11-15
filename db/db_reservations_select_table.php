<?php

include("../db/db_connection.php");
$sql =
  "

  SELECT `reservation_id`,`reservation_date_in`,`reservation_date_out`,`reservation_room_price`,`reservation_room_extras`, `reservation_services`,`reservation_status`, `041_fullName`(c.customer_fname, c.customer_lname) AS 'reservation_client', r.room_number AS 'reservation_room' FROM `041_reservations` 
  INNER JOIN `041_rooms` AS r ON r.room_id = `reservation_room`
  INNER JOIN `041_customers` AS c ON c.customer_id = `reservation_client`;
  ";

$result = mysqli_query($mysqli, $sql);
$reservations  = mysqli_fetch_all($result, MYSQLI_ASSOC);

$i = 1;

?>

<div class="table-responsive">
  <table class="table table-responsive table-hover h-100 table-border">
    <thead>
      <tr>
        <th scope="col">ID</th>
        <th scope="col">Room</th>
        <th scope="col">Client</th>
        <th scope="col">Date IN</th>
        <th scope="col">Date OUT</th>
        <th scope="col">Room Price (Per night)</th>
        <th scope="col">Room Extras</th>
        <th scope="col">Room Services</th>
        <th scope="col">Reservation Status</th>
        <th scope="col">Quick Actions</th>
      </tr>
    </thead>
    <tbody class="table-group-divider">

      <?php
      foreach ($reservations as $reservation) {
        echo '<tr> <th scope="row">';
        echo $reservation['reservation_id'];
        echo "</th> <td>";
        echo $reservation['reservation_room'];
        echo "</td> <td>";
        echo $reservation["reservation_client"];
        echo "</td> <td>";
        echo $reservation['reservation_date_in'];
        echo "</td> <td>";
        echo $reservation['reservation_date_out'];
        echo "</td> <td>";
        echo $reservation['reservation_room_price'];
        echo "</td> <td>";

        $decode = json_decode($reservation['reservation_room_extras']);
        echo "<table class='table table-borderless table-hover '>";
        foreach ($decode as $key => $value) {
          echo "<tr> <td>" . $key . "</td> <td>" . $value[0] . "</td> </tr>";
        }
        echo "</table>";        
        echo "</td> <td>";

        $decode2 = json_decode($reservation['reservation_services']);
        
        echo "<table class='table table-borderless table-hover '>";
        echo '<tr>  <th scope="col"></th>
        <th scope="col">bar</th>
        <th scope="col">dvdRenting</th>
        <th scope="col">gym </th>
        <th scope="col">spa </th>
        </tr>   ';
        foreach ($decode2 as $key => $value) {
          echo "<tr> 
          <td>" . $key . "</td>";
          
          foreach ($value as $key2 => $value2) {
            echo " <td>";
            echo "<table class='table table-hover '> <tr>";
            foreach( $value2 as $key3 => $value3) {
              echo "<td>". $value3 ."</td>" ;
            }            
            echo "</tr></table>";
            echo "</td> ";
          }
          echo "  </tr> ";
        }                
        echo "</table>";
  
        // print_r($decode2);
        // 
        // foreach ($decode2 as $key => $value) {
        //   echo "<tr> <td>" . $key . "</td> <td>" . $value[0] . "</td> </tr>";
        // }

        echo "</>";     
        echo "</td> <td>";
        echo $reservation['reservation_status'];
        echo "</td> <td>";


      ?>
       <div class="d-flex text-center  flex-column ">
       <form action="../forms/form_rooms_update.php" method="POST">
          <input type="text" name="room_id" id="room_id" value="<?php echo $room['room_id']; ?>" hidden>
          <button class="btn btn-primary">Update</button>
        </form>
        <form action="../forms/form_rooms_delete.php" method="POST">
          <input type="text" name="room_id" id="room_id" value="<?php echo $room['room_id']; ?>" hidden>
          <button class="btn btn-secondary">Delete</button>
        </form>
       </div>
      <?php
        echo "</td>";
      }

      ?>
    <tbody>
  </table>
</div>