script "lib_Federation"
--> MetaData
-
license: GPLv3
name: lib_Federation
type: library
version: 0.1

/*
This library is for manipulating data about the entire federation.
*/


--> Federation
-
function federation_FetchMyRecentOther pCheckWikiSite
   put atopia_FetchRosterDomains() into minusDomains
   put federation_FetchLiveRecentDomains (pCheckWikiSite, minusDomains) into domainNames
   return domainNames
end federation_FetchMyRecentOther


--> Federation | Roster
-
function federation_FetchFilteredActivity wikiDomain, pageSlug, minusID, pCheckWikiSite
   put fedwiki_FetchRosterText (wikiDomain, pageSlug, minusID) into domainsToStrip
   put federation_FetchLiveRecentDomains (pCheckWikiSite, pMinusDomains) into domainNames
   
   put "Filtered Federation Activity" & CR & CR & domainNames into strippedRosterText
   put fedwiki_ConstructRosterPageArray (strippedRosterText) into pageArray
   return pageArray
end federation_FetchFilteredActivity

function federation_FetchLiveRecentDomains pCheckWikiSite, pMinusDomains
   put fedwiki_FetchRosterText ("search.fed.wiki.org:3030", "recent-activity") into rosterText
   put fedwiki_ExtractRosterDomains (rosterText) into domainNames
   
   set the wholeMatches to true
   repeat for each line minusLine in pMinusDomains
      put lineOffset (minusLine, domainNames) into lineNum
      delete line lineNum of domainNames
   end repeat
   
   -- here we filter for actual wiki sites (slow)
   if pCheckWikiSite is true then fedwiki_FilterCheck domainNames
   
   return domainNames
end federation_FetchLiveRecentDomains

function federation_FetchDomains pFilterDomain, pAddTitle
   put federation_FetchDomainArray() into federationDomainArray
   put _SortAndFilter (federationDomainArray, pFilterDomain, pAddTitle) into domainNames
   return domainNames
end federation_FetchDomains

function federation_FilterDomainArray domainArray, pMinPageNum
   repeat for each key domainName in domainArray
      put domainArray [domainName] into infoArray
      put infoArray ["pages"] into pageNum
      if pageNum > pMinPageNum then
         put infoArray into goodBadArray ["good"][domainName]
      else
         put infoArray into goodBadArray ["bad"][domainName]
      end if
   end repeat
   return goodBadArray
end federation_FilterDomainArray


--> Federation | Domain | Model
-
function federation_FetchDomainArray
   put atopia_FetchServerJSON ("Federation Domains") into someJSON
   put json_ToArray (someJSON) into federationDomainArray
   return federationDomainArray
end federation_FetchDomainArray

command federation_StoreDomainArray
   put fedray_FetchWardsSiteArray() into federationDomainArray
   -- here we can add atopia stuff?
   --
   atopia_StoreServerArray "Federation Domains", federationDomainArray
   put the result into putError
   return putError
end federation_StoreDomainArray
