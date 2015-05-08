<?php
// include all the init stuff
include 'config.php';
include 'opendb.php';

// select the products
$query = "SELECT distinct Product from tests order by Product";
$products = mysql_query($query);
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
  <title>SIT Test Results Database</title>
</head>
<body>
<div style="text-align: left;">
<br>
<h2>SIT Test Results Database</h2>
</div>
<div style="text-align: left;"><span
 style="font-weight: bold;">Please choose the release:</span></div>
</div>
<table style="text-align: left; width: 384px; height: 132px;"
 border="1" cellpadding="0" cellspacing="0">
  <tbody>
    <tr>
      <td style="width: 374px;">

<?php
// loop through the results and list the products
while (list($product) = mysql_fetch_row($products))
{
  echo "<!-- $product -->\n";
?>

<b><?=$product;?>:</b><br>

<?php
  // for each of the product, get the major versions
  $query = "SELECT distinct MajorVersion from tests where Product = '$product' order by MajorVersion";
  $versions = mysql_query($query);

  // index numbers...
  $num = 0;

  // loop through the results and print the versions
  while (list($version) = mysql_fetch_row($versions))
  {
    $num++;
    echo "<!-- $num. $version -->\n";
?>
      <table style="text-align: left; width: 100%;" border="0" cellpadding="2" cellspacing="0">
        <tbody>
          <tr>
            <td style="width: 25px;"></td>
            <td style="width: 25px;" align="undefined" valign="undefined"><?=$num;?>.</td>
            <td style="width: 300px;"><a href="listResults.php?prod=<?=$product;?>&ver=<?=$version;?>&type=All"><?=$version;?></a></td>
          </tr>
        </tbody>
      </table>
<?php
  } // end of version loop
?>
      <br>
<?php
} // end of product loop
?>

      </td>
    </tr>
  </tbody>
</table>


<?php
// cleanup/close all the connections
include 'closedb.php';
?>

</body>
</html>

