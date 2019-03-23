script "model_Federation"
--> MetaData
-
license: GPLv3
name: model_Federation
type: model
version: 0.2


--> Working on
-

--> Fedray | Author | Model
-
function federation_FetchAuthorData
   put fedwiki_FetchPluginJSON ("author-model", "roster.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into authorArray
   return authorArray
end federation_FetchAuthorData

command federation_StoreAuthorData authorArray
   put atopia_GetJsonSecret() into apiKey
   put json_FromArray (authorArray) into someJSON
   fedwiki_PutPluginJSON someJSON, "author-model", "roster.fedwiki.org", apiKey
   put the result into putError -- error 401 Unauthorized
   return putError
end federation_StoreAuthorData


--> Federation | Fetch | Domains
-
function federation_FetchDomains pHow
   switch
      case pHow contains "Array"
         return fedray_FetchDomains()
      case pHow contains "Live"
         return fedray_FetchWardsDomains()
      default
         return roster_FetchDomains (pHow)
   end switch
end federation_FetchDomains

function federation_FetchRootDomains pHow
   put federation_FetchDomains (pHow) into fedDomains
   put url_ListTopDomains (fedDomains) into routeDomains
   return routeDomains
end federation_FetchRootDomains


--> Federation | ServerArray | Model
-
function federation_FetchServerArray serverName
   put serverName && "Server" into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   put fedwiki_FetchPluginJSON (pageSlug, "server.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into serverArray
   return serverArray
end federation_FetchServerArray

command federation_StoreServerArray serverName, serverArray
   put serverName && "Server" into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   put json_FromArray (serverArray) into someJSON
   put atopia_GetJsonSecret() into apiKey
   fedwiki_PutPluginJSON someJSON, pageSlug, "server.fedwiki.org", apiKey
   put the result into putError
   return putError
end federation_StoreServerArray


--> Federation | Model
-
function federation_FetchServerData
   put fedwiki_FetchPluginJSON ("server-model", "roster.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into serverData
   return serverData
end federation_FetchServerData

command federation_StoreServerData serverData
   put atopia_GetJsonSecret() into apiKey
   put json_FromArray (serverData) into someJSON
   fedwiki_PutPluginJSON someJSON, "server-model", "roster.fedwiki.org", apiKey
   put the result into putError
   return putError
end federation_StoreServerData


--> Fedray | Model
-
/*
We are now moving over to federation-model" from federation-domain-index"

The domains are the same ("roster.fedwiki.org"), and the data model is compatible.
*/
function fedray_FetchDomains
   put fedray_Fetch() into fedray
   put keys (fedray) into fedrayDomains
   url_SortDomainIndex fedrayDomains
   return fedrayDomains
end fedray_FetchDomains

function fedray_Fetch pWhichModel
   _SetModelSlug pageSlug, pWhichModel
   put fedwiki_FetchPluginJSON (pageSlug, "roster.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into fedray
   if fedray is false then return empty
   return fedray
end fedray_Fetch

command fedray_Store fedray, pWhichModel
   _SetModelSlug pageSlug, pWhichModel
   put atopia_GetJsonSecret() into apiKey
   put json_FromArray (fedray) into someJSON
   fedwiki_PutPluginJSON someJSON, pageSlug, "roster.fedwiki.org", apiKey
   put the result into putError
   return putError
end fedray_Store

private command _SetModelSlug @pageSlug, pWhichModel
   if pWhichModel is empty then put "federation" into pWhichModel
   put tolower (pWhichModel) & "-model" into pageSlug
end _SetModelSlug


--> Fedray | Model | Ward
-
function fedray_FetchWardsRecentDomains pCheckWikiSite, pMinusDomains
   -- was "federation_FetchLiveRecentDomains"
   put pageArray_Fetch ("search.fed.wiki.org:3030", "recent-activity", true) into pageArray
   put pageArray_FindItemType ("roster", pageArray) into itemNum
   put pageArray ["story"][itemNum]["text"] into domainNames
   --
   line_SetUnique domainNames
   url_CheckDomainIndex domainNames
   
   set the wholeMatches to true
   repeat for each line minusLine in pMinusDomains
      put lineOffset (minusLine, domainNames) into lineNum
      delete line lineNum of domainNames
   end repeat
   
   -- here we filter for actual wiki sites (slow)
   if pCheckWikiSite is true then fedwiki_FilterCheck domainNames
   return domainNames
end fedray_FetchWardsRecentDomains

function fedray_FetchWardsLogTable
   put url "http://search.fed.wiki.org:3030/logs" into folderHTML
   -- <a href="/logs/Thu-2000.txt">Thu-2000</a><br>
   put "<a href='/logs/(.+)'>.+</a><br>" into someReg
   replace "'" with quote in someReg
   get line 1 of folderHTML
   if matchText (it, someReg, shortFile) is false then
      return empty
   end if
   
   put "http://search.fed.wiki.org:3030/logs/" & shortFile into someURL
   put url someURL into someTable
   return someTable
end fedray_FetchWardsLogTable

function fedray_FetchWardsTopDomains
   -- fetch all federation domains from wards scrape
   put fedray_FetchWardsDomains() into federationDomains
   put url_ListTopDomains (federationDomains) into topFederationDomains
   return topFederationDomains
end fedray_FetchWardsTopDomains

function fedray_FetchWardsDomains pCheckDomains
   -- takes betewwn 40 to 17 seconds
   put fedray_FetchWards() into siteArray
   put keys (siteArray) into domainNames
   --
   if pCheckDomains is true then
      line_SetUnique domainNames
      url_CheckDomainIndex domainNames -- quick syntax check
   end if
   --
   url_SortDomainIndex domainNames
   return domainNames
end fedray_FetchWardsDomains

function fedray_FetchWards
   put fedray_FetchWardsJson() into siteJSON
   put json_ToArray (siteJSON) into siteArray
   return siteArray
end fedray_FetchWards

function fedray_FetchWardsJson
   put url "http://search.fed.wiki.org:3030/site-web.json" into siteJSON
   return siteJSON
end fedray_FetchWardsJson
