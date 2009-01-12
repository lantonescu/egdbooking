<cfhtmlhead text="
	<meta name=""dc.title"" content=""PWGSC - ESQUIMALT GRAVING DOCK - Delete Company"">
	<meta name=""keywords"" content="""" />
	<meta name=""description"" content="""" />
	<meta name=""dc.subject"" scheme=""gccore"" content="""" />
	<title>PWGSC - ESQUIMALT GRAVING DOCK - Delete Company</title>">
<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

<cflock scope="session" throwontimeout="no" type="readonly" timeout="60">
	<cfquery name="getCompanyList" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT CID, Name
	FROM Companies
	WHERE Approved = 1 AND Deleted = 0
	ORDER BY Name
	</cfquery>
</cflock>

<!---
<cflock scope="session" throwontimeout="no" type="readonly" timeout="60">
	<cfquery name="getCompanyList" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT CID, Name
		FROM Companies
		WHERE NOT EXISTS (SELECT CID
							FROM UserCompanies
							WHERE UserCompanies.CID = Companies.CID
							AND UserCompanies.Deleted = 0 AND UserCompanies.Approved = 1
							AND UserCompanies.UID = #session.UID#)
		AND Companies.Deleted = 0
		ORDER BY Name
	</cfquery>
</cflock>
--->

<cfinclude template="#RootDir#includes/restore_params.cfm">
<cfif isDefined("form.CID")>
	<cfset variables.CID = #form.CID#>
<cfelse>
	<cfset variables.CID = 0>
</cfif>

		<!-- BREAD CRUMB BEGINS | DEBUT DE LA PISTE DE NAVIGATION -->
		<p class="breadcrumb">
			<cfinclude template="#CLF_Path#/clf20/ssi/bread-pain-#lang#.html"><cfinclude template="#RootDir#includes/bread-pain-#lang#.cfm">&gt;
			<cfoutput>
			<CFIF IsDefined('Session.AdminLoggedIn') AND Session.AdminLoggedIn eq true>
				<a href="#RootDir#admin/menu.cfm?lang=#lang#">Admin</a> &gt;
			<CFELSE>
				 <a href="#RootDir#reserve-book/reserve-booking.cfm?lang=#lang#">Welcome Page</a> &gt;
			</CFIF>
			Delete Company
			</cfoutput>
		</p>
		<!-- BREAD CRUMB ENDS | FIN DE LA PISTE DE NAVIGATION -->
		<div class="colLayout">
		<cfinclude template="#RootDir#includes/left-menu-gauche-#lang#.cfm">
			<!-- CONTENT BEGINS | DEBUT DU CONTENU -->
			<div class="center">
				<h1><a name="cont" id="cont">
					<!-- CONTENT TITLE BEGINS | DEBUT DU TITRE DU CONTENU -->
					Delete Company
					<!-- CONTENT TITLE ENDS | FIN DU TITRE DU CONTENU -->
					</a></h1>

				<CFINCLUDE template="#RootDir#includes/admin_menu.cfm">

				<cfif IsDefined("Session.Return_Structure")>
					<!--- Populate the Variables Structure with the Return Structure.
							Also display any errors returned --->
					<cfinclude template="#RootDir#includes/getStructure.cfm">
				</cfif>

				<div style="text-align:center;">
					<cfform action="delCompany_confirm.cfm?lang=#lang#" method="post" id="delCompanyForm">
						<cfselect name="CID" query="getcompanyList" value="CID" display="name" selected="#variables.CID#"/>
						<input type="submit" name="submitForm" class="textbutton" value="Delete" />
						<cfoutput><a href="#RootDir#admin/menu.cfm?lang=#lang#" class="textbutton">Cancel</a></cfoutput>
					</cfform>
				</div>


			</div>
		<!-- CONTENT ENDS | FIN DU CONTENU -->
		</div>

<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">
