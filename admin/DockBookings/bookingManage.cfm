<cfsavecontent variable="js">
	<cfoutput>
	<meta name="dcterms.title" content="pwgsc - esquimalt graving dock - Drydock Booking Management">
	<meta name="keywords" content="" />
	<meta name="description" content="" />
	<meta name="dcterms.description" content="" />
	<meta name="dcterms.subject" title="gccore" content="" />
	<title>PWGSC - ESQUIMALT GRAVING DOCK - Drydock Booking Management</title>
	<script type="text/javascript">
		/* <![CDATA[ */
		var bookingLength = 2;
		/* ]]> */
	</script>
	<script type="text/javascript" src="#RootDir#scripts/tandemDateFixer.js"></script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#js#">
<cfset request.title = "Drydock Booking Management">
<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

<!---clear form structure--->
<cfif IsDefined("Session.Form_Structure")>
	<cfset StructDelete(Session, "Form_Structure")>
</cfif>

<!--checking if enddate is defined instead of show is not a mistake!-->
<cfif IsDefined("form.EndDate") AND IsDate("form.EndDate")>
	<cfif IsDefined("form.show")>
		<cfset url.show = #form.show#>
	</cfif>
</cfif>

<!--- Want URL variables to take precedence over form variables for proper linking purposes --->
<cfif IsDefined("url.startDate") and IsDate(URLDecode(url.startDate))>
	<!---cfoutput>#url.startDate#</cfoutput--->
	<cfset form.startDate = url.startDate>
	<cfset Variables.startDate = url.startDate>
</cfif>
<cfif IsDefined("url.endDate") and IsDate(URLDecode(url.endDate))>
	<!---cfoutput>#url.endDate#</cfoutput--->
	<cfset form.endDate = url.endDate>
	<cfset Variables.endDate = url.endDate>
<cfelse>
	<!---added to default to max enddate so all bookings are shown--->
	<cfset form.endDate = "12/31/2031">
</cfif>

<cfparam name="form.startDate" default="#DateFormat(PacificNow, 'MM/dd/yyyy')#">
<cfparam name="form.endDate" default="#DateFormat(DateAdd('d', 30, PacificNow), 'MM/dd/yyyy')#">
<cfparam name="Variables.startDate" default="#form.startDate#">
<cfparam name="Variables.endDate" default="#form.endDate#">


<!---Drydock Status--->
<cfquery name="countPending" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT count(*) as numPend
		FROM Docks, Bookings
		WHERE (
				(Bookings.StartDate = <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND Bookings.EndDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR	(Bookings.startDate <= <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate >= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR	(Bookings.startDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate >= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR 	(Bookings.endDate >= <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
			)
		AND Docks.BRID = Bookings.BRID AND (Status = 'PC' OR Status = 'PT' OR Status = 'PX') AND Bookings.Deleted = '0'
</cfquery>
<cfquery name="countTentative" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT count(*) as numTent
		FROM Docks, Bookings
		WHERE (
				(Bookings.StartDate = <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND Bookings.EndDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR	(Bookings.startDate <= <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate >= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR	(Bookings.startDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate >= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR 	(Bookings.endDate >= <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
			)
		AND Docks.BRID = Bookings.BRID AND Status = 'T' AND Bookings.Deleted = '0'
		<!--- Eliminates any Tentative bookings with a start date before today --->
		AND ((Docks.status <> 'T') OR (Docks.status = 'T' AND Bookings.startDate >= <cfqueryparam value="#LSDateFormat(PacificNow, 'yyyy-MM-dd')#" cfsqltype="cf_sql_date" />))
</cfquery>
<cfquery name="countConfirmed" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT count(*) as numConf
		FROM Docks, Bookings
		WHERE (
				(Bookings.StartDate = <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND Bookings.EndDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR	(Bookings.startDate <= <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate >= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR	(Bookings.startDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate >= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR 	(Bookings.endDate >= <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
			)
		AND Docks.BRID = Bookings.BRID AND Status = 'C' AND Bookings.Deleted = '0'
</cfquery>

<cfparam name="form.show" default="c,t,p">
<cfparam name="url.show" default="#form.show#">
<cfparam name="Variables.show" default="#url.show#">

<cfset showPend = false>
<cfset showTent = false>
<cfset showConf = false>

<cfscript>
	if (REFindNoCase('p', url.show) neq 0) {
		// wants to show pending bookings
		showPend = true;
	}
	if (REFindNoCase('t', url.show) neq 0) {
		// wants to show tentative bookings
		showTent = true;
	}
	if (REFindNoCase('c', url.show) neq 0) {
		// wants to show confirmed bookings
		showConf = true;
	}
</cfscript>

<!-- Start JavaScript Block -->
<script type="text/javascript">
/* <![CDATA[ */
function EditSubmit ( selectedform )
{
  document.forms[selectedform].submit();
	}
/* ]]> */
</script>

<h1 id="wb-cont">Drydock Booking Management</h1>

<CFINCLUDE template="#RootDir#includes/admin_menu.cfm">

<p>Please enter a range of dates for which you would like to see the bookings:</p>
<form action="bookingManage.cfm?lang=#lang#" method="get">
	<input type="hidden" name="lang" value="<cfoutput>#lang#</cfoutput>" />
	
	<label for="start">Start Date:</label>
	<cfoutput>
		<input id="startDate" name="startDate" type="text" class="datepicker startDate" value="#DateFormat(variables.startDate, 'mm/dd/yyyy')#" size="15" maxlength="10" /> #language.dateform#
	</cfoutput>
			
	<label for="end">End Date:</label>
	<cfoutput>
		<input id="endDate" name="endDate" type="text" class="datepicker endDate" value="#DateFormat(variables.endDate, 'mm/dd/yyyy')#" size="15" maxlength="10" /> #language.dateform#
	<br/>
	Show Only:</cfoutput>
	<div class="form-checkbox" style="margin-left:20px">
		<label for="showPend" class="pending">Pending<input type="checkbox" id="showPend" name="show" value="p"<cfif showPend eq true> checked="true"</cfif> />
		</label>
		<label for="showTent" class="tentative">Tentative<input type="checkbox" id="showTent" name="show" value="t"<cfif showTent eq true> checked="true"</cfif> /></label>
		<label for="showConf" class="confirmed">Confirmed<input type="checkbox" id="showConf" name="show" value="c"<cfif showConf eq true> checked="true"</cfif> /></label>
	</div>
	<input type="submit" class="button button-accent" value="Submit" />	
</form>

<cfif form.startDate NEQ "" and form.endDate NEQ "">
	<cfif isDate(form.startDate)>
		<cfset proceed = "yes">
	</cfif>
</cfif>

<cfif isdefined('proceed') and proceed EQ "yes">
	<cfoutput>
	<cfparam name="form.expandAll" default="">
	<form action="bookingManage.cfm?#urltoken#" method="post" id="expandAll" class="hidden">
		<input type="hidden" name="startDate" value="#variables.startdate#" />
		<input type="hidden" name="endDate" value="#variables.endDate#" />
		<cfif form.expandAll NEQ "yes">
			<input type="hidden" name="expandAll" value="yes" />
		<cfelse>
			<input type="hidden" name="expandAll" value="no" />
		</cfif>
		<input type="hidden" name="show" value="#url.show#" />
	</form>

	<h2>Drydock <cfif #countPending.numPend# NEQ 0>(#countPending.numPend# #language.pending#)</cfif></h2>

<p>
<a href="addBooking.cfm?#urltoken#" class="textbutton">Add New Drydock Booking</a>
</p>
<p>
		<cfif form.expandAll NEQ "yes">
			<a href="javascript:EditSubmit('expandAll');">Expand All</a>
		<cfelse>
			<a href="javascript:EditSubmit('expandAll');">Collapse All</a>
		</cfif>
</p>

	<p align="center">Total:&nbsp;&nbsp;
		<span class="pending">Pending - #countPending.numPend#</span>&nbsp;&nbsp;
		<span class="tentative">Tentative - #countTentative.numTent#</span>&nbsp;&nbsp;
		<span class="confirmed">Confirmed - #countConfirmed.numConf#</span>
	</p>

	</cfoutput>

	<cfquery name="getBookings" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT 	Bookings.EndHighlight AS EndHighlight, Bookings.*, Vessels.Name AS VesselName, Docks.Status
		FROM 	Bookings INNER JOIN Vessels ON Bookings.VNID = Vessels.VNID
					INNER JOIN Docks ON Bookings.BRID = Docks.BRID
		WHERE  ((Bookings.startDate >= <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
				AND Bookings.startDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
			OR (Bookings.startDate <= <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
				AND Bookings.endDate >= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
			OR (Bookings.endDate >= <cfqueryparam value="#dateformat(variables.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
				AND Bookings.endDate <= <cfqueryparam value="#dateformat(variables.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />))
			AND Bookings.Deleted = 0
			AND Vessels.Deleted = 0

		<cfif variables.showPend EQ true AND variables.showTent EQ false AND variables.showConf EQ false>
			AND (Docks.Status = 'PC' OR Docks.Status = 'PX' OR Docks.Status = 'PT')
		</cfif>
		<cfif variables.showTent EQ true AND variables.showPend EQ false AND variables.showConf EQ false>
			AND Docks.Status = 'T'
		</cfif>
		<cfif variables.showConf EQ true AND variables.showPend EQ false AND variables.showTent EQ false>
			AND Docks.Status = 'C'
		</cfif>
		<cfif variables.showPend EQ true AND variables.showTent EQ true AND variables.showConf EQ false>
			AND ((Docks.Status = 'PC' OR Docks.Status = 'PX' OR Docks.Status = 'PT') OR (Docks.Status = 'T'))
		</cfif>
		<cfif variables.showPend EQ true AND variables.showTent EQ false AND variables.showConf EQ true>
			AND ((Docks.Status = 'C') OR (Docks.Status = 'PC' OR Docks.Status = 'PX' OR Docks.Status = 'PT'))
		</cfif>
		<cfif variables.showPend EQ false AND variables.showTent EQ true AND variables.showConf EQ true>
			AND ((Docks.Status = 'C') OR (Docks.Status = 'T'))
		</cfif>
		ORDER BY Bookings.startDate, Bookings.endDate, Vessels.Name
	</cfquery>

	<cfif getBookings.RecordCount GT 0>
		<cfoutput query="getBookings">
		<cfset Variables.id = #BRID#>
			<form name="booking#id#" action="bookingManage.cfm?#urltoken###id#id#" method="post" class="hidden">
				<input type="hidden" name="startDate" value="#form.startDate#" />
				<input type="hidden" name="endDate" value="#form.endDate#" />
				<cfif (isDefined("form.ID") AND form.ID EQ #id#) OR (isDefined('url.BRID') AND url.BRID EQ id)>
					<input type="hidden" name="ID" value="0" />
				<cfelse>
					<input type="hidden" name="ID" value="#id#" />
				</cfif>
				<input type="hidden" name="show" value="#variables.show#" />
			</form>
		</cfoutput>
	</cfif>
	<table class="width-90">
		<tr>
			<th id="Start">Start Date</th>
			<th id="End">End Date</th>
			<th id="Vessel">Vessel Name</th>
			<th id="Status">Status</th>
		</tr>
<cfif getBookings.RecordCount GT 0>
<cfoutput query="getBookings">
<tr style="display: none">
<td>
				<cfset Variables.id = #BRID#>

				<form method="post" action="deleteBooking_confirm.cfm?#urltoken#" name="delete#ID#">
					<input type="hidden" name="BRID" value="#id#" />
				</form>
				<form method="post" action="chgStatus_2c.cfm?#urltoken#" name="chgStatus_2c#ID#">
					<input type="hidden" name="BRID" value="#id#" />
				</form>

				<form method="post" action="chgStatus_2p.cfm?#urltoken#" name="chgStatus_2p#ID#">
					<input type="hidden" name="BRID" value="#id#" />
				</form>

				<form method="post" action="chgStatus_2t.cfm?#urltoken#" name="chgStatus_2t#ID#">
					<input type="hidden" name="BRID" value="#id#" />
				</form>

				<form method="post" action="deny.cfm?#urltoken#" name="deny#ID#">
					<input type="hidden" name="BRID" value="#id#" />
				</form>

				<form method="post" action="editBooking.cfm?#urltoken#" name="editBooking#ID#">
					<input type="hidden" name="BRID" value="#id#" />
				</form>
</td>
</tr>

		<tr>
			<td headers="start" nowrap>#LSdateformat(startDate, "mmm d, yyyy")#</td>
			<td headers="end" nowrap>#LSdateformat(endDate, "mmm d, yyyy")#</td>
			<td headers="vessel"><a href="javascript:EditSubmit('booking#id#');" name="id#id#" id="id#id#"><cfif #EndHighlight# GTE PacificNow>* </cfif>#VesselName#</a></td>
			<td headers="status"><cfif status EQ "C"><div class="confirmed">Confirmed</div><cfelseif status EQ "T"><div class="tentative">Tentative</div><cfelseif status EQ "PT"><div class="pending">Pending T</div><cfelseif status EQ "PC"><div class="pending">Pending C</div><cfelseif status EQ "PX"><a href="javascript:EditSubmit('delete#ID#');"><div class="cancelled">Pending X</div></a></cfif></td>
		</tr>

		<cfif (isDefined('form.id') AND form.id EQ id) OR (isDefined('url.BRID') AND url.BRID EQ id) OR form.expandAll EQ "yes">
			<cfquery name="getData" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
				SELECT 	Bookings.EndHighlight AS EndHighlight, Bookings.StartDate, Bookings.EndDate, Vessels.Name AS VesselName, Vessels.*,
						Users.LastName + ', ' + Users.FirstName AS UserName,
						Companies.Name AS CompanyName, Docks.Section1, Docks.Section2, Docks.Section3,
						Docks.Status, BookingTime, BookingTimeChange, BookingTimeChangeStatus
				FROM 	Bookings, Docks, Vessels, Users, Companies
				WHERE	Bookings.VNID = Vessels.VNID
				AND		Vessels.CID = Companies.CID

				AND		Bookings.UID = Users.UID
				AND		Bookings.BRID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer" />
				AND		Docks.BRID = Bookings.BRID
			</cfquery>

			<tr><td colspan="5">
				
			<div class="module-info widemod">
				<h2>Booking Details</h2>
				<div class="indent">
					<b>Start Date:</b> #dateformat(getData.startDate, "mmm d, yyyy")#<br/>
					<b>End Date:</b> #dateformat(getData.endDate, "mmm d, yyyy")#<br/>
					<b>## of Days:</b> #datediff('d', getData.startDate, getData.endDate) + 1#<br/>
					<b>Vessel:</b> <cfif #EndHighlight# GTE PacificNow>* </cfif>#getData.vesselName#<br/>
					<b><i>Length:</i></b> <i>#getData.length# m</i><br/>
					<b><i>Width:</i></b> <i>#getData.width# m</i><br/>
					<b><i>Tonnage:</i></b> <i>#getData.tonnage#</i><br/>
					<b>Agent:</b> #getData.UserName#<br/>
					<b>Company:</b> #getData.companyName# <a class="textbutton" href="changeCompany.cfm?BRIDURL=#BRID#&CompanyURL=#getData.companyName#&vesselNameURL=#getData.vesselName#&amp;UserNameURL=#getData.UserName#">Change</a><br/>
					<b>Booking Time:</b> #DateFormat(getData.bookingTime,"mmm d, yyyy")# #TimeFormat(getData.bookingTime,"long")#<br/>
					<b>Last Change:</b> #getData.bookingTimeChangeStatus# #DateFormat(getData.bookingTimeChange,"mmm d, yyyy")# #TimeFormat(getData.bookingTimeChange,"long")#<br/>
					<b>Section(s):</b> <cfif getData.Section1>Section 1</cfif>
						<cfif getData.Section2><cfif getData.Section1> &amp; </cfif>Section 2</cfif>
						<cfif getData.Section3><cfif getData.Section1 OR getData.Section2> &amp; </cfif>Section 3</cfif>
						<cfif NOT getData.Section1 AND NOT getData.Section2 AND NOT getData.Section3>Unassigned</cfif>
				</div>
				<div style="text-align:right"><a href="javascript:EditSubmit('editBooking#ID#');">Edit Details</a></div>
			</div>
			<br/>
			<div style="margin-left:-10px;"><form class="form-inline"><label for="EndHighlight">Highlight for:</label>
				<cfform action="highlight_action.cfm?BRID=#BRID#" method="post" id="updateHighlight">
					<cfif EndHighlight NEQ "">
					<cfset datediffhighlight = DateDiff("d", PacificNow, EndHighlight)>
					<cfset datediffhighlight = datediffhighlight+"1">
					<cfif datediffhighlight LTE "0"><cfset datediffhighlight = "0"></cfif>
					<cfelse>
					<cfset datediffhighlight = "0">
					</cfif>
					<cfinput id="EndHighlight" name="EndHighlight" type="text" value="#datediffhighlight#" size="3" maxlength="3" required="yes" message="Please enter an End Highlight Date." /> Days <input type="submit" name="submitForm" class="button" value="Update" />
				</cfform></form>
			</div>
			
			<b>Highlight Until:</b> <cfif datediffhighlight NEQ "0">#DateFormat(EndHighlight, "mmm dd, yyyy")#</cfif>
			<cfif DateCompare(PacificNow, getData.startDate, 'd') NEQ 1 OR (DateCompare(PacificNow, getData.startDate, 'd') EQ 1 AND DateCompare(PacificNow, getData.endDate, 'd') NEQ 1)>
					<cfset variables.actionCap = "Cancel Booking">
				<cfelse>
					<cfset variables.actionCap = "Delete Booking">
				</cfif><br/>
			<b>Status:</b> <cfif getData.Status EQ "C">
						<strong>Confirmed</strong>
						<a href="javascript:EditSubmit('chgStatus_2t#ID#');" class="textbutton">Make Tentative</a>
						<a href="javascript:EditSubmit('chgStatus_2p#ID#');" class="textbutton">Make Pending</a>
					<cfelseif getData.Status EQ "T">
						<a href="javascript:EditSubmit('chgStatus_2c#ID#');" class="textbutton">Make Confirmed</a>
						<strong>Tentative</strong>
						<a href="javascript:EditSubmit('chgStatus_2p#ID#');" class="textbutton">Make Pending</a>
					<cfelse>
						<a href="javascript:EditSubmit('chgStatus_2c#ID#');" class="textbutton">Make Confirmed</a>
						<a href="javascript:EditSubmit('chgStatus_2t#ID#');" class="textbutton">Make Tentative</a>
						<a href="javascript:EditSubmit('chgStatus_2p#ID#');" class="textbutton">Make Pending</a>
						<cfif getData.Status EQ "PC">
							<a href="javascript:EditSubmit('deny#ID#');" class="textbutton">Deny Request</a>
						</cfif>
					</cfif>				
				<br/>
					<a href="javascript:EditSubmit('delete#ID#');" class="textbutton">#variables.actionCap#</a>
					<a href="javascript:EditSubmit('deny#ID#');" class="textbutton">Deny Request</a>	
				</cfif>
			</cfoutput>

		<cfelse>
			<tr>
				<td colspan="4">
					There are no bookings for this date range.
				</td>
			</tr>
		</cfif>

	</table>
	<div style="float:left;"><a href="addBooking.cfm?#urltoken#" class="textbutton">Add New Drydock Booking</a></div>
	<div style="text-align:right;">
		<cfif form.expandAll NEQ "yes">
			<a href="javascript:EditSubmit('expandAll');">Expand All</a>
		<cfelse>
			<a href="javascript:EditSubmit('expandAll');">Collapse All</a>
		</cfif>
	</div>

	<hr />
	<h2>Maintenance</h2>
	<cfoutput><a href="addMaintBlock.cfm?#urltoken#" class="textbutton">Add New Maintenance Block</a></cfoutput>

	<cfquery name="getMaintenance" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT  Bookings.*, Docks.Section1, Docks.Section2, Docks.Section3
		FROM 	Bookings INNER JOIN Docks ON Bookings.BRID = Docks.BRID
		WHERE	(
					(Bookings.startDate >= <cfqueryparam value="#dateformat(form.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.startDate <= <cfqueryparam value="#dateformat(form.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR	(Bookings.startDate <= <cfqueryparam value="#dateformat(form.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate >= <cfqueryparam value="#dateformat(form.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				OR 	(Bookings.endDate >= <cfqueryparam value="#dateformat(form.startDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />	AND Bookings.endDate <= <cfqueryparam value="#dateformat(form.endDate, 'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />)
				)
		AND 	Bookings.Deleted = 0
		AND 	Docks.Status = 'M'
		ORDER BY Bookings.startDate, Bookings.endDate
	</cfquery>

	<table style="width:90%">
		<tr>
			<th id="Start">Start Date</th>
			<th id="End">End Date</th>
			<th id="Section">Section</th>
			<th colspan="2">&nbsp;</th>
		</tr>
		<cfif getMaintenance.RecordCount GT 0>
			<cfoutput query="getMaintenance">
				<cfif DateCompare(PacificNow, getMaintenance.startDate, 'd') NEQ 1 OR (DateCompare(PacificNow, getMaintenance.startDate, 'd') EQ 1 AND DateCompare(PacificNow, getMaintenance.endDate, 'd') NEQ 1)>
					<cfset variables.actionCap = "Cancel">
				<cfelse>
					<cfset variables.actionCap = "Delete">
				</cfif>

				<cfset Variables.id = #BRID#>
				<tr>
					<td headers="Start" nowrap>#dateformat(startDate, "mmm d, yyyy")#</td>
					<td headers="End" nowrap>#dateformat(endDate, "mmm d, yyyy")#</td>
					<td headers="Section">
						<cfif getMaintenance.Section1 AND getMaintenance.Section2 AND getMaintenance.Section3>
							All Sections
						<cfelse>
							<cfif getMaintenance.Section1>Section 1</cfif>
							<cfif getMaintenance.Section2><cfif getMaintenance.Section1> &amp; </cfif>Section 2</cfif>
							<cfif getMaintenance.Section3><cfif getMaintenance.Section1 OR getMaintenance.Section2> &amp; </cfif>Section 3</cfif>
						</cfif>
					</td>
					<td><a href="#RootDir#admin/DockBookings/editMaintBlock.cfm?BRID=#getMaintenance.BRID#">Edit</a></td>
					<td><a href="#RootDir#admin/DockBookings/deleteMaintBlock_confirm.cfm?BRID=#getMaintenance.BRID#">#variables.actionCap#</a></td>
				</tr>
			</cfoutput>
		<cfelse>
			<tr>
				<td colspan="5">
					There are no maintenance blocks for this date range.
				</td>
			</tr>
		</cfif>
	</table>

	<cfoutput><a href="addMaintBlock.cfm?#urltoken#" class="textbutton">Add New Maintenance Block</a></cfoutput>

</cfif>
<!-- CONTENT ENDS | FIN DU CONTENU -->

<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">
