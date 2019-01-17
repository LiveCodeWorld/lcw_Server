script "lib_AtopiaDomainOwnership"
--> MetaData
-
license: GPLv3
name: lib_AtopiaDomainOwnership
type: library
version: 0.1

/*
These handlers hack into Atopia servers config.json and owner.json files to try to figure out a domain's owner.
*/


--> Working on
-
function atopia_FindFarmEmail wikiDomain
   put url_GetTopDomain (wikiDomain) into topDomainName
   put atopia_GetFarmArray() into farmArray
   put farmArray ["author farm"][topDomainName] into maybeLineNum
   if maybeLineNum is empty then
      -- not an author farm
      put fedray_GetDomainMetaArray (wikiDomain) into domainMetaArray
   else
      put fedray_GetDomainMetaArray (topDomainName) into domainMetaArray
   end if
   fedray_DeconstructDomainMeta domainMetaArray, ipAddress, lastSiteUpdate, ownerEmail, ownerName
   return ownerEmail
end atopia_FindFarmEmail

function atopia_GetDomainOwnerIdPath domainName, pConfigArray
   put atopia_GetDomainConfigArray (domainName, pConfigArray) into domainConfigArray
   put domainConfigArray ["id"] into idPath
   return idPath
end atopia_GetDomainOwnerIdPath

function atopia_GetDomainConfigArray domainName, pConfigArray
   if pConfigArray is empty then
      put atopia_GetConfigArray() into pConfigArray
   end if
   put pConfigArray ["wikidomains"][domainName] into domainConfigArray
   return domainConfigArray
end atopia_GetDomainConfigArray

function atopia_FetchEmail wikiDomain, pConfigArray
   -- tries hard to find it on the server
   put atopia_FetchAndFindOwnerArray (wikiDomain, pConfigArray) into ownerArray
   put atopia_GetOwnerEmail (ownerArray) into ownerEmail
   return ownerEmail
   
   /*
   -- looks first in owner.json
   put atopia_FetchOwnerEmail (wikiDomain) into ownerEmail
   if ownerEmail is not empty then return ownerEmail
   
   -- let's try the config.json
   put atopia_FetchEmailFromConfig (wikiDomain, pConfigArray) into ownerEmail
   return ownerEmail
   */
end atopia_FetchEmail

function atopia_GetOwnerFilePath wikiDomain, pConfigArray
   -- exact match
   -- now that we look to have simple automated config.json
   
   if pConfigArray is not an array then
      put atopia_GetConfigArray() into pConfigArray
   end if
   put pConfigArray ["wikiDomains"][wikiDomain]["id"] into ownerFilePath
   return ownerFilePath
end atopia_GetOwnerFilePath

function atopia_FetchOwnerJson wikiDomain
   put atopia_WikiStatusFolder (wikiDomain) into wikiStatusFolder
   put wikiStatusFolder & "owner.json" into ownerJsonPath
   put atopia_FetchData (ownerJsonPath) into ownerJson
   return ownerJson
end atopia_FetchOwnerJson


--> Atopia | Domain | Owner | Get
-
function atopia_GetOwnerEmail ownerArray
   -- work in progress
   fedwiki_DeconstructOwnerArray ownerArray, ownerEmail, accountType, ownerID, ownerName
   -- should also do Twitter and other schemes
   return ownerEmail
end atopia_GetOwnerEmail

function atopia_ConstructPersonaOwnerArray personaEmail
   -- for legacy persona sites
   put personaEmail into ownerArray ["persona"]["emails"][1]["value"]
   return ownerArray
end atopia_ConstructPersonaOwnerArray

function atopia_FindOwnerFilePath wikiDomain, pConfigArray
   -- generous find
   if pConfigArray is not an array then
      put atopia_GetConfigArray() into pConfigArray
   end if
   set the itemdelimiter to "."
   put the number of items of wikiDomain -1 into maxNum
   put wikiDomain into testDomain
   repeat maxNum
      put pConfigArray ["wikiDomains"][testDomain]["id"] into ownerFilePath
      if ownerFilePath is not empty then next repeat
      delete item 1 of testDomain
   end repeat
   return ownerFilePath
end atopia_FindOwnerFilePath

function atopia_GetDomainsFromEmail userEmail, pOwnershipArray
   if pOwnershipArray is not an array then
      put atopia_GetOwnershipArray() into pOwnershipArray
   end if
   put pOwnershipArray [userEmail]["domains"] into domainArray
   repeat for each key indexNum in domainArray
      put domainArray [indexNum]["domain"] into domainName
      put domainName & CR after domainNames
   end repeat
   delete char -1 of domainNames
   url_SortDomainIndex domainNames
   return domainNames
end atopia_GetDomainsFromEmail


--> Atopia | Domain | Owner | Build
-
command atopia_DeleteFromOwnershipArray wikiFolder
   breakpoint
end atopia_DeleteFromOwnershipArray

command atopia_AddToOwnershipArray wikiFolder
   breakpoint
   
   -- still to do - delete old stuff
   
   put atopia_GetOwnershipArray() into ownershipArray
   put atopia_FetchConfigArray() into configArray
   --
   -- still to do - check if domain is already there
   _AddDomainToOwnershipArray ownershipArray, wikiFolder, configArray
   --
   atopia_SetOwnershipArray ownershipArray
   return ownershipArray
end atopia_AddToOwnershipArray

command atopia_ConstructOwnershipArray pDeleteExisting, pIndexView
   put atopia_FetchAllFolderList() into wikiFolders
   if pDeleteExisting is true then
      atopia_SetOwnershipArray empty
      put empty into ownershipArray
   else
      put atopia_GetOwnershipArray() into ownershipArray
   end if
   --
   atopia_AddOwnershipToDomainArray ownershipArray, wikiFolders, pIndexView
   --
   atopia_SetOwnershipArray ownershipArray
   -- put the result into modelDataFile
   return ownershipArray
end atopia_ConstructOwnershipArray

command atopia_AddOwnershipToDomainArray @ownershipArray, wikiFolders, pIndexView
   local indexedArray
   
   put atopia_FetchConfigArray() into configArray   
   repeat for each line wikiFolder in wikiFolders
      _AddDomainToOwnershipArray ownershipArray, wikiFolder, configArray
      --
      set the cursor to busy
      if exists (pIndexView) then
         set the selected_Index of pIndexView to wikiFolder
      end if
   end repeat
end atopia_AddOwnershipToDomainArray

private command _AddDomainToOwnershipArray @ownershipArray, wikiFolder, configArray
   put atopia_FetchAndFindOwnerArray (wikiFolder, configArray) into ownerArray
   put atopia_GetOwnerEmail (ownerArray) into ownerEmail
   if ownerEmail is empty then
      put "No email" into ownerEmail
   end if
   
   -- could add to fedray here
   
   put ownershipArray [ownerEmail]["domains"] into indexedArray
   array_AddToNumbered indexedArray, "domain", wikiFolder
   put the result into newIndexNum
   put ownerArray into indexedArray [newIndexNum]["ownerArray"]
   put indexedArray into ownershipArray [ownerEmail]["domains"]
end _AddDomainToOwnershipArray

function atopia_DomainIsBadInDomainArray folderName, atopiaData
   put atopiaData ["good"] into goodArray
   put atopiaData ["bad"] into badArray
   
   set the caseSensitive to true
   put folderName is among the keys of badArray into isBad
   put folderName is among the keys of goodArray into isGood
   
   if isGood and isbad is true then
      breakpoint -- shoud be one or the other
      return false
   else if isGood is true then
      return false
   else if isBad is true then
      return true
   end if
end atopia_DomainIsBadInDomainArray


--> Atopia | Fetch | Owner | Email
-
function atopia_FetchOwnerEmail wikiDomain
   put atopia_FetchOwnerArray (wikiDomain) into ownerArray
   put atopia_GetOwnerEmail (ownerArray) into ownerEmail
   return ownerEmail
end atopia_FetchOwnerEmail

function atopia_FetchEmailFromConfig  wikiDomain, pConfigArray
   put atopia_FetchOwnerArrayFromConfig (wikiDomain, pConfigArray) into ownerArray
   put atopia_GetOwnerEmail (ownerArray) into ownerEmail
   return ownerEmail
end atopia_FetchEmailFromConfig

function atopia_FetchAndFindOwnerArray wikiDomain, pConfigArray
   put atopia_FetchOwnerArray (wikiDomain) into ownerArray
   if ownerArray is an array then return ownerArray
   
   -- let's try the config.json
   put atopia_FetchOwnerArrayFromConfig (wikiDomain, pConfigArray) into ownerArray
   if ownerArray is an array then return ownerArray
   
   -- let's see if it an old persona site
   put atopia_FetchPersonaEmail (wikiDomain) into personaEmail
   if personaEmail is not empty then
      put atopia_ConstructPersonaOwnerArray (personaEmail) into ownerArray
      return ownerArray
   end if
   
   return empty
end atopia_FetchAndFindOwnerArray


--> Atopia | Fetch | Owner
-
function atopia_FetchOwnerArrayFromConfig wikiDomain, pConfigArray
   put atopia_GetOwnerFilePath (wikiDomain, pConfigArray) into ownerFilePath
   if ownerFilePath is empty then return empty
   
   put atopia_FetchData (ownerFilePath) into ownerJSON
   put json_ToArray (ownerJSON) into ownerArray
   return ownerArray
end atopia_FetchOwnerArrayFromConfig

function atopia_FetchOwnerArray wikiDomain
   put atopia_FetchOwnerJson (wikiDomain) into ownerJSON
   if item 1 of ownerJSON is "error"  or ownerJSON is empty then return empty
   put json_ToArray (ownerJSON) into ownerArray
   return ownerArray
end atopia_FetchOwnerArray

function atopia_FetchPersonaEmail wikiDomain
   put atopia_WikiStatusFolder (wikiDomain) into wikiStatusFolder
   put wikiStatusFolder & "persona.identity" into ownerJsonPath
   
   put atopia_FetchData (ownerJsonPath) into personaData
   return personaData
end atopia_FetchPersonaEmail

function atopia_FetchConfigJSON
   put ".wiki/config.json" into somePath
   put atopia_FetchData (somePath) into someJSON
   return someJSON
end atopia_FetchConfigJSON


--> Atopia | ConfigArray | Model
-
function atopia_GetConfigArray 
   put the model_Array ["atopia_Config.array"] of me into configArray
   return configArray
end atopia_GetConfigArray

command atopia_SetConfigArray configArray
   set the model_Array ["atopia_Config.array"] of me to configArray
   put the result into modelFile
   return modelFile
end atopia_SetConfigArray


--> Atopia | ConfigArray | Fetch
-
function atopia_ListConfigFolders configArray
   put configArray ["wikidomains"] into wikiDomainArray
   put keys (wikiDomainArray) into wikiDomains
   return wikiDomains
end atopia_ListConfigFolders

function atopia_FetchConfigFolderList
   put atopia_FetchConfigArray() into configArray
   put atopia_ListConfigFolders (configArray) into wikiDomains
   return wikiDomains
end atopia_FetchConfigFolderList

function atopia_FetchConfigArray
   put atopia_FetchConfigJSON() into configJSON
   put json_ToArray (configJSON) into configArray
   return configArray
end atopia_FetchConfigArray


--> Private
-
private command fedwiki_DeconstructOwnerArray ownerArray, @ownerEmail, @accountType, @ownerID, @ownerName
   put empty into ownerEmail
   put empty into accountType
   put empty into ownerID
   put empty into ownerName
   --
   put ownerArray ["google"] into googleOwnerArray
   put googleOwnerArray ["emails"][1]["value"] into ownerEmail
   if ownerEmail is not empty then
      put "google" into accountType
      put googleOwnerArray ["id"] into ownerID
      put googleOwnerArray ["name"] into ownerName
      return true
   end if
   
   -- for gitHub only the primary email
   put ownerArray ["github"] into githubOwnerArray
   put githubOwnerArray ["email"] into indexedArray
   repeat for each key indexNum in indexedArray
      put githubOwnerArray ["email"][indexNum]["primary"] into isPrimary
      if isPrimary is true then
         put githubOwnerArray ["email"][indexNum]["value"] into ownerEmail
         if ownerEmail is empty then put "No email" into ownerEmail
         
         put "gitHub" into accountType
         put githubOwnerArray ["id"] into ownerID
         put googleOwnerArray ["name"] into ownerName
         return true
      else
         -- not a primary email
         -- beep -- assuming there should be at least one set as primary by github
      end if
   end repeat
   
   get ownerArray ["persona"]["emails"][1]["value"]
   if it is not empty then
      put "persona" into accountType
      put it into ownerEmail
   end if
   
   -- should also do Twitter and other schemes
   return false
end fedwiki_DeconstructOwnerArray
