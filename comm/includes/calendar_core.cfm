<cfoutput>

<div class="selector">
  <form id="dateSelect" action="#CGI.script_name#?lang=#lang#" method="post">
    <fieldset>
      <legend>#language.dateSelect#</legend>
      <label for="month">#language.month#</label>
      <select name="m-m" id="month">
        <CFLOOP index="i" from="1" to="12">
          <option value="#i#" <cfif i eq url['m-m']>selected="selected"</cfif>>#LSDateFormat(CreateDate(2005, i, 1), 'mmmm')#</option>
        </CFLOOP>
      </select>
      <br />
      <label for="year">#language.year#</label>
      <select name="a-y" id="year">
        <CFLOOP index="i" from="-5" to="25">
          <cfset year = #DateFormat(DateAdd('yyyy', i, PacificNow), 'yyyy')# />
          <option <cfif year eq url['a-y']>selected="selected"</cfif>>#year#</option>
        </CFLOOP>
      </select>
      <br />
      <input type="submit" value="Go" />
    </fieldset>
  </form>
</div>
</cfoutput>

<cfif find("jet", cgi.script_name) EQ 0>
  <cfinclude template="#RootDir#comm/includes/dock_key.cfm" />
<cfelse>
  <cfinclude template="#RootDir#comm/includes/jetty_key.cfm" />
</cfif>

<h2><cfoutput>#LSDateFormat(CreateDate(url['a-y'], url['m-m'], 1), 'mmmm')# #url['a-y']#</cfoutput></h2>

<cfoutput>
<div class="selector">
  <a href="#cgi.script_name#?lang=#lang#&amp;m-m=#prevmonth#&amp;a-y=#prevyear#" class="previousLink">#language.prev#</a>
  <a href="#cgi.script_name#?lang=#lang#&amp;m-m=#nextmonth#&amp;a-y=#nextyear#" class="nextLink">#language.next#</a>
</div>
</cfoutput>

<!--- Create an array for the days of the month --->
<cfset DaysofMonth = ArrayNew(1)>
<cfloop index="kounting" from="1" to="31" step="1">
	<cfif isDate(url['a-y'] & "/" & url['m-m'] & "/" & kounting) eq "yes">
		<cfset DaysofMonth[kounting] = #kounting#>
	</cfif>
</cfloop>
<cfset LastDayofMonth = ArrayMax(DaysofMonth)>

<!--- Find the day of the week for the first day of the month, used for finding events in the query --->
<cfset FirstDay = CreateDate(url['a-y'], url['m-m'], 1)>
<cfset LastDay = CreateDate(url['a-y'], url['m-m'], LastDayofMonth)>
<cfset CurDayofWeek = LSDateFormat(FirstDay, "dddd")>

<table class="basic calendar" id="calendar<cfoutput>#url['m-m']#</cfoutput>" 
summary="<cfoutput>#language.calendar#</cfoutput>">
	<!--- Output the days of the week at the top of the calendar --->
	<tr>
		<cfloop index="doh" from="1" to="#ArrayLen(DaysofWeek)#" step="1">
		<cfoutput>
			<CFSET dummydate = CreateDate(2005, 5, doh)>
			<th scope="col">#LSDateFormat(dummydate, 'dddd')#</th>
		</cfoutput>
		</cfloop>
	</tr>

	<!--- Output all the weeks in the calendar --->
	<cfset DateCounter = 0>
	<cfset WeekCounter = 0>
	<cfset FirstDay = "No">
	<cfloop condition="Variables.DateCounter LT ArrayLen(DaysofMonth)">
	<tr class="week">
		<cfset WeekCounter = WeekCounter + 1>
		<cfloop index="kounter" from="1" to="#ArrayLen(DaysofWeek)#" step="1">
			<cfif WeekCounter EQ 1>
				<cfif Variables.CurDayofWeek EQ DaysofWeek[kounter]>
					<cfset DateCounter = DateCounter + 1>
					<cfset FirstDay = "Yes">
				<cfelse>
					<cfif FirstDay IS "Yes">
						<cfset DateCounter = DateCounter + 1>
					</cfif>
				</cfif>
			<cfelse>
				<cfset DateCounter = DateCounter + 1>
			</cfif>
			<td>
				<cfif not (Variables.DateCounter IS 0) AND NOT (Variables.DateCounter GT Variables.LastDayofMonth)>
					<cfset taday = DateFormat(CreateDate(url['a-y'], url['m-m'], DaysofMonth[DateCounter]), "yyyy-MM-dd")>
					<cfoutput><a href="detail.cfm?lang=#lang#&amp;date=#taday#" title="#DateFormat(taday, 'dddd')# #taday# #language.details#" rel="nofollow"><strong>#DaysofMonth[DateCounter]#</strong></a></cfoutput>

					<cfquery name="GetEventsonDay" dbtype="query">
						SELECT 	BRID, VesselName, VNID,
								Anonymous,
								Section1, Section2, Section3,
								Status
						FROM	GetEvents
						WHERE	<cfqueryparam value="#taday#" cfsqltype="cf_sql_date"> >= StartDate
							AND <cfqueryparam value="#taday#" cfsqltype="cf_sql_date"> <= EndDate
					</cfquery>

					<!--- Doing the craaaazeh query math.  Need to combine records and count them all!
						Using Left and my magicnumber to make it all pretty, too.
						Dance wit me!
						Lois Chan, May 2005 --->

					<CFSET sec1.num = 0>
					<CFSET sec2.num = 0>
					<CFSET sec3.num = 0>
					<CFSET tent.num = 0>
					<CFSET pend.num = 0>

					<CFSET sec1.name = "">
					<CFSET sec2.name = "">
					<CFSET sec3.name = "">
					<CFSET sec1.BRID = "">
					<CFSET sec2.BRID = "">
					<CFSET sec3.BRID = "">
					<CFSET tent.name = "">
					<CFSET pend.name = "">

					<CFSET sec1.maint = false>
					<CFSET sec2.maint = false>
					<CFSET sec3.maint = false>

					<cfoutput query="GetEventsonDay">
						<!---check if ship belongs to user's company--->
						<cflock timeout="20" throwontimeout="no" type="READONLY" scope="SESSION">
							<cfquery name="userVessel#VNID#" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
								SELECT	Vessels.VNID
								FROM	Users INNER JOIN UserCompanies ON Users.UID = UserCompanies.UID
										INNER JOIN Vessels ON UserCompanies.CID = Vessels.CID
								WHERE	Users.UID = <cfqueryparam value="#Session.UID#" cfsqltype="cf_sql_integer" /> AND VNID = <cfqueryparam value="#VNID#" cfsqltype="cf_sql_integer" />
									AND UserCompanies.Approved = 1 AND Users.Deleted = 0 AND UserCompanies.Deleted = 0
							</cfquery>
						</cflock>

						<cfset Variables.countQName = "userVessel" & #VNID# & ".recordCount">
						<cfset Variables.count = EVALUATE(countQName)>

						<CFSCRIPT>

						if (Status eq 'm') {  // maintenance
							for (frika = 1; frika LTE 3; frika = frika + 1) {
								if (Evaluate('Section' & frika)) {
									Evaluate('sec' & frika).maint = true;
									Evaluate('sec' & frika).name = "";
								}
							}

						} else if (Status eq 'c') {  // confirmed
							for (frika = 1; frika LTE 3; frika = frika + 1) {
								buzzard = 'sec' & frika;
								if (Evaluate('Section' & frika) AND (Evaluate(buzzard).maint eq false)) {
									Evaluate(buzzard).num = Evaluate(buzzard).num + 1;
									if (Evaluate(buzzard).num eq 1) {
										Evaluate(buzzard).name = VesselName;
										Evaluate(buzzard).BRID = BRID;
									} else {
										Evaluate(buzzard).name = Evaluate(buzzard).num & " #language.bookings#";
									}
								}
							}
						} else if (Status eq 't') {
							tent.num = tent.num + 1;
							if (tent.num eq 1) {
								if (Anonymous AND (NOT IsDefined('session.adminLoggedIn')) AND Variables.count eq 0) {
									tent.name = "#language.deepsea#";
								} else {
									tent.name = VesselName;
								}
							} else {
								tent.name = tent.num & " #language.tentative#";
							}
						} else if (Status eq 'p') {  // pending
							pend.num = pend.num + 1;
							if (pend.num eq 1) {
								pend.name = "#language.pending#";
							} else {
								pend.name = pend.num & " #language.pending#";
							}
						} else {  // unrecognised character;
						}

						</CFSCRIPT>
					</cfoutput>

					<cfoutput>

						<CFLOOP from="1" to="3" index="bloop">

							<CFSET sec = "sec" & #bloop#>
              <CFSET vessel_name = Evaluate(sec).name />
              <CFSET BRID = Evaluate(sec).BRID />

							<CFIF Evaluate(sec).maint eq true>
								<div class="maintenance"><a href="detail.cfm?lang=#lang#&amp;date=#taday###booking-#BRID#" class="maintenance" title="#DateFormat(taday, 'dddd')# #taday# #language.maintenance#"><span style="display: none" rel="nofollow">#taday#</span> #language.maintenance#</a></div>
							<CFELSEIF vessel_name neq "">
              <div class="vessel #sec#"><a href="detail.cfm?lang=#lang#&amp;date=#taday###booking-#BRID#" class="confirmed" title="#DateFormat(taday, 'dddd')# #taday# #vessel_name#" rel="nofollow"><span style="display: none">#taday#</span> #vessel_name#</a><a class="legend" href="###sec#"><sup>L#bloop#</sup></a></div>
							</CFIF>
						</CFLOOP>
						<cfif tent.num neq 0>
							<div><a href="detail.cfm?lang=#lang#&amp;date=#taday#" class="tentative" title="#DateFormat(taday, 'dddd')# #taday# #tent.name#" rel="nofollow"><span style="display: none">#taday#</span> #tent.name#</a><a href="##tentative" class="legend tentative"><sup>L4</sup></a></div>
						</cfif>
						<cfif pend.num neq 0>
							<div><a href="detail.cfm?lang=#lang#&amp;date=#taday#" class="pending" title="#DateFormat(taday, 'dddd')# #taday# #pend.name#" rel="nofollow"><span style="display: none">#taday#</span> #pend.name#</a><a href="##pending" class="legend pending"><sup><cfif sec3.name NEQ "">L5<cfelse>L3</cfif></sup></a></div>
						</cfif>
					</cfoutput>
				</cfif>
			</td>
		</cfloop>
	</tr>
	</cfloop>
</table>
