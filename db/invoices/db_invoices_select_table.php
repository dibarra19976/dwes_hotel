<?php

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
$sql =
  "

  SELECT `invoice_reservation_id`,`invoice_date_in`,`invoice_date_out`,`invoice_room_price`,`invoice_room_extras`, `invoice_services`,`invoice_status`, `041_fullName`(c.customer_fname, c.customer_lname) AS 'invoice_client', r.room_number AS 'invoice_room', `invoice_room_total` , `invoice_room_services_total`, `invoice_room_extras_total`, `invoice_total_days`, `invoice_subtotal` FROM `041_invoices` 
  INNER JOIN `041_rooms` AS r ON r.room_id = `invoice_room`
  INNER JOIN `041_customers` AS c ON c.customer_id = `invoice_client`
  ORDER BY invoice_reservation_id ASC
  ";

$result = mysqli_query($mysqli, $sql);
$invoices  = mysqli_fetch_all($result, MYSQLI_ASSOC);

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
        <th scope="col">Total Days</th>
        <th scope="col">Room Price (Per night)</th>
        <th scope="col">Room Total</th>
        <th scope="col">Room Extras</th>
        <th scope="col">Room Extras Total</th>
        <th scope="col">Room Services</th>
        <th scope="col">Room Services Total</th>
        <th scope="col">Invoice Status</th>
        <th scope="col">Invoice Subtotal</th>
      </tr>
    </thead>
    <tbody class="table-group-divider">

      <?php
      foreach ($invoices as $invoice) {
        echo '<tr> <th scope="row">';
        echo $invoice['invoice_reservation_id'];
        echo "</th> <td>";
        echo $invoice['invoice_room'];
        echo "</td> <td>";
        echo $invoice["invoice_client"];
        echo "</td> <td>";
        echo $invoice['invoice_date_in'];
        echo "</td> <td>";
        echo $invoice['invoice_date_out'];
        echo "</td> <td>";
        echo $invoice['invoice_total_days'];
        echo "</td> <td>";
        echo $invoice['invoice_room_price'];
        echo "</td> <td>";
        echo $invoice['invoice_room_total'];
        echo "</td> <td>";
        $decode = json_decode($invoice['invoice_room_extras']);
        echo "<table class='table table-borderless table-hover '>";
        foreach ($decode as $key => $value) {
          echo "<tr> <td>" . $key . "</td> <td>" . $value[0] . "</td> </tr>";
        }
        echo "</table>";        
        echo "</td> <td>";
        echo $invoice['invoice_room_extras_total'];
        echo "</td> <td>";

        $decode2 = json_decode($invoice['invoice_services']);
        
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
            echo "<table class='table  '> <tr>";
            foreach( $value2 as $key3 => $value3) {
              echo "<td class='hover-cell'>". $value3 ."</td>" ;
            }            
            echo "</tr></table>";
            echo "</td> ";
          }
          echo "  </tr> ";
        }                
        echo "</table>";
        echo "</td> <td>";
        echo $invoice['invoice_room_services_total'];
        echo "</td> <td>";
        echo $invoice['invoice_status'];
        echo "</td> <td>";
        echo $invoice['invoice_subtotal'];
        echo "</td>";
      }

      ?>
    <tbody>
  </table>
</div>