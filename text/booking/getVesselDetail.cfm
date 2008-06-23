<cfinclude template="#RootDir#includes/vesselInfoVariables.cfm">
<cfif lang EQ "eng">
	<cfset language.vesselDetail = "Vessel Details">
	<cfset language.keywords = language.masterKeywords & ", Vessel details">
	<cfset language.description = "Retrieves information for a given vessel.">
	<cfset language.subjects = language.masterSubjects & "">
	<cfset language.detailsFor = "Details for">
	<cfset language.days = "days">
	<cfset language.editVessel = "Edit Vessel">
	<cfset language.deleteVessel = "Delete Vessel">
	<cfset language.company = "Company">
	<cfset language.tonnes = "tonnes">
	<cfset language.anon = "Anonymous">
	<cfset language.yes = "Yes">
	<cfset language.no = "No">
<cfelse>
	<cfset language.vesselDetail = "D&eacute;tails concernant le navire">
	<cfset language.keywords = language.masterKeywords & ", D&eacute;tails concernant le navire">
	<cfset language.description = "R&eacute;cup&eacute;ration de renseignements sur un navire pr&eacute;cis.">
	<cfset language.subjects = language.masterSubjects & "">
	<cfset language.detailsFor = "D&eacute;tails pour">
	<cfset language.days = "jours">
	<cfset language.editVessel = "Modifier le navire">
	<cfset language.deleteVessel = "Supprimer le navire">
	<cfset language.company = "Entreprise">
	<cfset language.tonnes = "tonnes">
	<cfset language.anon = "Anonyme">
	<cfset language.yes = "Oui">
	<cfset language.no = "Non">
</cfif>

<cfquery name="readonlycheck" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT ReadOnly
	FROM Users
	WHERE UserID = #Session.UserID#
</cfquery>
<cfoutput query="readonlycheck">	
	<cfset Session.ReadOnly = #ReadOnly#>
</cfoutput>
<cfhtmlhead text="
	<meta name=""dc.title"" lang=""eng"" content=""#language.PWGSC# - #language.EsqGravingDockCaps# - #language.vesselDetail#"">
	<meta name=""keywords"" lang=""eng"" content=""#language.keywords#"">
	<meta name=""description"" lang=""eng"" content=""#language.description#"">
	<meta name=""dc.subject"" scheme=""gccore"" lang=""eng"" content=""#language.subjects#"">
	<meta name=""dc.date.published"" content=""2005-07-25"">
	<meta name=""dc.date.reviewed"" content=""2005-07-25"">
	<meta name=""dc.date.modified"" content=""2005-07-25"">
	<meta name=""dc.date.created"" content=""2005-07-25"">
	<title>#language.PWGSC# - #language.EsqGravingDockCaps# - #language.vesselDetail#</title>">

<cfif isDefined("form.vesselID")><cfinclude template="#RootDir#includes/build_form_struct.cfm"></cfif>
<cfinclude template="#RootDir#includes/restore_params.cfm">

<cfif NOT IsDefined('url.vesselID') OR NOT IsNumeric(url.vesselID)>
	<cflocation addtoken="no" url="booking.cfm?lang=#lang#">
</cfif>

<cflock timeout="60" throwontimeout="No" type="exclusive" scope="session">
	<cfset Session.Flow.VesselID = URL.VesselID>
</cflock>

<cfquery name="getVesselDetail" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT Vessels.*, Companies.Name AS CompanyName, Companies.CompanyID
	FROM  Vessels INNER JOIN Companies ON Vessels.CompanyID = Companies.CompanyID
	WHERE VesselID = #url.VesselID#
	AND Vessels.deleted = 0
</cfquery>

<cfif getVesselDetail.recordCount EQ 0>
	<cflocation addtoken="no" url="booking.cfm?lang=#lang#">
</cfif>

<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

		<!-- BREAD CRUMB BEGINS | DEBUT DE LA PISTE DE NAVIGATION -->
		<p class="breadcrumb">
			<cfinclude template="/clf20/ssi/bread-pain-eng.html"><cfinclude template="#RootDir#includes/bread-pain-#lang#.cfm">&gt;
			<CFOUTPUT>
			<CFIF IsDefined('Session.AdminLoggedIn') AND Session.AdminLoggedIn eq true>
				<A href="#RootDir#text/admin/menu.cfm?lang=#lang#">#language.Admin#</A> &gt;
			<CFELSE>
				<a href="#RootDir#text/booking/booking.cfm?lang=#lang#">#language.welcomePage#</a> &gt;
			</CFIF>
			#language.vesselDetail#
			</CFOUTPUT>
		</p>
		<!-- BREAD CRUMB ENDS | FIN DE LA PISTE DE NAVIGATION -->
		<div class="colLayout">
		<cfinclude template="#RootDir#includes/left-menu-gauche-eng.cfm">
			<!-- CONTENT BEGINS | DEBUT DU CONTENU -->
			<div class="center">
				<CFOUTPUT query="getVesselDetail">
				<h1><a name="cont" id="cont">
					<!-- CONTENT TITLE BEGINS | DEBUT DU TITRE DU CONTENU -->
					<CFOUTPUT>#language.detailsFor# #Name#</CFOUTPUT>
					<!-- CONTENT TITLE ENDS | FIN DU TITRE DU CONTENU -->
					</a></h1>
				
					<CFINCLUDE template="#RootDir#includes/user_menu.cfm"><br>
				
					<table align="center">
						<tr>
							<td id="vessel">#language.vessel#:</td>
							<td headers="vessel">#name#</td>
						</tr>
						<!---<tr>
							<td>Owner:</td>
							<td>#userName#</td>
						</tr>--->
						<tr>
							<td id="Company">#language.Company#:</td>
							<td headers="Company">#companyname#</td>
						</tr>
						<tr>
							<td id="Length">#language.Length#:</td>
							<td headers="Length">#length# m</td>
						</tr>
						<tr>
							<td id="Width">#language.Width#:</td>
							<td headers="Width">#width# m</td>
						</tr>
						<tr>
							<td id="BlockSetup">#language.BlockSetup#:</td>
							<td headers="BlockSetup">#blocksetuptime# #language.days#</td>
						</tr>
						<tr>
							<td id="BlockTeardown">#language.BlockTeardown#:</td>
							<td headers="BlockTeardown">#blockteardowntime# #language.days#</td>
						</tr>
						<tr>
							<td id="LloydsID">#language.LloydsID#:</td>
							<td headers="LloydsID">#lloydsid#</td>
						</tr>
						<tr>
							<td id="Tonnage">#language.Tonnage#:</td>
							<td headers="Tonnage">#tonnage# #language.tonnes#</td>
						</tr>
						<tr>
							<td id="anon">#language.anon#:</td>
							<td headers="anon"><cfif anonymous>#language.yes#<cfelse>#language.no#</cfif></td>
						</tr>
					</table>
				
					<BR>
					<div align="center">
						<cfif #Session.ReadOnly# EQ "1"><cfelse>
						<a href="editVessel.cfm?lang=#lang#&amp;vesselID=#url.vesselID#" class="textbutton">#language.EditVessel#</a>
						<a href="delVessel.cfm?lang=#lang#&amp;vesselID=#url.vesselID#" class="textbutton">#language.DeleteVessel#</a>
						</cfif>
						<!---<a href="booking.cfm?lang=#lang#&amp;CompanyID=#getVesselDetail.companyID#" class="textbutton">#language.Back#</a>--->
					</div>
				</CFOUTPUT>

			</div>

		<!-- CONTENT ENDS | FIN DU CONTENU -->
		</div>
<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">
