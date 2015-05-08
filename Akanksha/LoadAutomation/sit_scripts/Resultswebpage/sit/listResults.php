<?php
include 'config.php';
include 'opendb.php';

// retrieve the product, major version and test type passed through the URL
$product = $_GET['prod'];
$majVer = $_GET['ver'];
$testType = $_GET['type'];

// filter to use in the SQL
$typeFilter = "AND TestType = '$testType'";

// set the intial selection for the test type selection box
if (strcmp($testType, "Basic") == 0)
{
  $basicSelected = 'selected="selected"';
} elseif (strcmp($testType, "Full") == 0)
{
  $fullSelected = 'selected="selected"';
} elseif (strcmp($testType, "Load") == 0)
{
  $loadSelected = 'selected="selected"';
} elseif (strcmp($testType, "Nightly") == 0)
{
  $nightlySelected = 'selected="selected"';
} else
{
  $allSelected = 'selected="selected"';
  $typeFilter = "";
}

// retrieve the last 50 test results ordered by most recent tests
$query = "SELECT Id, TestStart, TestEnd, SUTVersion, TestStatus, TestType, NumTests, NumPass, SystemHW, MediaHW, DetailsKey, NextestVersion, Contact, Comments from tests where MajorVersion = '$majVer' AND Product = '$product'" . $typeFilter . " order by TestStart desc limit 50";
$results = mysql_query($query);
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
  <title>SIT Test Results History</title>
</head>
<body>
<a href="/index.html">Home</a> | <a href="/sit/">Back</a> | <a href="/phpmyadmin/" title="Open in new window" target="_blank">phpMyAdmin</a>
<h2>History of <?=$testType;?> Test Results for <?=$product;?> <?=$majVer;?>:</h2>
<br>
<form method="GET" name="form1" action="listResults.php">
Show Tests: 
<select size="1" name="type" onchange="form1.submit()">
  <option value="All" <?=$allSelected;?>>All</option>
  <option value="Basic" <?=$basicSelected;?>>Basic</option>
  <option value="Full" <?=$fullSelected;?>>Full</option>
  <option value="Load" <?=$loadSelected;?>>Load</option>
  <option value="Nightly" <?=$nightlySelected;?>>Nightly</option>
</select>
<input type="hidden" name="prod" value="<?=$product;?>">
<input type="hidden" name="ver" value="<?=$majVer;?>">
</form>

<table style="text-align: left; margin-left: 0px;" border="1" cellpadding="2" cellspacing="0">
  <tbody>
    <tr>
      <th style="width: 30px;"><b>#</b></th>
      <th style="width: 120px;" align="undefined" valign="undefined"><b>Test Start</b></th>
      <th style="width: 120px;" align="undefined" valign="undefined"><b>Test End</b></th>
      <th style="width: 80px;" align="undefined" valign="undefined"><b>Version</b></th>
      <th style="width: 50px;" align="undefined" valign="undefined"><b>Type</b></th>
      <th style="width: 80px;" align="undefined" valign="undefined"><b>Status</b></th>
      <th style="width: 50px;" align="undefined" valign="undefined"><b>Total</b></th>
      <th style="width: 50px;" align="undefined" valign="undefined"><b>Pass</b></th>
      <th style="width: 50px;" align="undefined" valign="undefined"><b>Fail</b></th>
      <th style="width: 40px;" align="undefined" valign="undefined"><b>%</b></th>
      <th style="width: 60px;" align="undefined" valign="undefined"><b>Difference from the last run</b></th>
      <th style="width: 150px;" align="undefined" valign="undefined"><b>Details</b></th>
      <th style="width: 100px;" align="undefined" valign="undefined"><b>Test Setup</b></th>
      <!--adding a new column: Comments, contact name will also be shown in this field -->
      <th style="width: 100px;" align="undefined" valign="undefined"><b>Contact</b></th>
    </tr>
<?php
$num = 0;
while (list($id, $start, $end, $version, $status, $type, $total, $pass, $hw, $media, $detailKey, $nexversion, $contact, $comment) = mysql_fetch_row($results))
{
  $num++;

  // calculate failures and percentage
  $fail = $total-$pass;
  $per = number_format(($pass/$total)*100, 2, '.', '');

  // color the status...
  $statusColor = "";
  if (strcmp($status, "Pass") == 0)
  {
    $statusColor = $GreenColor;
  } elseif (strcmp($status, "Fail") == 0)
  {
    $statusColor = $RedColor;
  }

//commenting the code of calculation of new failures 
/*
  // calculate number of failures since last run
  // get the most recent completed results for the same product/major version/test type/nextest version/system hw/media hw
  $query = "SELECT NumPass from tests where TestStatus != 'In Progress' AND TestStart < '$start' AND Product = '$product' AND MajorVersion = '$majVer' AND TestType = '$type' AND SystemHW = '$hw' AND MediaHW = '$media' AND NextestVersion = '$nexversion' order by TestEnd desc limit 1";
  $prevtest = mysql_query($query);
*/
  
  $newFailures = "N/A";

//commenting the code of calculation of new failures   
/*
  $failureCountColor = "";
  if (list($prevPass) = mysql_fetch_row($prevtest))
  {
    // only report this if our last test run had an equal or higher pass count
    if ($prevPass >= $pass)
    {
      $newFailures = $prevPass - $pass;
    } 
    if ($newFailures > 0)
    {
      // color the failure count...
      $failureCountColor = $RedColor;
    }
  }
*/

  // create the details URL
  $query = "SELECT DisplayString, RelativePath from details where Details = '$detailKey'";
  $details = mysql_query($query);
  $detailsUrl = '';
  while (list($display, $path) = mysql_fetch_row($details))
  {
    $detailsUrl .= "<a href=\"$dataURL$path\">$display</a><br>";
  }
  $detailsUrl = substr($detailsUrl, 0, strlen($detailsUrl)-4);

  // prepend the comments text to the details
//  $detailsUrl = $comment . "<br>" . $detailsUrl;

  // create the test setup URL
  $testSetup = "$hw";
  if (strcmp($media, "N/A") != 0)
  {
    $testSetup .= "<br>$media";
  }
  $testSetup .= "<br>$nexversion";
  
  //Contact name will be shown in Comments column
  $comments = "$contact";


  // create a background color for the row
  if ($num%2 == 0)
  {
    $cellBackground = $BlueBackground;
  } else {
    $cellBackground = "";
  }

?>
    <tr>
      <td style="width: 30px; <?=$cellBackground;?>"><?=$id;?></td>
      <td style="width: 120px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$start;?></td>
      <td style="width: 120px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$end;?></td>
      <td style="width: 80px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$version;?></td>
      <td style="width: 50px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$type;?></td>
      <td style="width: 80px; <?=$cellBackground;?> <?=$statusColor;?>" align="undefined" valign="undefined"><?=$status;?></td>
      <td style="width: 50px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$total;?></td>
      <td style="width: 50px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$pass;?></td>
      <td style="width: 50px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$fail;?></td>
      <td style="width: 40px; <?=$cellBackground;?> <?=$statusColor;?>" align="undefined" valign="undefined"><?=$per;?>%</td>
      <td style="width: 60px; <?=$cellBackground;?> <?=$failureCountColor;?>" align="undefined" valign="undefined"><a href="newPage.php"><?=$newFailures;?></a></td>
      <td style="width: 150px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$detailsUrl;?></td>
      <td style="width: 100px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$testSetup;?></td>
      <!--adding new column Comments value -->
      <td style="width: 100px; <?=$cellBackground;?>" align="undefined" valign="undefined"><?=$comments;?></td>
    </tr>
<?php
}
?>
  </tbody>
</table>
<br>
<?php
include 'closedb.php';
?>
</body>
</html>
