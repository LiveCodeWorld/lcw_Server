script "model_Atopia"
--> MetaData
-
license: GPLv3
name: model_Atopia
type: model
version: 0.2

/*
This model is not about files and their contents. 
Instead, this model is for metadata about the server and should be renamed or handlers moved to make this clear.

The model should be changed to use model_Array and not user_GetArray()
*/


--> Atopia | Model
-
/*
Models should use model_Array, rather than user_GetArray
*/

function atopia_GetData
   put user_GetArray ("atopia_FetchError.array") into atopiaData
   return atopiaData
end atopia_GetData

command atopia_SetData atopiaData
   atopia_FilterGoodAndBad atopiaData -- just in case???
   user_SetArray "atopia_FetchError.array", atopiaData
   put the result into modelDataFile
   return modelDataFile
end atopia_SetData


--> Working on
-
function atopia_FetchTopTSV cseName
   put cse_NameToID (cseName) into cseID
   put atopia_FetchTopDomains() into atopiaDomains
   put cse_ConstructTSV (atopiaDomains, cseID) into topTSV
   return topTSV
end atopia_FetchTopTSV

function atopia_FetchTopDomains
   put atopia_FetchRoster() into atopiaDomainNames
   put url_ListTopDomains (atopiaDomainNames) into topDomains
   return topDomains
end atopia_FetchTopDomains

function atopia_GetTopDomains
   put atopia_ListLocalGoodFolders() into domainNames
   put url_ListTopDomains (domainNames) into topDomains
   return topDomains
end atopia_GetTopDomains


--> Atopia | Model | Wrappers
-
function atopia_GetArray topKey
   put atopia_GetData() into atopiaData
   put atopiaData [topKey] into atopiaArray
   return atopiaArray
end atopia_GetArray

command atopia_SetArray atopiaArray, topKey
   put atopia_GetData() into atopiaData
   put atopiaArray into atopiaData [topKey]
   atopia_SetData atopiaData
   put the result into modelDataFile
   return modelDataFile
end atopia_SetArray

function atopia_GetDomainDnsArray
   put atopia_GetArray ("dns") into dnsArray
   return dnsArray
end atopia_GetDomainDnsArray

command atopia_SetDomainDnsArray dnsArray
   atopia_SetArray dnsArray, "dns"
   put the result into modelDataFile
   return modelDataFile
end atopia_SetDomainDnsArray

function atopia_GetGoodDomainArray
   put atopia_GetArray ("good") into goodDomainArray
   return goodDomainArray
end atopia_GetGoodDomainArray

command atopia_SetGoodDomainArray goodDomainArray
   atopia_SetArray goodDomainArray, "good"
   put the result into modelDataFile
   return modelDataFile
end atopia_SetGoodDomainArray

function atopia_GetOwnershipArray
   put atopia_GetArray ("owner") into ownershipArray
   return ownershipArray
end atopia_GetOwnershipArray

command atopia_SetOwnershipArray ownershipArray
   atopia_SetArray ownershipArray, "owner"
   put the result into modelDataFile
   return modelDataFile
end atopia_SetOwnershipArray


--> Atopia | Model | Filter
-
function atopia_MissingRemoteFolderArray
   -- check if they are still there
   put atopia_ListLocalBadFolders() into badFolders
   put atopia_ListLocalGoodFolders() into goodFolders
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   if item 1 of it is "error" then return empty
   
   -- check local good folder exists
   repeat for each line goodFolder in goodFolders
      put remoteFolderArray [goodFolder] into goodFolderArray
      if goodFolderArray is not an array then
         put goodFolder & CR after notGoodThereIndex 
      end if
   end repeat
   delete char -1 of notGoodThereIndex
   
   -- check local bad folder exists
   repeat for each line badFolder in badFolders
      put remoteFolderArray [badFolder] into badFolderArray
      if badFolderArray is not an array then
         put badFolder & CR after notBadThereIndex 
      end if
   end repeat
   delete char -1 of notBadThereIndex
   
   put notGoodThereIndex into notThereArray ["Local Good folder missing"]
   put notBadThereIndex into notThereArray ["Local Bad folder missing"]
   --
   return notThereArray
end atopia_MissingRemoteFolderArray


--> Atopia | Model | Local | List
-
function atopia_ListLocalWikiFolders pAtopiaData
   -- reconstruct from array  
   if pAtopiaData is empty then
      put atopia_GetData() into pAtopiaData
   end if
   if pAtopiaData is empty then return empty -- ideally should not be?
   
   put atopia_GetLocalGoodArray (pAtopiaData) into allArray
   put atopia_GetLocalBadArray (pAtopiaData) into badArray
   union allArray with badArray
   
   -- make a cononical sorted list
   put keys (allArray) into allFolderNames
   url_SortDomainIndex allFolderNames, true
   return word 1 to -1 of allFolderNames
end atopia_ListLocalWikiFolders

function atopia_ListLocalGoodFolders
   put atopia_GetLocalGoodArray() into goodArray
   if goodArray is empty then return empty -- ideally should not be?
   --
   put keys (goodArray) into goodFolderNames
   url_SortDomainIndex goodFolderNames, true
   return word 1 to -1 of goodFolderNames
end atopia_ListLocalGoodFolders

function atopia_ListLocalBadFolders
   put atopia_GetLocalBadArray() into badArray
   if badArray is empty then return empty -- ideally should not be?
   --
   put keys (badArray) into badFolderNames
   url_SortDomainIndex badFolderNames, true
   return word 1 to -1 of badFolderNames
end atopia_ListLocalBadFolders

function atopia_ListLocalUnhostedFolders
   put atopia_GetLocalUnhostedArray() into unhostedArray
   if unhostedArray is empty then return empty -- ideally should not be?
   --
   put keys (unhostedArray) into unhostedFolders
   url_SortDomainIndex unhostedFolders, true
   return word 1 to -1 of unhostedFolders
end atopia_ListLocalUnhostedFolders

function atopia_ListLocalDomainOwners
   put atopia_GetOwnershipArray() into ownershipArray
   put keys (ownershipArray) into domainOwners
   sort domainOwners
   return domainOwners
end atopia_ListLocalDomainOwners


--> Atopia | Model | Local | Remove
-
/*
Remove from daomainArray
*/

command atopia_RemoveLocalBad badDomainName
   put atopia_GetData() into atopiaData
   delete variable atopiaData ["bad"][badDomainName]
   atopia_SetData atopiaData
end atopia_RemoveLocalBad


--> Atopia | Model | Local | Wrappers
-
function atopia_GetLocalGoodArray pAtopiaData
   if pAtopiaData is empty then
      put atopia_GetData() into pAtopiaData
   end if
   put pAtopiaData ["good"] into goodArray
   return goodArray
end atopia_GetLocalGoodArray

function atopia_GetLocalBadArray pAtopiaData
   if pAtopiaData is empty then
      put atopia_GetData() into pAtopiaData
   end if
   put pAtopiaData ["bad"] into badArray
   return badArray
end atopia_GetLocalBadArray

function atopia_GetLocalUnhostedArray pAtopiaData
   if pAtopiaData is empty then
      put atopia_GetData() into pAtopiaData
   end if
   put pAtopiaData ["_unhosted_sites"] into unhostedArray
   return unhostedArray
end atopia_GetLocalUnhostedArray


--> Filter
-
command atopia_FilterAllFolderArray @folderArray
   -- let's filter
   repeat for each key folderName in folderArray
      switch
         case folderName begins with "."
         case folderName begins with "_"
         case folderName is among the items of ReservedFolderNames
            delete variable folderArray [folderName]
            put folderName & CR after removedFolderNames
            break
         default
            -- it's ok
      end switch
   end repeat
   delete char -1 of removedFolderNames
   return removedFolderNames
end atopia_FilterAllFolderArray


--> Private
-
private command atopia_FilterGoodAndBad @atopiaData
   repeat for each item keyName in "good,bad"
      put atopiaData [keyname] into goodArray
      atopia_FilterAllFolderArray goodArray
      put the result into filteredDomainNames
      put goodArray into atopiaData [keyname]
      put filteredDomainNames & CR after filteredNames
   end repeat
   delete char -1 of filteredNames
   return filteredNames
end atopia_FilterGoodAndBad
