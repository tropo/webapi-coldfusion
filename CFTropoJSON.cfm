<!-- CFTropoJSON written by Shane Smith and Johnny Diggz (let's face it, mostly Shane) 
 	 This is presented as-is, and while we've tested it with Tropo Web-API, it's not 
	 officially supported so you're on your own :) -->

<!-- The following script will consume Tropo WebAPI JSON and make it digestible by ColdFusion -->

<cfscript>
function CFTropoJSON(content) {
theData=REReplace(tostring(content), "^\s*[[:word:]]*\s*\(\s*","");
theData=REReplace(theData, "\s*\)\s*$", "");
theData=DeserializeJSON(theData);
return theData; }
</cfscript>

<!-- The following puts Tropo WebAPI JSON into the variable "theJSON" -->

<CFSET theJSON=CFTropoJSON(GetHttpRequestData().content)>

<!-- 

	To evaluate variables inside theJSON payload, you address them the following way in ColdFusion:

	<CFOUTPUT>#theJSON.session.accountid#</CFOUTPUT> (gives you the Tropo accountID)
	
	additional helpful session object variables:
	
	theJSON.session.initialText (for inbound text messages)
	theJSON.session.from.id (gives you the caller id)
	theJSON.session.to.id (called id)
	theJSON.session.timestamp (gives you the date time in ISO 8601 UTC format: YYYY-MM-DDTHH:MM:SS.SSSZ)
	
	More info about Tropo session object here: https://www.tropo.com/docs/webapi/session.htm
	and the Tropo WebAPI docs: https://www.tropo.com/docs/webapi/new_tropo_web_api_overview.htm
	
-->