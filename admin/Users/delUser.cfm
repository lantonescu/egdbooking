<cfhtmlhead text="
	<meta name=""dcterms.title"" content=""PWGSC - ESQUIMALT GRAVING DOCK - Delete User"">
	<meta name=""keywords"" content="""" />
	<meta name=""description"" content="""" />
	<meta name=""dcterms.description"" content="""" />
	<meta name=""dcterms.subject"" content="""" />
	<title>PWGSC - ESQUIMALT GRAVING DOCK - Delete User</title>">
	<cfset request.title ="Delete User">
<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

<cflock scope="session" throwontimeout="no" type="readonly" timeout="60">
	<cfquery name="getUserList" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT UID, LastName + ', ' + FirstName AS UserName
		FROM Users
		WHERE UID <> <cfqueryparam value="#session.UID#" cfsqltype="cf_sql_integer" />
		AND Deleted = 0
		ORDER BY LastName
	</cfquery>
</cflock>

<cfquery name="companyUsers" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT companies.CID, companies.name AS CompanyName, users.UID, lastname + ', ' + firstname AS UserName
	FROM Users INNER JOIN UserCompanies ON Users.UID = UserCompanies.UID
		 INNER JOIN Companies ON UserCompanies.CID = Companies.CID
	WHERE Users.Deleted = 0 AND Companies.Deleted = 0 AND Companies.Approved = 1
			AND UserCompanies.Deleted = 0 AND UserCompanies.Approved = 1
	ORDER BY Companies.Name, Users.lastname, Users.firstname
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
		

				<h1 id="wb-cont">
					<!-- CONTENT TITLE BEGINS | DEBUT DU TITRE DU CONTENU -->
					Delete User
					<!-- CONTENT TITLE ENDS | FIN DU TITRE DU CONTENU -->
					</h1>

				<CFINCLUDE template="#RootDir#includes/admin_menu.cfm">

				<cfparam name="form.UID" default="">
				<cfinclude template="#RootDir#includes/restore_params.cfm">

				<cfif isDefined("form.CID")>
					<cfset variables.CID = #form.CID#>
				<cfelse>
					<cfset variables.CID = 0>
				</cfif>
				<cfif isDefined("form.UID")>
					<cfset variables.UID = #form.UID#>
				<cfelse>
					<cfset variables.UID = 0>
				</cfif>

				<cfif IsDefined("Session.Return_Structure")>
					<!--- Populate the Variables Structure with the Return Structure.
							Also display any errors returned --->
					<cfinclude template="#RootDir#includes/getStructure.cfm">
				</cfif>

				<cfform action="delUser_confirm.cfm?lang=#lang#" method="post" id="delUserForm">
				<div>
					Company: <br />
					<CF_TwoSelectsRelated
								QUERY="companyUsers"
								id1="CID"
								id2="UID"
								DISPLAY1="CompanyName"
								DISPLAY2="UserName"
								VALUE1="CID"
								VALUE2="UID"
								SIZE1="1"
								SIZE2="1"
								htmlBETWEEN="<br />User:<br />"
								AUTOSELECTFIRST="Yes"
								EMPTYTEXT1="(choose a company)"
								EMPTYTEXT2="(choose a user)"
								DEFAULT1 ="#variables.CID#"
								DEFAULT2 ="#variables.UID#"
								FORMNAME="delUserForm">
					<!--a href="javascript:EditSubmit('delUserForm');" class="textbutton">Submit</a-->
          <input type="submit" name="submitForm" value="Delete" class="button-accent button" />
          <cfoutput><a href="#RootDir#admin/menu.cfm?lang=#lang#" class="textbutton">Cancel</a></cfoutput>
				</div>
				</cfform>


<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">
