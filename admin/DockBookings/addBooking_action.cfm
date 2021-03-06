<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

<cfif IsDefined("Session.Return_Structure")>
	<cfoutput>#StructDelete(Session, "Return_Structure")#</cfoutput>
</cfif>

<cfset Variables.BookingDateTime = #CreateDateTime(DatePart('yyyy',Form.bookingDate), DatePart('m',Form.bookingDate), DatePart('d',Form.bookingDate), DatePart('h',Form.bookingTime), DatePart('n',Form.bookingTime), DatePart('s',Form.bookingTime))#>

<cfset Errors = ArrayNew(1)>
<cfset Success = ArrayNew(1)>
<cfset Proceed_OK = "Yes">

<cfoutput>#ArrayAppend(Success, "The booking has been successfully added.")#</cfoutput>

<!--- Validate the form data --->
<cfif (NOT isDefined("Form.Section1B")) AND (NOT isDefined("Form.Section2B")) AND (NOT isDefined("Form.Section3B")) AND (isDefined("Form.Confirmed"))>
	<cfoutput>#ArrayAppend(Errors, "You must choose at least one section of the dock for confirmed bookings.")#</cfoutput>
	no sections
	<cfset Proceed_OK = "No">
</cfif>


<cfif Proceed_OK EQ "No">
	<!--- Save the form data in a session structure so it can be sent back to the form page --->
	<cfset Session.Return_Structure.StartDate = Form.StartDate>
	<cfset Session.Return_Structure.EndDate = Form.EndDate>
	<cfset Session.Return_Structure.VNID = Form.VNID>
	<cfset Session.Return_Structure.UID = Form.UID>
	<cfif isDefined("Form.Section1B")><cfset Session.Return_Structure.Section1B = Form.Section1B></cfif>
	<cfif isDefined("Form.Section2B")><cfset Session.Return_Structure.Section2B = Form.Section2B></cfif>	
	<cfif isDefined("Form.Section3B")><cfset Session.Return_Structure.Section3B = Form.Section3B></cfif>
	<cfif isDefined("Form.Tentative")><cfset Session.Return_Structure.Tentative = Form.Tentative></cfif>
	<cfif isDefined("Form.Confirmed")><cfset Session.Return_Structure.Confirmed = Form.Confirmed></cfif>
		
	<cfset Session.Return_Structure.Errors = Errors>
	
 	<cflocation url="addBooking_process.cfm?startdate=#DateFormat(url.startdate, 'mm/dd/yyyy')#&enddate=#DateFormat(url.enddate, 'mm/dd/yyyy')#&show=#url.show#" addtoken="no"> 
<cfelse>

<cftransaction>
	<cfquery name="insertbooking" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		INSERT INTO	Bookings
				(VNID,
				StartDate,
				EndDate, 
				BookingTime, 
				UID)
		VALUES	
				(<cfqueryparam value="#form.VNID#" cfsqltype="cf_sql_integer" />,
				<cfqueryparam value="#CreateODBCDate(Form.StartDate)#" cfsqltype="cf_sql_date" />,
				<cfqueryparam value="#CreateODBCDate(Form.EndDate)#" cfsqltype="cf_sql_date" />, 
				<cfqueryparam value="#CreateODBCDateTime(Variables.BookingDateTime)#" cfsqltype="cf_sql_timestamp" />, 
				<cfqueryparam value="#form.UID#" cfsqltype="cf_sql_integer" />)
	</cfquery>
	<cfquery name="getID" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT	@@IDENTITY AS BRID
		FROM	Bookings
	</cfquery>
</cftransaction>

	<cfquery name="bookDock" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		INSERT INTO	Docks( 	<CFIF (isDefined("Form.Section1B") AND Form.Status EQ "C") OR (isDefined("Form.Section1A") AND Form.Section1A EQ 1)>
							Section1,
							</CFIF>
							<CFIF (isDefined("Form.Section2B") AND Form.Status EQ "C") OR (isDefined("Form.Section2A") AND Form.Section2A EQ 1)>
							Section2,
							</CFIF>
							<CFIF (isDefined("Form.Section3B") AND Form.Status EQ "C") OR (isDefined("Form.Section3A") AND Form.Section3A EQ 1)>
							Section3, 
							</CFIF>
							BRID, Status)
		VALUES		(<CFIF (isDefined("Form.Section1B") AND Form.Status EQ "C") OR (isDefined("Form.Section1A") AND Form.Section1A EQ 1)>
					1,
					</CFIF>
					<CFIF (isDefined("Form.Section2B") AND Form.Status EQ "C") OR (isDefined("Form.Section2A") AND Form.Section2A EQ 1)>
					1,
					</CFIF>
					<CFIF (isDefined("Form.Section3B") AND Form.Status EQ "C") OR (isDefined("Form.Section3A") AND Form.Section3A EQ 1)>
					1,
					</CFIF>
					<cfqueryparam value="#getID.BRID#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="#Form.Status#" cfsqltype="cf_sql_varchar" maxlength="2" />
					)
	</cfquery>

	<cfquery name="getDetails" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT	Email, Vessels.Name AS VesselName, StartDate, EndDate
		FROM	Bookings INNER JOIN Users ON Bookings.UID = Users.UID 
				INNER JOIN Vessels ON Bookings.VNID = Vessels.VNID
		WHERE	BRID = <cfqueryparam value="#getID.BRID#" cfsqltype="cf_sql_integer" />
	</cfquery>
		
	<cflock throwontimeout="no" scope="session" timeout="30" type="readonly">
		<cfquery name="getAdmin" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
			SELECT	Email
			FROM	Users
			WHERE	UID = <cfqueryparam value="#session.UID#" cfsqltype="cf_sql_integer" />
		</cfquery>
	</cflock>
		
	<cfoutput>
	<cfif ServerType EQ "Development">
		<cfset getDetails.Email = DevEmail />
		</cfif>
	<cfmail to="#getDetails.Email#" from="#AdministratorEmail#" subject="New Booking - Nouvelle r&eacute;servation: #getDetails.Vesselname#" type="html" username="#mailuser#" password="#mailpassword#">
<p>#getDetails.Vesselname# has been booked in the dock from #DateFormat(getDetails.StartDate, 'mmm d, yyyy')# to #DateFormat(getDetails.EndDate, 'mmm d, yyyy')#.</p>
<p>Esquimalt Graving Dock</p>
<br />
<p>Il y a une r&eacute;servation pour #getDetails.Vesselname# dans la cale s&egrave;che du #DateFormat(getDetails.StartDate, 'mmm d, yyyy')# au #DateFormat(getDetails.EndDate, 'mmm d, yyyy')#.</p>
<p>Cale s&egrave;che d'Esquimalt</p>
	</cfmail>
	</cfoutput>
	
	<!--- URL tokens set-up.  Do not edit unless you KNOW something is wrong, otherwise I will beat you.
		Lois Chan, July 2007 --->
	<CFSET variables.urltoken = "lang=#lang#">
	<CFIF IsDefined('variables.startDate')>
		<CFSET variables.urltoken = variables.urltoken & "&startDate=#variables.startDate#">
	<CFELSEIF IsDefined('url.startDate')>
		<CFSET variables.urltoken = variables.urltoken & "&startDate=#url.startDate#">
	</CFIF>
	<CFIF IsDefined('variables.endDate')>
		<CFSET variables.urltoken = variables.urltoken & "&endDate=#variables.endDate#">
	<CFELSEIF IsDefined('url.endDate')>
		<CFSET variables.urltoken = variables.urltoken & "&endDate=#url.endDate#">
	</CFIF>
	<CFIF IsDefined('variables.show')>
		<CFSET variables.urltoken = variables.urltoken & "&show=#variables.show#">
	<CFELSEIF IsDefined('url.show')>
		<CFSET variables.urltoken = variables.urltoken & "&show=#url.show#">
	</CFIF>
	
	<!--- create structure for sending to mothership/success page. --->
	<cfset Session.Success.Breadcrumb = "<a href='../admin/DockBookings/bookingManage.cfm?lang=#lang#'>Drydock Management</a> &gt; Create Booking">
	<cfset Session.Success.Title = "Create New Dock Booking">
	<cfset Session.Success.Message = "A new booking for <strong>#getDetails.vesselName#</strong> from #LSDateFormat(CreateODBCDate(getDetails.startDate), 'mmm d, yyyy')# to #LSDateFormat(CreateODBCDate(getDetails.endDate), 'mmm d, yyyy')# has been successfully created.  Email notification of this new booking has been sent to the agent.">
	<cfset Session.Success.Back = "Back to Dock Bookings Management">
	<cfset Session.Success.Link = "#RootDir#admin/DockBookings/bookingManage.cfm?#urltoken#">
	<cflocation addtoken="no" url="#RootDir#comm/succes.cfm?lang=#lang#">

	<!---cflocation url="bookingManage.cfm?lang=#lang#&startdate=#DateFormat(url.startdate, 'mm/dd/yyyy')#&enddate=#DateFormat(url.enddate, 'mm/dd/yyyy')#&show=#url.show#" addtoken="no"--->
</CFIF>

<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">

