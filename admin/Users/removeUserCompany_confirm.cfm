<cfhtmlhead text="
	<meta name=""dcterms.title"" content=""PWGSC - ESQUIMALT GRAVING DOCK - Confirm Remove Company"">
	<meta name=""keywords"" content="""" />
	<meta name=""description"" content="""" />
	<meta name=""dcterms.description"" content="""" />
	<meta name=""dcterms.subject"" content="""" />
	<title>PWGSC - ESQUIMALT GRAVING DOCK - Confirm Remove Company</title>">
	<cfset request.title ="Confirm Remove Company">
<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

<cfif isDefined("form.UID")><cfinclude template="#RootDir#includes/build_form_struct.cfm"></cfif>
<cfinclude template="#RootDir#includes/restore_params.cfm">

<cfquery name="getCompany" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT	Name
	FROM	Companies
	WHERE	CID = <cfqueryparam value="#form.CID#" cfsqltype="cf_sql_integer" />
</cfquery>

<cfquery name="getUser" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT FirstName + ' ' + LastName AS UserName
	FROM Users
	WHERE UID = <cfqueryparam value="#form.UID#" cfsqltype="cf_sql_integer" />
</cfquery>

<!-- Start JavaScript Block -->
<script type="text/javascript">
/* <![CDATA[ */
function EditSubmit ( selectedform )
	{
	  document.forms[selectedform].submit();
	}
/* ]]> */
</script>
		
		<div class="colLayout">
			<div class="center">
				<h1 id="wb-cont">
					<!-- CONTENT TITLE BEGINS | DEBUT DU TITRE DU CONTENU -->
					Confirm Remove Company
					<!-- CONTENT TITLE ENDS | FIN DU TITRE DU CONTENU -->
					</h1>

				<CFINCLUDE template="#RootDir#includes/admin_menu.cfm">

				<cfif IsDefined("Session.Return_Structure")>
					<!--- Populate the Variables Structure with the Return Structure.
							Also display any errors returned --->
					<cfinclude template="#RootDir#includes/getStructure.cfm">
				</cfif>

				<cfoutput>
				<cfform action="removeUserCompany_action.cfm?lang=#lang#&UID=#form.UID#" method="post" id="remCompanyConfirmForm">
					<div style="text-align:center;">Are you sure you want to remove <strong>#getUser.UserName#</strong> from <strong>#getCompany.Name#</strong>?</div>

					<p><div style="text-align:center;">
						<!--a href="javascript:EditSubmit('remCompanyConfirmForm');" class="textbutton">Submit</a>
						<a href="editUser.cfm?UID=#form.UID#" class="textbutton">Cancel</a-->
						<input type="submit" name="submitForm" value="Remove" class="button-accent button" />
						<a href="editUser.cfm?lang=#lang#&UID=#form.UID#" class="textbutton">Cancel</a>
					</div></p>

					<input type="hidden" name="CID" value="#form.CID#" />
					<input type="hidden" name="UID" value="#form.UID#" />
				</cfform>
				</cfoutput>

			</div>
		<!-- CONTENT ENDS | FIN DU CONTENU -->
		</div>
<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">
