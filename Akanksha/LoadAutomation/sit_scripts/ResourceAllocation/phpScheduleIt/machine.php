<?php
/**
* @author Nabanita Dutta
* GL Change:This script creates the page for machine details 
* for a particular resources.
* @version 08-08-06
* @package phpScheduleIt
*
* Copyright (C) 2003 - 2007 phpScheduleIt
* License: GPL, see LICENSE
*/

include_once('lib/db/ResDB.class.php');
include_once('lib/Resource.class.php');
include_once('lib/Template.class.php');
include_once('lib/helpers/ReservationHelper.class.php');
include_once('lib/Utility.class.php');

$timer = new Timer();
$timer->start();

$t = new Template();

    $t->printHTMLHeader();
    $t->startMain();
    
    $machid =  trim($_GET['machid']);
    $db = new ResDB();
    $rs = $db->get_machine_data($machid);
    $priString = "<table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"1\" align=\"center\">\n";
    $priString .=  "<tr>\n";
    $priString .= "<td class=\"tableBorder\">\n";
    $priString .= "<table width=\"100%\" border=\"0\" cellspacing=\"1\" cellpadding=\"0\">\n";
    $priString .= "<tr class=\"rowHeaders\">\n";
    $priString .= "<td width=\"10%\">Sl. No.</td>\n";
    $priString .= "<td width=\"10%\">Name</td>\n";
    $priString .= "<td width=\"20%\">Management IP</td>\n";
    $priString .= "<td width=\"19%\">Machine Type</td>\n";
    $priString .= "<td width=\"20%\">Media Card</td>\n";
    $priString .= "</tr>\n";
    for ($i = 0; $i < count($rs); $i++) {
        $priString .= "<tr class=\"cellColor" . ($i%2) . "\" align=\"center\">\n";
        $priString .= "<td>" . ($i+1) . "</td>\n";
        $priString .= "<td>" . $rs[$i]['machinename'] . "</td>\n";
        $priString .= "<td style=\"text-align:centre\">" . $rs[$i]['machineip'] . "</td>\n";
        $priString .= "<td style=\"text-align:centre\">". $rs[$i]['machinetype'] . "</td>\n";
        $priString .= "<td>".$rs[$i]['mediahwtype']."</td>\n";
        $priString .= "</tr>\n";
        }

    $priString .=  "</table>\n";
    $priString .=  "</td>\n";
    $priString .=  "</tr>\n";
    $priString .=  "</table>\n";
    print $priString;

// End main table
$t->endMain();

$timer->stop();
$timer->print_comment();

// Print HTML footer
$t->printHTMLFooter();

?>
