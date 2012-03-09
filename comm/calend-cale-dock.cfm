<cfif IsDefined("Session.Form_Structure")>
	<cfset StructDelete(Session, "Form_Structure")>
</cfif>
<cfif structKeyExists(form, 'm-m')>
	<cfset url['m-m'] = form['m-m'] />
</cfif>
<cfif structKeyExists(form, 'a-y')>
	<cfset url['a-y'] = form['a-y'] />
</cfif>

<cfif lang EQ "eng">
	<cfset language.description = "Allows user to view all bookings in the drydock in a given month.">
	<cfset language.keywords = "calendar, 1 month view, one month view, drydock side">
<cfelse>
	<cfset language.description = "Permet &agrave; l'utilisateur de voir toutes les r&eacute;servations concernant la cale s&egrave;che pour un mois donn&eacute;.">
	<cfset language.keywords = "Calendrier, visualisation d'un mois, visualisation de 1 mois, secteur de la cale s&egrave;che">
</cfif>

<cfhtmlhead text="
	<meta name=""dc.title"" content=""#language.drydockCalendar# - #language.esqGravingDock# - #language.PWGSC#"" />
	<meta name=""keywords"" content=""#Language.masterKeywords#, #language.keywords#"" />
	<meta name=""description"" content=""#language.description#"" />
	<meta name=""dc.subject"" scheme=""gccore"" content=""#Language.masterSubjects#"" />
	<title>#language.drydockCalendar# - #language.esqGravingDock# - #language.PWGSC#</title>">
<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

		<!-- BREAD CRUMB BEGINS | DEBUT DE LA PISTE DE NAVIGATION -->
		<p class="breadcrumb">
			<cfinclude template="#CLF_Path#/clf20/ssi/bread-pain-#lang#.html"><cfinclude template="#RootDir#includes/bread-pain-#lang#.cfm">&gt;
			<cfoutput>
			<CFIF IsDefined('Session.AdminLoggedIn') AND Session.AdminLoggedIn eq true>
				<a href="#RootDir#admin/menu.cfm?lang=#lang#">#language.Admin#</a> &gt;
			</CFIF>
			#language.drydockCalendar#
			</cfoutput>
		</p>
		<!-- BREAD CRUMB ENDS | FIN DE LA PISTE DE NAVIGATION -->
		<div>
			<!-- CONTENT BEGINS | DEBUT DU CONTENU -->
			<div>
				<h1><a name="cont" id="cont">
					<!-- CONTENT TITLE BEGINS | DEBUT DU TITRE DU CONTENU -->
					<cfoutput>#language.drydockCalendar#</cfoutput>
					<!-- CONTENT TITLE ENDS | FIN DU TITRE DU CONTENU -->
					</a></h1>

				<CFIF IsDefined('Session.AdminLoggedIn') AND Session.AdminLoggedIn eq true>
					<CFINCLUDE template="#RootDir#includes/admin_menu.cfm">
				<CFELSE>
					<CFINCLUDE template="#RootDir#includes/user_menu.cfm">
				</CFIF>

				<CFINCLUDE template="includes/calendar_variables.cfm">
				<cfset firstdayofbunch = CreateDate(url['a-y'], url['m-m'], 1)>
				<cfset lastdayofbunch = CreateDate(url['a-y'], url['m-m'], DaysInMonth(firstdayofbunch))>
				<cfquery name="GetEvents" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
					SELECT 	Bookings.BRID, Status,
						StartDate, EndDate,
						Section1, Section2, Section3,
						Vessels.Name AS VesselName, Vessels.VNID,
						Vessels.Anonymous
					FROM	Bookings
						INNER JOIN	Docks ON Bookings.BRID = Docks.BRID
						INNER JOIN	Vessels ON Bookings.VNID = Vessels.VNID
					WHERE	StartDate <= <cfqueryparam value="#lastdayofbunch#" cfsqltype="cf_sql_date" />
						AND EndDate >= <cfqueryparam value="#firstdayofbunch#" cfsqltype="cf_sql_date" />
						AND	Bookings.Deleted = '0'
						AND	Vessels.Deleted = '0'
          ORDER BY 
          CASE Status
            WHEN 'P' THEN 3
            WHEN 'PT' THEN 3
            WHEN 'PC' THEN 3
            WHEN 'T' THEN 2
            ELSE 1
          END
				</cfquery>

				<CFIF url['m-m'] eq 1>
					<CFSET prevmonth = 12>
					<CFSET prevyear = url['a-y'] - 1>
				<CFELSE>
					<CFSET prevmonth = url['m-m'] - 1>
					<CFSET prevyear = url['a-y']>
				</CFIF>

				<CFIF url['m-m'] eq 12>
					<CFSET nextmonth = 1>
					<CFSET nextyear = url['a-y'] + 1>
				<CFELSE>
					<CFSET nextmonth = url['m-m'] + 1>
					<CFSET nextyear = url['a-y']>
				</CFIF>

				<CFINCLUDE template="includes/calendar_core.cfm">

			</div>
			<!-- CONTENT ENDS | FIN DU CONTENU -->
		</div>
<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">
