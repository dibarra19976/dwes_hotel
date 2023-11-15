<?php

include("../db/db_connection.php");
$sql =
  "
SELECT * FROM rooms; 
";


$result = mysqli_query($mysqli, $sql);
$rooms  = mysqli_fetch_all($result, MYSQLI_ASSOC);
$i = 1;

include("../db/db_room_type_select.php");

?>

<div class="table-responsive">
  <table class="table table-responsive table-hover h-100 table-border">
    <thead>
      <tr>
        <th scope="col">ID</th>
        <th scope="col">Room Number</th>
        <th scope="col">Available Extras</th>
        <th scope="col">Room Type</th>
        <th scope="col">Room Status</th>
        <th scope="col">Quick Actions</th>
      </tr>
    </thead>
    <tbody class="table-group-divider">

      <?php
      foreach ($rooms as $room) {
        echo '<tr> <th scope="row">';
        echo $room['room_id'];
        echo "</th> <td>";
        echo $room['room_number'];
        echo "</td> <td>";

        $decode = json_decode($room['room_available_extras']);
        echo "<table class='table table-borderless table-hover '>";
        foreach ($decode as $key => $value) {
          echo "<tr> <td>" . $key . "</td> <td>" . $value[0] . "</td> </tr>";
        }
        echo "</table>";

        echo "</td> <td>";
        echo $room['room_type'];
        echo " (", $room_types[$room['room_type'] - 1]['type_name'], ")";
        echo "</td> <td>";
        echo $room['room_status'];
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