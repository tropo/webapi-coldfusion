<!-- 
	This sample app will answer a call, ask the caller to say or type their 4 digit year of birth,
     and then returns the value back to the caller.  Basically shows you how to consume a Tropo
     WebAPI JSON payload in ColdFusion, assign the payload to a variable and then access the values 
     inside a ColdFusion document.  This sample app was developed by Shane Smith and Johnny Diggz, 
     (Shane did all the actual coding, Diggz just copied and pasted stuff and bugged Shane).
     There is a blog post about this app on the Tropo site, but Diggz didn't write it yet, or else
     he would post the link here.  We hope that all seven of the ColdFusion developers left in the 
     world will enjoy this. Feel free to make it better.  We like that.  Helpful docs about each Tropo 
     method and object can be found here: https://www.tropo.com/docs/webapi/new_tropo_web_api_overview.htm
     You'll notice examples in Ruby, PHP, NodeJS, Python but no ColdFusion. (that's why we made this!)
-->

<!-- Some header stuff that is helpful in development so Tropo and other web servers don't cache things -->

<CFHEADER NAME="Expires" VALUE="Mon, 06 Jan 1990 00:00:01 GMT">
<CFHEADER NAME="Pragma" VALUE="no-cache">
<CFHEADER NAME="cache-control" VALUE="no-cache">

<!-- Because it's difficult to debug this stuff, we create a log file on your server (or local machine)
     that stores the Tropo JSON payloads as they come in.  This is very handy to help debug your code, but 
     not necessary once you have things up and running.  Alternatively you could be putting this into 
     a database or something much more elegant than a text file, but we'll leave that elegance up to you.  
-->

<CFSET myfilepath="c:\localfolder">

<!-- The following script will consume Tropo WebAPI JSON and make it digestible by ColdFusion.  You could 
     move this somewhere else and include it with a CFInclude -->

<cfscript>
function CFTropoJSON(content) {
theData=REReplace(tostring(content), "^\s*[[:word:]]*\s*\(\s*","");
theData=REReplace(theData, "\s*\)\s*$", "");
theData=DeserializeJSON(theData);
return theData; }
</cfscript>

<!-- The following puts Tropo WebAPI JSON into the variable "theJSON" -->

<cftry>

<CFSET theJSON=CFTropoJSON(GetHttpRequestData().content)>

<!-- Check to see if there is a result from the ask below -->
    
<cfif IsDefined("theJSON.result.actions.interpretation")>    

<!-- For debugging, if we have a result, add that the the log -->

<CFSAVECONTENT variable="outputlog">

<!-- Say the result to the caller using the Tropo Say method -->
{
   "tropo":[{"say":{"value":"Okay, I heard <CFOUTPUT>#theJSON.result.actions.interpretation#</CFOUTPUT>. Thanks."}}]
}
</CFSAVECONTENT>

<!-- If there is no result, we need to ask the question using the Tropo Ask method -->

<cfelse>

<!-- Again, this CFSAVECONTENT is for debugging purposes -->
    
<CFSAVECONTENT variable="outputlog">
{
   "tropo":[
      {
         "ask":{
            "attempts":3,
            "say":[
               {
                  "value":"Sorry, I did not hear anything.",
                  "event":"timeout"
               },
               {
                  "value":"Don't think that was a year. ",
                  "event":"nomatch:1"
               },
               {
                  "value":"Nope, still not a year.",
                  "event":"nomatch:2"
               },
               {
                  "value":"What is your birth year?"
               }
            ],
            "choices":{
               "value":"[4 DIGITS]"
            },
            "bargein":true,
            "timeout":60,
            "interdigitTimeout": 1,
            "name":"year",
            "required":true
         }
      },
      {
         "on":{
            "next":"index.cfm",
            "event":"continue"
         }
      },
      {
         "on":{
            "next":"index.cfm",
            "event":"incomplete"
         }
      }
   ]
}
</CFSAVECONTENT>
</cfif>

<!-- Save the JSON to the log file for debugging purposes -->

<CFOUTPUT>#outputlog#</CFOUTPUT>
<cfcatch>
<cffile action="append"
    file="#myfilepath#\log.txt"
    output="#cfcatch#">
</cfcatch>
</cftry>