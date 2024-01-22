<?php

include($_SERVER["DOCUMENT_ROOT"]."/student041/dwes/db/connection/db_connection.php");
$sql_query =
  "
SELECT * FROM 041_customers WHERE !( customer_status = 'disabled'); 
";


$result = mysqli_query($mysqli, $sql_query);
$customers  = mysqli_fetch_all($result, MYSQLI_ASSOC);
$i = 1;
?>

<div class="table-responsive">
  <table class="table table-responsive table-hover h-100 table-border">
    <thead>
      <tr>
        <th scope="col">ID</th>
        <th scope="col">First Name</th>
        <th scope="col">Last Name</th>
        <th scope="col">Birthdate</th>
        <th scope="col">Email</th>
        <th scope="col">Password</th>
        <th scope="col">DNI</th>
        <th scope="col">Phone</th>
        <th scope="col">Status</th>
        <th scope="col">Quick Actions</th>
      </tr>
    </thead>
    <tbody class="table-group-divider ">

      <?php
      foreach ($customers as $customer) {
        echo '<tr> <th scope="row">';
        echo $customer['customer_id'];
        echo "</th> <td>";
        echo $customer['customer_fname'];
        echo "</td> <td>";
        echo $customer['customer_lname'];
        echo "</td> <td>";
        echo $customer['customer_birthdate'];
        echo "</td> <td>";
        echo $customer['customer_email'];
        echo "</td> <td>";
        echo $customer['customer_password'];
        echo "</td> <td>";
        echo $customer['customer_dni'];
        echo "</td> <td>";
        echo $customer['customer_phone'];
        echo "</td> <td>";
        echo $customer['customer_status'];
        echo "</td> <td>";
      ?>
       <div class="d-flex text-center  flex-column align-items-center justify-content-center ">
        <form action="/student041/dwes/forms/customers/form_customers_update.php" method="POST">
          <input type="text" name="customer_id" id="customer_id" value="<?php echo $customer['customer_id']; ?>" hidden>
          <button class="btn btn-primary m-3"><i class="bi bi-arrow-clockwise"></i>Update</button>
        </form>
        <form action="/student041/dwes/forms/customers/form_customers_delete.php" method="POST">
          <input type="text" name="customer_id" id="customer_id" value="<?php echo $customer['customer_id']; ?>" hidden>
          <button class="btn btn-secondary"><i class="bi bi-trash-fill"></i>Delete</button>
        </form>
        </div>
      <?php
        echo "</td>";
      }

      ?>
    <tbody>
  </table>
</div>