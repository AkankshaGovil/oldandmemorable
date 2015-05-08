// 	0 = MAIL, 1 = LOG, 2 = NONE
	actarr = new Array("MAIL", "LOG", "NONE");

//	0 = TO, 1 = SUBJ, 2 = CC, 3 = BCC, 4 = ""
	optarr = new Array(3);
	optarr[0] = new Array("TO", "SUBJ", "CC", "BCC", "");
	optarr[1] = new Array("FILE", "", "", "", "");
	optarr[2] = new Array("","","","","");

//	for (i=0; i<3; i++) {
//		str = "row "+i+":";
//		for (j=0; j<5; j++) {
//			str += "   " + actarr[i][j];
//		}
//		document.write(str + "<p>");	
//	}

//	function findindex(x) {
//		var i;
//		for (i=0; i<3; i++) {
//			if (actarr[i] == x) {
//				return(i);
//			}
//		}
//		return(i-1);
//	}

//
//	optvalform:: print a form for the optional values
//
	function optvalform()
	{
	
	x = parent.rtop.document.Form1.ACTION.options[parent.rtop.document.Form1.ACTION.options.selectedIndex].value;
//	alert("This is another test! argument is " + x);

	if (x == "NONE") {
		return;
	}
	
	optwin = window.open("","" + x, "toolbar=0, menubar=0, resizable=1, location=0, width=300, height=250");	
	opthdr = " <html> \n";
	opthdr += " <head><title> Optional settings \n";
	opthdr += " </title></head> \n";
//	opthdr += " <base href=\"http://204.180.228.69\"> \n";
	opthdr += " <body> \n";
//        opthdr += " <script language="javascript"> alert('The action is ' +x); </script> \n";
	opthdr += " <script src='options.js'> ";
	opthdr += " document.write(\" Included .js file not found \"); ";
	opthdr += " alert('This is another test! - '" + x + "); ";
	opthdr += " </script> \n";
	opthdr += " <center><H4>" + x + " " + "Options" + "</H4></center>\n";
//	opthdr += ' <form action="" method="post" name="optfields" onsubmit="readoptvals(\"' +x +'\")"> \n';
	opthdr += ' <form action="" method="post" name="optfields" onsubmit="readoptvals()"> \n';

	optform = optional_fields(x);
	optform += ' <p><input type="submit" value="Submit" name="OB1"> \n';
	optform += ' <input type="reset" value="Reset" name="OB2"></p> \n';

	optftr = " </form> \n";
	optftr += " </body> \n";
	optftr += " </html> \n";


	optwin.document.write(opthdr, optform, optftr);
	//document.form.T3.value="ptyagi@nextone.com";
	//alert("value of document.form.T3.value = " + document.form.T3.value);
	}

//
//	readoptvals:: read the optional values and store them in variables of the main form
//
	function readoptvals()
	{
	aform = this.document.optfields;
//	alert("Entered readoptvals");
//	if (action == "MAIL") {
//		alert(" Submitting a MAIL form");
		opener.Form1.MAIL_TO.value = aform.MAIL_TO.value;
		opener.Form1.MAIL_SUBJ.value = aform.MAIL_SUBJ.value;
		opener.Form1.MAIL_CC.value = aform.MAIL_CC.value;
		opener.Form1.MAIL_BCC.value = aform.MAIL_BCC.value;
//		alert(" Submitted a MAIL form");
//	}
//	if (action == "LOG") {
//		alert(" Submitting a LOG form");
		opener.Form1.LOG_FILE.value = aform.LOG_FILE.value;
//		alert(" Submitted a LOG form");
//	}
//	alert("ID:" + aform[0].value + " To: " + aform[1].value + " Subject: " + aform[2].value);
	window.close(this);
	}

//
//	AskIt:: Ask a question - using prompt
//
	function AskIt() {
		Response = "";
		while ((Response == "") || (Response == ""))	{
		Response=prompt ("Who are you?", "Your Address?");
		}
		if (Response != null)
		alert ("Hello, " + Response + "!"); 
	}

//
//	printtest:: print - this is a test
//		
	function printtest() {
		alert(" This is a test! ");
	}

//
// 	optional_fields:: prints the optional fields of the form
//
	function optional_fields(id) {
	var text="";
	var ind;
	
	if (id == "MAIL") {
		text += ' <input type="hidden" name="OT0" value="' + id + '"> \n';
		text += ' <p>To:&nbsp;&nbsp;&nbsp;<input type="text" name="MAIL_TO" size="23" value=""></p> \n';
		text += ' <p>Subject:&nbsp;<input type="text" name="MAIL_SUBJ" size="23" value=""></p> \n';
		text += ' <p>CC:&nbsp;<input type="text" name="MAIL_CC" size="23" value=""></p> \n';
		text += ' <p>BCC:&nbsp;<input type="text" name="MAIL_BCC" size="23" value=""></p> \n';
		text += ' <input type="hidden" name="LOG_FILE" size="23" value=""> \n';	
	}

	if (id == "NOTIFY") {
		text += ' <input type="hidden" name="OT0" value="' + id + '"> \n';
	}

	if (id == "LOG") {
		text += ' <input type="hidden" name="OT0" value="' + id + '">';
		text += ' <input type="hidden" name="MAIL_TO" size="23" value="">';
		text += ' <input type="hidden" name="MAIL_SUBJ" size="23" value="">';
		text += ' <input type="hidden" name="MAIL_CC" size="23" value="">';
		text += ' <input type="hidden" name="MAIL_BCC" size="23" value="">';
		text += ' <p>File:&nbsp;&nbsp;&nbsp;<input type="text" name="LOG_FILE" size="23" value=""></p>';
	}

	if (id == "NONE") {
		text = "";
	}
	
	return(text);
	}

	function heading(x) {
		document.write('<p><b><font FACE="verdana" color="ff0000">' + x + '</font></b></p>');
	}

	function ask_EVENT(x) {
		document.write("<td>\n");
		document.write('<b> <font FACE="arial">');
		document.write("Name:&nbsp;");
		document.write("</font></b>\n");
		document.write('<input type="text" name="EVENT" size="23" value="');
		document.write(x);
		document.write('">');
		document.write("\n</td>");
	}

	function ask_QUAL_DEF_LOG(x) {
		document.write("<td>\n");
		document.write('<b> <font FACE="arial">');
		document.write("&nbsp; Type:&nbsp;&nbsp;&nbsp;&nbsp;");
		document.write("</font></b>\n"); 
      		document.write('<select size="1" name="QUAL">');
          	document.write('<option selected value="' + "logdesc" + '">' + "Log" + "</option>");
        	document.write("</select>");
		document.write("\n</td>");
	}

	function ask_QUAL_DEF_CDR(x) {
		document.write('<td>\n');
		document.write('<b> <font FACE="arial">');
		document.write('&nbsp; Type:&nbsp;&nbsp;&nbsp;&nbsp;');
		document.write('</font></b>\n'); 
      		document.write('<select size="1" name="QUAL">');
          	document.write('<option selected value="' + "cdrdesc" + '">' + 'Cdr' + '</option>');
        	document.write('</select>');
		document.write('\n</td>');
	}

	function ask_HOST(x) {
		document.write('<td>\n');
		document.write('<b> <font FACE="arial">');
		document.write('&nbsp; Host:&nbsp;&nbsp;');
		document.write('</font></b>\n');
		document.write('<select size="1" name="HOST">');
          	document.write('<option selected value="' + x + '">' + x + '</option>');
        	document.write('</select>');
		document.write('\n</td>');
	}

	function ask_EQUALS(x) {
		document.write('<td>\n');
		document.write('<b> <font FACE="arial">');
		document.write('Event:&nbsp;&nbsp; ');
		document.write('</font></b>\n');
		document.write('<input type="text" name="EQUALS" size="23" value="');
          	document.write(x);
        	document.write('">');
		document.write("\n</td>");
	}

	function ask_ACTION() {
		document.write("<td>\n");
		document.write('<b> <font FACE="arial">');
		document.write("&nbsp; Action:&nbsp;&nbsp;");
		document.write("</font></b>\n");
		document.write('<select size="1" name="ACTION" onchange="optvalform()"> \n');
//		document.write('<select size="1" name="ACTION" onchange="getagain()">');
		document.write('<option selected value="NONE">None</option>\n');
		document.write('<option value="MAIL">Mail</option>\n');
//          	document.write('<option value="NOTIFY">Notify</option>\n');
          	document.write('<option value="LOG">Log</option>\n');	
          	document.write("</select>\n");
//		alert("this =" + document.Form1.ACTION);        
		document.write(' <input type="hidden" name="MAIL_TO" value=""> \n');
		document.write(' <input type="hidden" name="MAIL_SUBJ" value=""> \n');
		document.write(' <input type="hidden" name="MAIL_CC" value=""> \n');
		document.write(' <input type="hidden" name="MAIL_BCC" value=""> \n');
		document.write(' <input type="hidden" name="LOG_FILE" value=""> \n');
		document.write("</td>");
	}

	function getagain() {
		alert("form is " + document.Form1.ACTION.value);
		parent.frames[0].templ=document.Form1;
		alert("ACTION before is " + parent.frames[0].templ.ACTION.value);
		document.location = document.location;
		alert("ACTION after is " + parent.frames[0].templ.ACTION.value);
	}

	function ask_ACTION_MENU(x) {
		document.write("<tr> \n");
		document.write('<td width="100%" colspan="3"> \n');
		document.write(optional_fields(x));
		document.write("</td> \n");
		document.write("</tr> \n");
	}

	function ask_KEY(x) {
		document.write("<td>\n");
		document.write('<b> <font FACE="arial">');
		document.write("Key:&nbsp;&nbsp;");
		document.write("</font></b>\n");
		document.write('<input type="text" name="KEY" size="15" value="');
          	document.write(x);
        	document.write('">');
		document.write('\n</td>');
	}

	function ask_OPERATOR() {
		document.write('<b> <font FACE="arial">');
		document.write("&nbsp;Count:&nbsp;");
		document.write("</font></b>\n");
		document.write('<select size="1" name="OPERATOR">\n');
		document.write('<option selected value="lt">&lt;</option>\n');
		document.write('<option value="gt">&gt;</option>\n');
          	document.write('<option value="eq">=</option>\n');
          	document.write('<option value="le">&lt;=</option>\n');
		document.write('<option value="ge">&gt;=</option>\n');
		document.write('<option value="N/A">N/A</option>\n');        
          	document.write('</select>&nbsp;');
	}

	function ask_OPERAND() {
		document.write('<input type="text" name="OPERAND" size="4" value="75">');
		document.write('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
	}
	
	function ask_TIME_AVERAGE() {
		document.write('<b> <font FACE="arial">');
		document.write('Duration(min):&nbsp;&nbsp;');
		document.write('</font></b>\n');
		document.write('<input type="text" name="TIME_AVERAGE" size="5" value="5">');
		document.write('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
	}

	function ask_RESET() {
		document.write('<td>\n');
		document.write('<b> <font FACE="arial">');
		document.write('&nbsp;Clear Alarm:&nbsp;&nbsp; ');
		document.write('</font></b>\n');
		document.write(' <input type="radio" value="yes" checked name="RESET">\n');
		document.write('</td>');
	}

	function ask_DESC(x) {
		document.write('<td colspan=3>\n');
		document.write('<b> <font FACE="arial">');
		document.write('Description:&nbsp;&nbsp;');		
		document.write('</font></b>\n');
		document.write('<textarea rows="1" name="DESC" cols="70">');
		document.write(x);
		document.write('</textarea>\n');
		document.write('</td>');
	}
