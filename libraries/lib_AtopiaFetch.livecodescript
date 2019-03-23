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
function atopia_FetchFolders pRemoveOwners
   put atopia_FetchFilteredFolderLsArray() into folderArray
   if pRemoveOwners is not false then
      delete variable folderArray ["fedwiki_owners"]
   end if
   put keys (folderArray) into wikiDomains
   url_SortDomainIndex wikiDomains
   return wikiDomains
end atopia_FetchFolders


--> Atopia | Fetch | Domains | Wrappers
-
function atopia_FetchDomainLinks topDomain, pHow
   -- was "atopia_FetchLiveDomainLinks"
   put atopia_FetchDomains (pHow) into domainIndex
   roster_DomainFilter domainIndex, topDomain
   url_SortDomainIndex domainIndex
   repeat for each line filteredDomain in domainIndex
      put "- [[" & filteredDomain & "]]" & CR after domainLinks
   end repeat
   delete char -1 of domainLinks
   return domainLinks
end atopia_FetchDomainLinks

function atopia_FetchTopDomains pHow
   put atopia_FetchDomains (pHow) into atopiaDomains
   put roster_GetTop (atopiaDomains) into topDomains
   return topDomains
end atopia_FetchTopDomains


--> Atopia | Fetch | Domains
-
function atopia_FetchDomains pHow
   switch
      case pHow begins with "New"
         return atopia_FetchNewFolders ()
      case pHow contains "Array"
         return atopia_FetchFedrayDomains()
      case pHow contains "Folder"
         return atopia_FetchFolders()
      default
         -- "roster"
         return atopia_FetchRoster()
   end switch
end atopia_FetchDomains

function atopia_FetchNewFolders pHow
   -- compare (pHow default = roster) with actual folders on server
   put atopia_FetchDomains (pHow) into alreadyGoodDomains
   if alreadyGoodDomains is empty then breakpoint
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   if item 1 of it is "error" then return empty
   
   delete variable remoteFolderArray ["fedwiki_owners"]
   repeat for each line goodDomainName in alreadyGoodDomains
      set the cursor to busy
      delete variable remoteFolderArray [goodDomainName]
   end repeat
   
   put keys (remoteFolderArray) into newRemoteDomains
   url_SortDomainIndex newRemoteDomains, true
   return newRemoteDomains
end atopia_FetchNewFolders

function atopia_FetchFedrayDomains pMinPageNum
   put atopia_FetchFedray() into atopiaFedray
   --
   if pMinPageNum is a number then fedray_Filter atopiaFedray, pMinPageNum
   put keys (atopiaFedray) into atopiaDomains
   url_SortDomainIndex atopiaDomains
   return atopiaDomains
end atopia_FetchFedrayDomains


--> Atopia | Plugin | Model
-
function atopia_FetchFedray
   put fedwiki_FetchPluginJSON ("atopia-domain-index", "server.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into atopiaFedray
   return atopiaFedray
end atopia_FetchFedray

command atopia_StoreFedray atopiaFedray
   put json_FromArray (atopiaFedray) into someJSON
   put atopia_GetJsonSecret() into apiKey
   fedwiki_PutPluginJSON someJSON, "atopia-domain-index", "server.fedwiki.org", apiKey
   put the result into putError
   return putError
end atopia_StoreFedray


--> Atopia | Plugin | Secret
-
function atopia_GetJsonSecret
   put secret_Get ("AtopiaJsonApiKey", "jsonApiKey") into apiKey
   return apiKey
end atopia_GetJsonSecret

command atopia_SetJsonSecret apiKey
   secret_Set "AtopiaJsonApiKey", apiKey, "jsonApiKey"
   return the result
end atopia_SetJsonSecret


--> Atopia | Person | JSON
-
function atopia_FetchPersonArray pageSlug
   put atopia_FetchPersonJSON (pageSlug) into someJSON
   put json_ToArray (someJSON) into someArray
   return someArray
end atopia_FetchPersonArray

command atopia_StorePersonArray pageSlug, someArray
   put json_FromArray (someArray) into someJSON
   atopia_StorePersonJSON pageSlug, someJSON
   put the result into putError
   return putError
end atopia_StorePersonArray

function atopia_FetchPersonJSON pageSlug
   put "people.fedwiki.org" into wikiDomain
   put fedwiki_FetchPluginJSON (pageSlug, wikiDomain) into someJSON
   return someJSON
end atopia_FetchPersonJSON

command atopia_StorePersonJSON pageSlug, someJSON
   put atopia_GetJsonSecret() into apiKey
   fedwiki_PutPluginJSON someJSON, pageSlug, "people.fedwiki.org", apiKey
   put the result into putError
   switch putError
      case "error Previous request not completed"
         break
      case empty
         break
      default
         put putError
   end switch
   return putError
end atopia_StorePersonJSON


/*
private command _SetSlugDomain jType, @pageSlug, @wikiDomain
   -- confusing split into individual handlers
   breakpoint
   switch jType
      case "Servers"
         put "site-of-servers" into pageSlug
         put "server.fedwiki.org" into wikiDomain
         break
      case "Federation Domains"
         put "federation-domain-index" into pageSlug
         put "roster.fedwiki.org" into wikiDomain
         break
      case "Atopia Domains"
         put "atopia-domain-index" into pageSlug
         put "roster.fedwiki.org" into wikiDomain
         break
      default
         -- some error
         exit to top
   end switch
end _SetSlugDomain

function atopia_FetchServerJSON jType
   _SetSlugDomain jType, pageSlug, wikiDomain
   put fedwiki_FetchPluginJSON (pageSlug, wikiDomain) into someJSON
   if someJSON is empty then
      resetall
      put fedwiki_FetchPluginJSON (pageSlug, wikiDomain) into someJSON
      -- put atopia_FetchServerJSON (jType) into someJSON
   end if
   return someJSON
end atopia_FetchServerJSON

command atopia_StoreServerJSON jType, someJSON
   _SetSlugDomain jType, pageSlug, wikiDomain
   put atopia_GetJsonSecret() into apiKey
   fedwiki_PutPluginJSON someJSON, pageSlug, wikiDomain, apiKey
   put the result into putError
   return putError
end atopia_StoreServerJSON
*/
