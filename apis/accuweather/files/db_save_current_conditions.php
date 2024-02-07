
<?php

$file = `current_conditions $date("Y-m-d").txt`;

$content = $_GET["json"];

file_put_contents($file, $content);
?>
