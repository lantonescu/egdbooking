<cfif isDefined("form.startDate")><cfinclude template="#RootDir#includes/build_form_struct.cfm"></cfif>
<cfinclude template="#RootDir#includes/restore_params.cfm">

<cfhtmlhead text="
	<meta name=""dcterms.title"" content=""PWGSC - ESQUIMALT GRAVING DOCK - Edit Dock Booking"">
	<meta name=""keywords"" content="""" />
	<meta name=""description"" content="""" />
	<meta name=""dcterms.description"" content="""" />
	<meta name=""dcterms.subject"" content="""" />
	<title>PWGSC - ESQUIMALT GRAVING DOCK - Edit Dock Booking</title>">
	<cfset request.title ="Edit Booking Information">
<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

<CFPARAM name="url.referrer" default="Drydock Booking Management">
<CFIF url.referrer eq "Booking Details">
	<CFSET returnTo = "#RootDir#comm/detail-res-book.cfm">
<CFELSE>
	<CFSET returnTo = "#RootDir#admin/DockBookings/bookingManage.cfm">
</CFIF>

<cfif isDefined("url.date")>
	<cfset variables.dateValue = "&date=#url.date#">
<cfelse>
	<cfset variables.dateValue = "">
</cfif>


<!-- Start JavaScript Block -->
<script type="text/javascript">
/* <![CDATA[ */
function EditSubmit ( selectedform )
	{
	  document.forms[selectedform].submit();
	}
/* ]]> */
</script>
<!-- End JavaScript Block -->
<h1 id="wb-cont">
	<!-- CONTENT TITLE BEGINS | DEBUT DU TITRE DU CONTENU -->
	Edit Booking Information
	<!-- CONTENT TITLE ENDS | FIN DU TITRE DU CONTENU -->
</h1>

<CFINCLUDE template="#RootDir#includes/admin_menu.cfm">

<cfset Errors = ArrayNew(1)>
<cfset Success = ArrayNew(1)>
<cfset Proceed_OK = "Yes">

<!---<cfoutput>#ArrayAppend(Success, "The booking has been successfully added.")#</cfoutput>--->

<cfparam name = "Form.StartDate" default="">
<cfparam name = "Form.EndDate" default="">
<cfparam name = "Variables.BRID" default="#Form.BRID#">
<cfparam name = "Variables.StartDate" default = "#Form.StartDate#">
<cfparam name = "Variables.EndDate" default = "#Form.EndDate#">
<cfparam name = "Form.VNID" default="">
<cfparam name = "Variables.VNID" default = "#Form.VNID#">
<cfparam name = "Form.UID" default="">
<cfparam name = "Variables.UID" default = "#Form.UID#">
<cfparam name = "Variables.Section1" default = 0>
<cfparam name = "Variables.Section2" default = 0>
<cfparam name = "Variables.Section3" default = 0>

<cfif (NOT IsDefined("Form.BRID") OR Form.BRID eq '') AND (NOT IsDefined("URL.BRID") OR URL.BRID eq '')>
	<cflocation addtoken="no" url="#RootDir#admin/DockBookings/bookingManage.cfm?#urltoken#">
</cfif>


<cfif IsDefined("Form.Section1")>
	<cfset Variables.Section1 = 1>
</cfif>
<cfif IsDefined("Form.Section2")>
	<cfset Variables.Section2 = 1>
</cfif>
<cfif IsDefined("Form.Section3")>
	<cfset Variables.Section3 = 1>
</cfif>

<cfif Variables.StartDate EQ "">
	<cflocation addtoken="no" url="editBooking.cfm?lang=#lang##variables.dateValue#">
</cfif>

<cfset Variables.StartDate = CreateODBCDate(#Variables.StartDate#)>
<cfset Variables.EndDate = CreateODBCDate(#Variables.EndDate#)>

<cfif IsDefined("Session.Return_Structure")>
	<cfoutput>#StructDelete(Session, "Return_Structure")#</cfoutput>
</cfif>

<cfquery name="getData" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT 	Vessels.VNID, Length, Width, Vessels.Name AS VesselName, Companies.Name AS CompanyName, Docks.Status
	FROM 	Vessels, Companies, Bookings, Docks
	WHERE 	Vessels.VNID = Bookings.VNID
	AND		Bookings.BRID = <cfqueryparam value="#Form.BRID#" cfsqltype="cf_sql_integer" />
	AND		Docks.BRID = Bookings.BRID
	AND		Companies.CID = Vessels.CID
	AND 	Vessels.Deleted = 0
	AND		Companies.Deleted = 0
</cfquery>
<cfquery name="getAgent" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT 	lastname + ', ' + firstname AS UserName
	FROM 	Users
	WHERE 	UID = <cfqueryparam value="#Variables.UID#" cfsqltype="cf_sql_integer" />
</cfquery>
<cfset Variables.VNID = getData.VNID>

<!---Check to see that vessel hasn't already been booked during this time--->
<cfquery name="checkDblBooking" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT 	Bookings.VNID, Name, StartDate, EndDate
	FROM 	Bookings
				INNER JOIN Vessels ON Vessels.VNID = Bookings.VNID
				INNER JOIN Docks ON Bookings.BRID = Docks.BRID
	WHERE 	Bookings.VNID = <cfqueryparam value="#Variables.VNID#" cfsqltype="cf_sql_integer" />
	AND 	Bookings.BRID != <cfqueryparam value="#Form.BRID#" cfsqltype="cf_sql_integer" />
	AND 	(
				(	Bookings.StartDate <= <cfqueryparam value="#Variables.StartDate#" cfsqltype="cf_sql_date" /> AND <cfqueryparam value="#Variables.StartDate#" cfsqltype="cf_sql_date" /> <= Bookings.EndDate )
			OR 	(	Bookings.StartDate <= <cfqueryparam value="#Variables.EndDate#" cfsqltype="cf_sql_date" /> AND <cfqueryparam value="#Variables.EndDate#" cfsqltype="cf_sql_date" /> <= Bookings.EndDate )
			OR	(	Bookings.StartDate >= <cfqueryparam value="#Variables.StartDate#" cfsqltype="cf_sql_date" /> AND <cfqueryparam value="#Variables.EndDate#" cfsqltype="cf_sql_date" /> >= Bookings.EndDate)
			)
	AND		Bookings.Deleted = 0
</cfquery>

<cfset Variables.StartDate = DateFormat(Variables.StartDate, 'mm/dd/yyyy')>
<cfset Variables.EndDate = DateFormat(Variables.EndDate, 'mm/dd/yyyy')>
<cfset Variables.TheBookingDate = CreateODBCDate(#Form.bookingDate#)>
<cfset Variables.TheBookingTime = CreateODBCTime(#Form.bookingTime#)>

<!--- Validate the form data --->
<cfif Variables.StartDate GT Variables.EndDate>
	<cfoutput>#ArrayAppend(Errors, "The Start Date must be before the End Date.")#</cfoutput>
	<cfset Proceed_OK = "No">
</cfif>

<cfif DateDiff("d",Variables.StartDate,Variables.EndDate) LT 0>
	<cfoutput>#ArrayAppend(Errors, "The minimum booking time is 1 day.")#</cfoutput>
	<cfset Proceed_OK = "No">
</cfif>

<!--- <cfif DateCompare(PacificNow, Variables.StartDate, 'd') EQ 1>
	<cfoutput>#ArrayAppend(Errors, "The Start Date can not be in the past.")#</cfoutput>
	<cfset Proceed_OK = "No"> --->
<cfif checkDblBooking.RecordCount GT 0>
	<!---<cfoutput>#ArrayAppend(Errors, "#checkDblBooking.Name# has already been booked from #dateFormat(checkDblBooking.StartDate, 'mm/dd/yyy')# to #dateFormat(checkDblBooking.EndDate, 'mm/dd/yyy')#.")#</cfoutput>--->
	<cfoutput><div id="actionErrors">#checkDblBooking.Name# has already been booked from #dateFormat(checkDblBooking.StartDate, 'mm/dd/yyy')# to #dateFormat(checkDblBooking.EndDate, 'mm/dd/yyy')#.</div></cfoutput>
	<cfset Proceed_OK = "Yes">
</cfif>

<cfif getData.Width GTE Variables.MaxWidth OR getData.Length GTE Variables.MaxLength>
	<cfoutput>#ArrayAppend(Errors, "The vessel, #getData.VesselName#, is too large for the drydock.")#</cfoutput>
	<cfset Proceed_OK = "No">
</cfif>

<cfif getData.Status EQ 'c' AND NOT isDefined("form.section1") AND NOT isDefined("form.section2") AND NOT isDefined("form.section3")>
	<cfoutput>#ArrayAppend(Errors, "At least one section of the dock must be selected for confirmed bookings.")#</cfoutput>
	<cfset Proceed_OK = "No">
</cfif>

<cfif Proceed_OK EQ "No">
	<!--- Save the form data in a session structure so it can be sent back to the form page --->
	<cfset Session.Return_Structure.StartDate = Variables.StartDate>
	<cfset Session.Return_Structure.EndDate = Variables.EndDate>
	<cfset Session.Return_Structure.VNID = Variables.VNID>
	<cfset Session.Return_Structure.BRID = Variables.BRID>
	<cfset Session.Return_Structure.Section1 = Variables.Section1>
	<cfset Session.Return_Structure.Section2 = Variables.Section2>
	<cfset Session.Return_Structure.Section3 = Variables.Section3>
	<cfset Session.Return_Structure.TheBookingDate = Variables.TheBookingDate>
	<cfset Session.Return_Structure.TheBookingTime = Variables.TheBookingTime>

	<cfset Session.Return_Structure.Errors = Errors>

	<cflocation url="editBooking.cfm?#urltoken##variables.dateValue#" addToken="no">
</CFIF>

<!--- <cfif IsDefined("Form.Section1")>
	<cfset Variables.Section1 = 1>
</cfif>
<cfif IsDefined("Form.Section2")>
	<cfset Variables.Section2 = 1>
</cfif>
<cfif IsDefined("Form.Section3")>
	<cfset Variables.Section3 = 1>
</cfif> --->

<!-- Gets all Bookings that would be affected by the requested booking --->
<cfset Variables.StartDate = #CreateODBCDate(Variables.StartDate)#>
<cfset Variables.EndDate = #CreateODBCDate(Variables.EndDate)#>

Please confirm the following information.
<cfform action="editBooking_action.cfm?#urltoken#&referrer=#URLEncodedFormat(url.referrer)##variables.dateValue#" method="post" id="bookingreq" preservedata="Yes">
<cfoutput><input type="hidden" name="BRID" value="#Variables.BRID#" /></cfoutput>
<br/>
<div class="module-info widemod">
	<h2>Booking Details</h2>
	<ul>
		<b>Vessel:</b> <cfoutput>#getData.VesselName#</cfoutput><br/>
		<b>Company:</b> <cfoutput>#getData.CompanyName#</cfoutput><br/>
		<b>Agent:</b> <input type="hidden" name="UID" value="<cfoutput>#Variables.UID#</cfoutput>" /><cfoutput>#getAgent.UserName#</cfoutput><br/>
		<b>Start Date:</b> <input type="hidden" name="StartDate" value="<cfoutput>#Variables.StartDate#</cfoutput>" /><cfoutput>#DateFormat(Variables.StartDate, 'mmm d, yyyy')#</cfoutput><br/>
		<b>End Date:</b> <input type="hidden" name="EndDate" value="<cfoutput>#Variables.EndDate#</cfoutput>" /><cfoutput>#DateFormat(Variables.EndDate, 'mmm d, yyyy')#</cfoutput><br/>
		<b>Booking Time:</b> <cfoutput>
				<input type="hidden" name="bookingDate" value="#Variables.TheBookingDate#" />
				<input type="hidden" name="bookingTime" value="#Variables.TheBookingTime#" />
				#DateFormat(Variables.TheBookingDate, 'mmm d, yyyy')# #TimeFormat(Variables.TheBookingTime, 'HH:mm:ss')#
			</cfoutput><br/>
		<b>Length:</b> <cfoutput>#getData.Length# m</cfoutput><br/>
		<b>Width:</b> <cfoutput>#getData.Width# m</cfoutput><br/>
		<cfif getData.Status EQ "C">
			<b>Sections:</b> <CFIF Variables.Section1>Section 1<input type="hidden" name="Section1" value="true" /></CFIF>
			<CFIF Variables.Section2><CFIF Variables.Section1> &amp; </CFIF>Section 2<input type="hidden" name="Section2" value="true" /></CFIF>
			<CFIF Variables.Section3><CFIF Variables.Section1 OR Variables.Section2> &amp; </CFIF>Section 3<input type="hidden" name="Section3" value="true" /></CFIF><br/>
		</cfif>
	</ul>
</div>

<br />
	<input type="submit" value="Confirm" class="button button-accent" />
	<cfoutput><a href="editBooking.cfm?#urltoken#&referrer=#URLEncodedFormat(url.referrer)##variables.dateValue#" class="textbutton">Back</a></cfoutput>
	<cfoutput><a href="#returnTo#?#urltoken#&BRID=#variables.BRID#&referrer=#URLEncodedFormat(url.referrer)##variables.dateValue#" class="textbutton">Cancel</a></cfoutput>	
</cfform>

<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">
