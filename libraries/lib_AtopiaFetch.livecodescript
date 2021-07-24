script "lib_AtopiaFetch"
--> MetaData
-
license: GPLv3
name: lib_AtopiaFetch
type: library
version: 0.4

/*
Here we fetch and store domain-arrays as json in json-plugin's on the Atopia server.
A domainArray is an array of wiki domains that is compaitble with the structure provided by Ward (see "fedray_FetchWards")
*/


--> Working on
-
function atopia_FetchDomainLinks topDomain, pHow
   put atopia_FetchFolders (topDomain) into domainIndex
   repeat for each line filteredDomain in domainIndex
      put "- [[" & filteredDomain & "]]" & CR after domainLinks
   end repeat
   delete char -1 of domainLinks
   return domainLinks
end atopia_FetchDomainLinks


--> Atopia | Roster | Fetch
-
function atopia_FetchCategorisedRoster pFilterDomain, pWithTitle
   -- fetch the one big domain index roster then filter
   put atopia_FetchRoster() into atopiaDomains
   --
   if pFilterDomain is not empty then
      put roster_CategorySplit (atopiaDomains, pFilterDomain) into atopiaDomains
   end if
   
   if pWithTitle is true then
      roster_AddHeader rosterText
   else
      roster_StripHeader rosterText
   end if
   return word 1 to -1 of atopiaDomains
end atopia_FetchCategorisedRoster

function atopia_CheckMissingSiteDomains
   put atopia_FetchRosterDomains() into rosterDomains
   delete line 1 to 2 of rosterDomains
   put atopia_ListFederationSitePages() into sitePages
   --
   put the number of lines of sitePages && the number of lines of rosterDomains
   line_DeleteIndex rosterDomains, sitePages
   return rosterDomains
end atopia_CheckMissingSiteDomains

function atopia_CheckMissingRosterDomains
   set the cursor to watch
   put atopia_FetchRosterDomains() into rosterDomains
   delete line 1 to 2 of rosterDomains
   --
   put atopia_FetchDomainArray() into atopiaServerDomainArray -- from JSON Plugin
   repeat for each line rosterDomain in rosterDomains
      set the cursor to busy
      put atopiaServerDomainArray [rosterDomain] into domainPageArray
      if domainPageArray is not an array then
         put rosterDomain & CR after missingDomains
      end if
   end repeat
   delete char -1 of missingDomains
   return missingDomains
end atopia_CheckMissingRosterDomains
