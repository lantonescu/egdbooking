<cfquery name="getVessel" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	SELECT	Name
	FROM	Vessels
	WHERE	VNID = <cfqueryparam value="#Form.VNID#" cfsqltype="cf_sql_integer" />
</cfquery>
<cfquery name="delVessel" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
	UPDATE Vessels
	SET Deleted = 1
	WHERE VNID = <cfqueryparam value="#Form.VNID#" cfsqltype="cf_sql_integer" />
</cfquery>

<cfif lang EQ "eng">
	<cfset Session.Success.Breadcrumb = "Delete Vessel">
	<cfset Session.Success.Title = "Delete Vessel">
	<cfset Session.Success.Message = "The vessel, <strong>#getVessel.Name#</strong>, has been deleted.">
	<cfset Session.Success.Back = "Back to Booking Home">
<cfelse>
	<cfset Session.Success.Breadcrumb = "Suppression de navire">
	<cfset Session.Success.Title = "Suppression de navire">
	<cfset Session.Success.Message = "Le navire, <strong>#getVessel.Name#</strong>, a &eacute;t&eacute; supprim&eacute;.">
	<cfset Session.Success.Back = "Retour &agrave; Accueil&nbsp;- R&eacute;servation">
</cfif>
<cfset Session.Success.Link = "#RootDir#reserve-book/reserve-booking.cfm?lang=#lang#">
<cflocation addtoken="no" url="#RootDir#comm/succes.cfm?lang=#lang#">
