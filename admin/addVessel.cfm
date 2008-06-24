<cfhtmlhead text="
	<meta name=""dc.title"" lang=""eng"" content=""PWGSC - ESQUIMALT GRAVING DOCK - Add New Vessel"">
	<meta name=""keywords"" lang=""eng"" content=""Add Vessel"">
	<meta name=""description"" lang=""eng"" content=""Allows user to create a new vessel in the Esquimalt Graving Dock booking website."">
	<meta name=""dc.subject"" scheme=""gccore"" lang=""eng"" content="""">
	<meta name=""dc.date.published"" content=""2005-07-25"">
	<meta name=""dc.date.reviewed"" content=""2005-07-25"">
	<meta name=""dc.date.modified"" content=""2005-07-25"">
	<meta name=""dc.date.created"" content=""2005-07-25"">
	<title>PWGSC - ESQUIMALT GRAVING DOCK - Add New Vessel</title>">

<cfquery name="getCompanies" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT CompanyID, Name
	FROM Companies
	WHERE Deleted = 0 AND Approved = 1
	ORDER BY Name
</cfquery>

<cfparam name="variables.userID" default="">
<cfparam name="variables.companyID" default="">
<cfparam name="variables.name" default="">
<cfparam name="variables.length" default="">
<cfparam name="variables.width" default="">
<cfparam name="variables.blocksetuptime" default="">
<cfparam name="variables.blockteardowntime" default="">
<cfparam name="variables.lloydsid" default="">
<cfparam name="variables.tonnage" default="">
<cfparam name="variables.anonymous" default="false">

<cfif NOT IsDefined("Session.form_Structure")>
	<cfinclude template="#RootDir#includes/build_form_struct.cfm">
	<cfinclude template="#RootDir#includes/restore_params.cfm">
<cfelse>
	<cfinclude template="#RootDir#includes/restore_params.cfm">
	<cfif isDefined("form.companyID")>
		<cfset Variables.companyID = #form.companyID#>
		<cfset Variables.name = #form.name#>
		<cfset Variables.length = #form.length#>
		<cfset Variables.width = #form.width#>
		<cfset Variables.blocksetuptime = #form.blocksetuptime#>
		<cfset Variables.blockteardowntime = #form.blockteardowntime#>
		<cfset Variables.lloydsid = #form.lloydsid#>
		<cfset Variables.length = #form.length#>
		<cfset Variables.tonnage = #form.tonnage#>
		<cfif isDefined("form.anonymous")><cfset Variables.anonymous = true><cfelse><cfset Variables.anonymous = false></cfif>
	</cfif>
</cfif>

<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

		<!-- BREAD CRUMB BEGINS | DEBUT DE LA PISTE DE NAVIGATION -->
		<p class="breadcrumb">
			<cfinclude template="/clf20/ssi/bread-pain-#lang#.html"><cfinclude template="#RootDir#includes/bread-pain-#lang#.cfm">&gt;
			<CFOUTPUT>
			<CFIF IsDefined('Session.AdminLoggedIn') AND Session.AdminLoggedIn eq true>
				<A href="#RootDir#admin/menu.cfm?lang=#lang#">Admin</A> &gt; 
			<CFELSE>
				 <a href="#RootDir#reserve-book/booking.cfm?lang=#lang#">Welcome Page</a> &gt;
			</CFIF>
			Add New Vessel
			</CFOUTPUT>
		</p>
		<!-- BREAD CRUMB ENDS | FIN DE LA PISTE DE NAVIGATION -->
		<div class="colLayout">
		<cfinclude template="#RootDir#includes/left-menu-gauche-#lang#.cfm">
			<!-- CONTENT BEGINS | DEBUT DU CONTENU -->
			<div class="center">
				<h1><a name="cont" id="cont">
					<!-- CONTENT TITLE BEGINS | DEBUT DU TITRE DU CONTENU -->
					Add New Vessel
					<!-- CONTENT TITLE ENDS | FIN DU TITRE DU CONTENU -->
					</a></h1>

				<cfinclude template="#RootDir#includes/admin_menu.cfm"><br>
				
				<cfinclude template="#RootDir#includes/getStructure.cfm">
				
				<cfform action="addVessel_process.cfm?lang=#lang#" method="post" name="addVessel">
				<table align="center">
				<tr>
					<td id="companyID_Header"><label for="companyID">Company Name:</label></td>
					<td headers="companyID_Header">
						<cfselect id="companyID" name="companyID" query="getCompanies" display="Name" value="companyID" selected="#variables.companyID#" />
					</td>
				</tr>
				<tr>
					<td id="name_Header"><label for="name">Name:</label></td>
					<td headers="name_Header"><cfinput id="name" name="name" type="text" value="#variables.name#" size="40" maxlength="100" required="yes" CLASS="textField" message="Please enter the vessel name."></td>
				</tr>
				<tr>
					<td id="LloydsID_Header"><label for="LloydsID">International Maritime Organization (IMO) Number:</label></td>
					<td headers="LloydsID_Header"><cfinput id="LloydsID" name="LloydsID" type="text" value="#variables.lloydsid#" size="20" maxlength="20"  CLASS="textField"></td>
				</tr>
				<tr>
					<td id="length_Header"><label for="length">Length (m):</label></td>
					<td headers="length_Header"><cfinput id="length" name="length" type="text" value="#variables.length#" size="8" maxlength="8" required="yes" validate="float" CLASS="textField" message="Please enter the length in metres.">  <span style="font-size: 9pt; color: red">Max: <cfoutput>#Variables.MaxLength#</cfoutput>m</span></td>
				</tr>
				<tr>
					<td id="width_Header"><label for="width">Width (m):</label></td>
					<td headers="width_Header"><cfinput id="width" name="width" type="text" value="#variables.width#" size="8" maxlength="8" validate="float" CLASS="textField" message="Please enter the width in metres.">  <span style="font-size: 9pt; color: red">Max: <cfoutput>#Variables.MaxWidth#</cfoutput>m</span></td>
				</tr>
				<tr>
					<td id="blocksetuptime_Header"><label for="blocksetuptime">Block Setup Time (days):</label></td>
					<td headers="blocksetuptime_Header"><cfinput id="blocksetuptime" name="blocksetuptime" type="text" value="#variables.blocksetuptime#" size="2" maxlength="2" validate="float" CLASS="textField" message="Please enter the block setup time in days."></td>
				</tr>
				<tr>
					<td id="blockteardowntime_Header"><label for="blockteardowntime">Block Teardown Time (days):</label></td>
					<td headers="blockteardowntime_Header"><cfinput id="blockteardowntime" name="blockteardowntime" type="text" value="#variables.blockteardowntime#" size="2" maxlength="2" validate="float" CLASS="textField" message="Please enter the block teardown time in days."></td>
				</tr>
				<tr>
					<td id="tonnage_Header"><label for="tonnage">Tonnage:</label></td>
					<td headers="tonnage_Header"><cfinput id="tonnage" name="tonnage" type="text" value="#variables.tonnage#" size="8" maxlength="8" validate="float" CLASS="textField" message="Please enter the tonnage."></td>
				</tr>
				<tr>
					<td id="Anonymous_Header"><label for="Anonymous">Keep this vessel anonymous:</label></td>
					<td headers="Anonymous_Header"><input id="Anonymous" type="checkbox" name="Anonymous" value="Yes" <cfif variables.anonymous>checked</cfif>></td>
				</tr>
				<tr>
					<td colspan="2" align="center" style="padding-top:20px;">
						<!---a href="javascript:document.addVessel.submitForm.click();" class="textbutton">Submit</a>
						<br--->
						<input type="submit" name="submitForm" value="Submit" class="textbutton">
						<cfoutput><input type="button" value="Cancel" onClick="self.location.href='menu.cfm?lang=#lang#'" class="textbutton"></cfoutput>
					</td>
				</tr>
				</table>
				</cfform>

			</div>
		<!-- CONTENT ENDS | FIN DU CONTENU -->
		</div>

<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">
