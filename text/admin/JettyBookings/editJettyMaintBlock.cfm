<!---cfinclude template="#RootDir#includes/restore_params.cfm">
<cfinclude template="#RootDir#includes/build_form_struct.cfm"--->

<cfhtmlhead text="
	<meta name=""dc.title"" lang=""eng"" content=""PWGSC - ESQUIMALT GRAVING DOCK - Edit Maintenance Block"">
	<meta name=""keywords"" lang=""eng"" content="""">
	<meta name=""description"" lang=""eng"" content="""">
	<meta name=""dc.subject"" scheme=""gccore"" lang=""eng"" content="""">
	<meta name=""dc.date.published"" content=""2005-07-25"">
	<meta name=""dc.date.reviewed"" content=""2005-07-25"">
	<meta name=""dc.date.modified"" content=""2005-07-25"">
	<meta name=""dc.date.created"" content=""2005-07-25"">
	<title>PWGSC - ESQUIMALT GRAVING DOCK - Edit Maintenance Block</title>">

<CFINCLUDE template="#RootDir#includes/calendar_js.cfm">

<!-- Start JavaScript Block -->
<script language="JavaScript" type="text/javascript">
	<!--
	function EditSubmit ( selectedform )
	{
	  document.forms[selectedform].submit() ;
	}
	//-->
</script>
<!-- End JavaScript Block -->
<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

		<!-- BREAD CRUMB BEGINS | DEBUT DE LA PISTE DE NAVIGATION -->
		<p class="breadcrumb">
			<cfinclude template="/clf20/ssi/bread-pain-eng.html"><cfinclude template="#RootDir#includes/bread-pain-#lang#.cfm">&gt;
			<CFOUTPUT>
			<CFIF IsDefined('Session.AdminLoggedIn') AND Session.AdminLoggedIn eq true>
				<A href="#RootDir#text/admin/menu.cfm?lang=#lang#">Admin</A> &gt; 
			<CFELSE>
				 <a href="#RootDir#text/booking/booking.cfm?lang=#lang#">Welcome Page</a> &gt;
			</CFIF>
			<a href="jettyBookingmanage.cfm?lang=#lang#">Jetty Management</A> &gt;
			Edit Maintenance Block
			</CFOUTPUT>
		</p>
		<!-- BREAD CRUMB ENDS | FIN DE LA PISTE DE NAVIGATION -->
		<div class="colLayout">
		<cfinclude template="#RootDir#includes/left-menu-gauche-eng.cfm">
			<!-- CONTENT BEGINS | DEBUT DU CONTENU -->
			<div class="center">
				<h1><a name="cont" id="cont">
					<!-- CONTENT TITLE BEGINS | DEBUT DU TITRE DU CONTENU -->
					Edit Maintenance Block
					<!-- CONTENT TITLE ENDS | FIN DU TITRE DU CONTENU -->
					</a></h1>
					
				<cfinclude template="#RootDir#includes/admin_menu.cfm"><br>

				<!--- -------------------------------------------------------------------------------------------- --->
				<cfparam name="Variables.BookingID" default="">
				<cfparam name="Variables.NorthJetty" default="false">
				<cfparam name="Variables.SouthJetty" default="false">
				
				<cfif NOT IsDefined("Session.form_Structure")>
					<cfinclude template="#RootDir#includes/build_form_struct.cfm">
					<cfinclude template="#RootDir#includes/restore_params.cfm">
				<cfelse>
					<cfinclude template="#RootDir#includes/restore_params.cfm">
					<cfif isDefined("form.bookingID")>
						<cfset Variables.bookingID = #form.bookingID#>
					</cfif>
				</cfif>
				
				<cfif IsDefined("Session.Return_Structure")>
					<cfinclude template="#RootDir#includes/getStructure.cfm">
				<cfelseif IsDefined("Form.BookingID") AND Form.BookingID NEQ "">
					<cfquery name="GetBooking" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
						SELECT	Bookings.StartDate, Bookings.EndDate, Bookings.BookingID, Jetties.NorthJetty, Jetties.SouthJetty
						FROM	Bookings, Jetties
						WHERE	Bookings.BookingID = Jetties.BookingID
						AND		Deleted = '0'
						AND		Status = 'M'
						AND		Bookings.BookingID = '#Form.BookingID#'
					</cfquery>
					
					<cfset Variables.StartDate = getBooking.StartDate>
					<cfset Variables.EndDate = getBooking.EndDate>
					<cfset Variables.NorthJetty = getBooking.NorthJetty>
					<cfset Variables.SouthJetty = getBooking.SouthJetty>
					<cfset Variables.BookingID = getBooking.BookingID>
				<cfelse>
					<cflocation addtoken="no" url="jettyBookingManage.cfm?lang=#lang#">
				</cfif>
				
				<cfif Variables.NorthJetty EQ 1>
					<cfset Variables.NorthJetty = true>
				<cfelse>
					<cfset Variables.NorthJetty = false>
				</cfif>
				<cfif Variables.SouthJetty EQ 1>
					<cfset Variables.SouthJetty = true>
				<cfelse>
					<cfset Variables.SouthJetty = false>
				</cfif>
				
				<cfif IsDefined("Session.form_Structure")>
					<cfinclude template="#RootDir#includes/restore_params.cfm">
					<cfif isDefined("form.StartDate")>
						<cfset Variables.StartDate = #form.startDate#>
						<cfset Variables.EndDate = #form.endDate#>
						<cfif isDefined("form.NorthJetty")>
							<cfset Variables.NorthJetty = true>
						<cfelse>
							<cfset Variables.NorthJetty = false>
						</cfif>
						<cfif isDefined("form.SouthJetty")>
							<cfset Variables.SouthJetty = true>
						<cfelse>
							<cfset Variables.SouthJetty = false>
						</cfif>
					</cfif>
				</cfif>
				<!--- -------------------------------------------------------------------------------------------- --->
				<cfform name="EditJettyMaintBlock" action="editJettyMaintBlock_process.cfm?#urltoken#" method="post">
				<cfoutput><input type="hidden" name="BookingID" value="#Variables.BookingID#"></cfoutput>
				<table width="100%">
				<tr>
					<td id="Start">Start Date:</td>
					<td headers="Start">
						<CFOUTPUT>
						<!---input class="textField" type="Text" name="startDateShow" id="start" disabled value="#DateFormat(startDate, 'mmm d, yyyy')#" size="17"--->
						<cfinput name="startDate" type="text" value="#DateFormat(startDate, 'mm/dd/yyyy')#" size="15" maxlength="10" required="yes" message="Please enter a start date." validate="date" class="textField"> <font class="light">#language.dateform#</font></CFOUTPUT>
						<a href="javascript:void(0);" onclick="javascript:getCalendar('EditJettyMaintBlock', 'start')" class="textbutton">calendar</a>
						<!---a href="javascript:void(0);" onClick="javascript:document.EditJettyMaintBlock.startDateShow.value=''; document.EditMaintBlock.startDate.value='';" class="textbutton">clear</a--->
					</td>
				</tr>
				<tr>
					<td id="End">End Date:</td>
					<td headers="End">
						<CFOUTPUT>
						<!---input type="text" name="endDateShow" id="end" class="textField" disabled value="#DateFormat(endDate, 'mmm d, yyyy')#" size="17"--->
						<cfinput name="endDate" type="text" value="#DateFormat(endDate, 'mm/dd/yyyy')#" size="15" maxlength="10" required="yes" message="Please enter an end date." validate="date" class="textField"> <font class="light">#language.dateform#</font></CFOUTPUT>
						<a href="javascript:void(0);" onclick="javascript:getCalendar('EditJettyMaintBlock', 'end')" class="textbutton">calendar</a>
						<!---a href="javascript:void(0);" onClick="javascript:document.EditMaintBlock.endDateShow.value=''; document.EditMaintBlock.endDate.value='';" class="textbutton">clear</a--->
					</td>
				</tr>
				<tr><td colspan="2">Please select the jetty/jetties that you wish to book for maintenance:</td></tr>
				<tr>
					<td id="nj"><label for="NorthJetty">North Landing Wharf</label></td>
					<td headers="nj"><cfinput type="Checkbox" id="NorthJetty" name="NorthJetty" checked="#Variables.NorthJetty#"></td></tr>
				<tr>
					<td id="sj"><label for="SouthJetty">South Jetty</label></td>
					<td headers="sj"><cfinput type="Checkbox" id="SouthJetty" name="SouthJetty" checked="#Variables.SouthJetty#"></td>
				</tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
					<td colspan="2" align="center">
						<!--a href="javascript:EditSubmit('EditMaintBlock');" class="textbutton">Submit</a-->
						<input type="submit" class="textbutton" value="submit">
						<cfoutput><input type="button" value="Cancel" onClick="self.location.href='jettyBookingManage.cfm?#urltoken#'" class="textbutton"></cfoutput>
						<!---input type="button" value="Cancel" class="textbutton" onClick="javascript:self.location.href='jettybookingmanage.cfm?#urltoken#';"--->
					</td>
				</tr>
				</table>
				</cfform>


			</div>
		<!-- CONTENT ENDS | FIN DU CONTENU -->
		</div>
<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">
