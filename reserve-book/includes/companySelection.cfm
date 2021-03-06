<cfquery name="companies" datasource="#DSN#" username="#dbuser#" password="#dbpassword#">
  SELECT DISTINCT 
    Companies.CID, 
    Companies.Name
  FROM Companies
  INNER JOIN UserCompanies 
    ON UserCompanies.CID = Companies.CID 
    AND UserCompanies.UID = <cfqueryparam value="#Session.UID#" cfsqltype="cf_sql_integer" /> 
  WHERE UserCompanies.Approved = 1 
  AND UserCompanies.Deleted = 0
  ORDER BY Companies.Name
</cfquery>

<cfparam name="session.CID" default="#companies.CID#" />
<cfparam name="current_company" default="#companies.name#" />

<cfif structKeyExists(url, 'CID') and listFind(valueList(companies.CID), url.CID)>
  <cfset session['CID'] = url.CID />
</cfif>

<cfif companies.recordcount gt 1>
  <cfoutput>
    <form action="#RootDir#reserve-book/reserve-booking.cfm" method="get">
      <fieldset>
        <legend>#language.companySelection#</legend>
        <label for="CID">#language.companies#</label>
        <select id="CID" name="CID">
          <cfloop query="companies">
            <cfset selected = "" />
            <cfif session['CID'] eq companies.CID>
              <cfset selected = "selected=""selected""" />
              <cfset current_company = companies.name />
            </cfif>
            <option value="#companies.CID#" #selected#>#companies.name#</option>
          </cfloop>
        </select>
        <input type="hidden" name="lang" value="#lang#" />
        <input type="submit" class="button button-accent" value="#language.select#" />
      </fieldset>
    </form>
  </cfoutput>
</cfif>
