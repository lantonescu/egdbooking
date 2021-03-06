<cfinclude template="#RootDir#includes/errorMessages.cfm">
<cfif lang EQ "eng">
	<cfset language.drydockRequest = "Submit Drydock Booking Request">
	<cfset language.keywords = language.masterKeywords & ", Drydock Booking Request">
	<cfset language.description = "Allows user to submit a new booking request, drydock section.">
	<cfset language.subjects = language.masterSubjects & "">
	<cfset language.daysToBook = "Enter the number of days the vessel needs to be booked for.  The system will locate the first available date period.">
	<cfset language.numDays = "Number of days">
	<cfset language.reset = "reset">
	<cfset language.or = "or">
	<cfset language.numDaysError = "Please enter the desired number of days.">
	<cfset language.dateRange = "Date Range">
	<cfset language.requestedStatus = "Requested Status">

<cfelse>
	<cfset language.drydockRequest = "Pr&eacute;sentation d'une demande de r&eacute;servation de la cale s&egrave;che">
	<cfset language.keywords = language.masterKeywords & ", demanmde de r&eacute;servatino de la cale s&egrave;che">
	<cfset language.description = "Permet &agrave; l'utilisateur de pr&eacute;senter une nouvelle demande de r&eacute;servation sur le site Web de la cale s&egrave;che d'Esquimalt - section de la cale s&egrave;che.">
	<cfset language.subjects = language.masterSubjects & "">
	<cfset language.daysToBook = "Veuillez entrer le nombre de jours de r&eacute;servation requis pour le navire. Le syst&egrave;me trouvera la prochaine p&eacute;riode libre.">
	<cfset language.numDays = "Nombre de jours">
	<cfset language.reset = "R&eacute;initialiser">
	<cfset language.or = "ou">
	<cfset language.numDaysError = "Veuillez entrer le nombre de jours voulus.">
	<cfset language.dateRange = "P&eacute;riode&nbsp;">
	<cfset language.requestedStatus = "&Eacute;tat demand&eacute;">
</cfif>
<cfoutput>

<cfsavecontent variable="js">
	<meta name="dcterms.title" content="#language.drydockRequest# - #language.esqGravingDock# - #language.PWGSC#" />
	<meta name="keywords" content="#language.keywords#" />
	<meta name="description" content="#language.description#" />
	<meta name="dcterms.description" content="#language.description#" />
	<meta name="dcterms.subject" title="gccore" content="#language.subjects#" />
	<title>#language.drydockRequest# - #language.esqGravingDock# - #language.PWGSC#</title>
</cfsavecontent>
<cfhtmlhead text="#js#">
<cfset request.title = language.drydockRequest />
<cfinclude template="#RootDir#includes/tete-header-#lang#.cfm">

<cflock scope="session" throwontimeout="no" type="readonly" timeout="60">
	<cfquery name="companyVessels" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
		SELECT	VNID, vessels.Name AS VesselName, companies.CID, companies.Name AS CompanyName
		FROM 	Vessels INNER JOIN Companies ON Vessels.CID = Companies.CID
				INNER JOIN UserCompanies ON Companies.CID = UserCompanies.CID
				INNER JOIN Users ON UserCompanies.UID = Users.UID
		WHERE 	Users.UID = <cfqueryparam value="#session.UID#" cfsqltype="cf_sql_integer" />
		AND		UserCompanies.Approved = 1
		AND		UserCompanies.Deleted = 0
		AND		Companies.Deleted = '0'
		AND		Companies.Approved = 1
		AND		Vessels.Deleted = '0'
		ORDER BY Companies.Name, Vessels.Name
	</cfquery>
</cflock>

<cfparam name="Variables.CID" default="">
<cfparam name="Variables.VNID" default="">
<cfparam name="Variables.startDate" default="#DateAdd('d', 1, PacificNow)#">
<cfparam name="Variables.endDate" default="#DateAdd('d', 3, PacificNow)#">
<cfparam name="Variables.numDays" default="">
<cfparam name="Variables.status" default="">
<cfparam name="err_ddstart" default="">
<cfparam name="err_ddend" default="">
<cfparam name="err_ddstart2" default="">
<cfparam name="err_ddend2" default="">
<cfparam name="err_numdays" default="">
<cfparam name="err_ddvess" default="">
<cfparam name="err_ddvess2" default="">

<cflock scope="session" throwontimeout="no" type="readonly" timeout="60">
	<cfif IsDefined("URL.VNID")>
		<cfset Variables.VNID = URL.VNID>
		<cfquery name="GetCompany" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
			SELECT	CID
			FROM	Vessels
			WHERE	Vessels.VNID = <cfqueryparam value="#Variables.VNID#" cfsqltype="cf_sql_integer" />
		</cfquery>
		<cfset Variables.CID = GetCompany.CID>
	<cfelseif IsDefined("URL.CID")>
		<cfset Variables.CID = URL.CID>
		<cfset Variables.VNID = "">
	</cfif>
	<cfif IsDefined("URL.Date")>
		<cfset Variables.StartDate = URL.Date>
		<cfset Variables.EndDate = DateAdd('d', 3, Variables.StartDate)>
	</cfif>
</cflock>

				<h1 id="wb-cont">#language.drydockRequest#</h1>

				<CFINCLUDE template="#RootDir#includes/user_menu.cfm">

				<cfinclude template="#RootDir#includes/getStructure.cfm">
				<cfinclude template="#RootDir#includes/restore_params.cfm">
				<cfif isDefined("session.form_structure")>
          <cfif isDate(form.startDate) and isDate(form.endDate)>
            <cfset Variables.startDate = form.startDate>
            <cfset Variables.endDate = form.endDate>
          </cfif>
					<cfset Variables.status = form.status>
          <cfif structKeyExists(session.form_structure, 'bookingByRange_CID')>
            <cfset variables.CID = form.bookingByRange_CID />
            <cfset variables.VNID = form.bookingByRange_VNID />
          </cfif>
				</cfif>

        <cfif not #error("startDateA")# EQ "">
              <cfset err_ddstart = "form-alert" />
        </cfif>
        <cfif not #error("endDateA")# EQ "">
              <cfset err_ddend = "form-alert" />
        </cfif>
        <cfif not #error("StartDateB")# EQ "">
              <cfset err_ddstart2 = "form-alert" />
        </cfif>
        <cfif not #error("EndDateB")# EQ "">
              <cfset err_ddend2 = "form-alert" />
        </cfif>
        <cfif not #error("numDays")# EQ "">
              <cfset err_numdays = "form-alert" />
        </cfif>
        <cfif not #error("booking_VNIDA")# EQ "">
              <cfset err_ddvess = "form-alert" />
        </cfif>
        <cfif not #error("bookingByRange_VNIDB")# EQ "">
              <cfset err_ddvess2 = "form-alert" />
        </cfif>


				<p>#language.enterInfo#  #language.dateInclusive#</p>
				<form action="#RootDir#reserve-book/caledemande-dockrequest_confirm.cfm?lang=#lang#" method="post" id="booking">
					<fieldset>
            <legend>#language.booking#</legend>
            <p>#language.requiredFields#</p>

            <div class="#err_ddvess#">
              <label for="booking_VNID">
                <abbr title="#language.required#" class="required">*</abbr>&nbsp;#language.vessel#:<span class="form-text">#error('booking_VNIDA')#</span>
              </label>
              <select id="booking_VNID" name="booking_VNID">
                <option value="">(#language.chooseVessel#)</option>
                <cfloop query="companyVessels">
                  <cfset selected = "" />
                  <cfif companyVessels.VNID eq variables.VNID>
                    <cfset selected = "selected=""selected""" />
                  </cfif>
                  <option value="#companyVessels.VNID#" #selected#>#companyVessels.VesselName#</option>
                </cfloop>
              </select>
              
            </div>

						<div class="#err_ddstart#">
              <label for="startDateA">
                <abbr title="#language.required#" class="required">*</abbr>&nbsp;#language.StartDate#:<br />
                <small><abbr title="#language.dateformexplanation#">#language.dateform#</abbr></small><span class="form-text">#error('StartDateA')#</span>
              </label>
              <input id="startDateA" name="startDate" class="datepicker startDate" type="text" size="15" maxlength="10"  />
              
						</div>

						<div class="#err_ddend#">
             <label for="endDateA">
               <abbr title="#language.required#" class="required">*</abbr>&nbsp;#language.EndDate#:<br />
               <small><abbr title="#language.dateformexplanation#">#language.dateform#</abbr></small><span class="form-text">#error('EndDateA')#</span>
             </label>
              <input id="endDateA" name="endDate" class="datepicker endDate" type="text" size="15" maxlength="10" value="#DateFormat(endDate, 'mm/dd/yyyy')#"  />
              
						</div>

						<div>
              <label for="status">
                <abbr title="#language.required#" class="required">*</abbr>&nbsp;#language.requestedStatus#:
              </label>
              <select id="status" name="status" >
                <option value="tentative" <cfif isDefined("form.status") AND form.status EQ "tentative">selected="selected"</cfif>>#language.tentative#</option>
                <option value="confirmed" <cfif isDefined("form.status") AND form.status EQ "confirmed">selected="selected"</cfif>>#language.confirmed#</option>
              </select>
						</div>

            <div>
              <input type="submit" value="#language.Submit#" class="button button-accent" />
            </div>
					</fieldset>
        </form>

				<p style="text-align: center"><strong>#language.or#</strong></p>
				<p>#language.daysToBook#  #language.dateInclusive#</p>

				<form action="#RootDir#reserve-book/caledemande-dockrequest_confirm2.cfm?lang=#lang#" method="post" id="bookingByRange">
					<fieldset>
            <legend>#language.booking#</legend>
            <p>#language.requiredFields#</p>

            <div class="#err_ddvess2#">
              <label for="bookingByRange_VNID">
                <abbr title="#language.required#" class="required">*</abbr>&nbsp;#language.vessel#:
                <span class="form-text">#error('bookingByRange_VNIDB')#</span>
              </label>
              <select id="bookingByRange_VNID" name="bookingByRange_VNID">
                <option value="">(#language.chooseVessel#)</option>
                <cfloop query="companyVessels">
                  <cfset selected = "" />
                  <cfif companyVessels.VNID eq variables.VNID>
                    <cfset selected = "selected=""selected""" />
                  </cfif>
                  <option value="#companyVessels.VNID#" #selected#>#companyVessels.VesselName#</option>
                </cfloop>
              </select>
              
            </div>

            <div class="#err_ddstart2#">
							<label for="StartDateB">
                <abbr title="#language.required#" class="required">*</abbr>&nbsp;#language.StartDate#:
                <br /><small><abbr title="#language.dateformexplanation#">#language.dateform#</abbr></small><span class="form-text">#error('StartDateB')#</span>
              </label>
							<input id="StartDateB" name="startDate" type="text" class="datepicker startDate" value="#DateFormat(startDate, 'mm/dd/yyyy')#" size="15" maxlength="10" />
              
            </div>

            <div class="#err_ddend2#">
              <label for="EndDateB">
                <abbr title="#language.required#" class="required">*</abbr>&nbsp;#language.EndDate#:
                <br />
                <small><abbr title="#language.dateformexplanation#">#language.dateform#</abbr></small><span class="form-text">#error('EndDateB')#</span>
              </label>
              <input id="EndDateB" name="endDate" type="text" class="datepicker endDate" value="#DateFormat(endDate, 'mm/dd/yyyy')#" size="15" maxlength="10" />
              
            </div>

            <div class="#err_numdays#">
              <label for="NumDays">
                <abbr title="#language.required#" class="required">*</abbr>&nbsp;#language.NumDays#:
                <span class="form-text">#error('NumDays')#</span>
              </label>
              <input id="NumDays" type="text" name="numDays" value="#Variables.numDays#"  />
              
            </div>

						<div>
              <label for="statusB">
                <abbr title="#language.required#" class="required">*</abbr>&nbsp;#language.requestedStatus#:
              </label>
              <select id="statusB" name="status" >
                <option value="tentative" <cfif isDefined("form.status") AND form.status EQ "tentative">selected="selected"</cfif>>#language.tentative#</option>
                <option value="confirmed" <cfif isDefined("form.status") AND form.status EQ "confirmed">selected="selected"</cfif>>#language.confirmed#</option>
              </select>
						</div>

            <input type="submit" class="button button-accent" value="#language.Submit#" />
					</fieldset>
				</form>

		<!-- CONTENT ENDS | FIN DU CONTENU -->
</cfoutput>

<cfinclude template="#RootDir#includes/foot-pied-#lang#.cfm">

