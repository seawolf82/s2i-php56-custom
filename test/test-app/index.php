<html>
 <head>
  <title>Test PHP</title>
 </head>
 <body>
 <?php
   //echo phpinfo();
   error_reporting(-1);
   ini_set('display_errors', 'On');
   //echo "test";
   $conn=oci_connect("stage","stage","192.168.3.81:1521/xe");
   if (!$conn) {
    $e = oci_error();
    echo $e['message'].' ciao';
    print_r($e);
    echo "test2";
    }
   $query=oci_parse($conn,"select * from anagrafica");
   oci_execute($query);
   while($row=oci_fetch_array($query)){
   print_r($row);
   }
oci_close($conn);
 ?>
 </body>
</html>

