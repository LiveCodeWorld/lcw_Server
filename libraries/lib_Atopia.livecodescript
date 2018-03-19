script "lib_Atopia"
--> MetaData
-
license: GPLv3
name: lib_Atopia
type: library
version: 0.3

/*
This library is for processing and interfacing with wiki folders on the Atopia server.
*/


--> Working on
-

--> Display | Events
-
on mDoubleUp_AtopiaWikiFiles indexView, pageSlug
   if the optionKey is "down" then breakpoint
   --
   put the title_Text of indexView into wikiDomain
   --
   put fedwiki_PageUrl (wikiDomain, pageSlug) into pageURL
   launch url pageURL
   
   put atopia_FindOwnerArray (wikiDomain) into ownerArray
   display_AtopiaOwnerArray ownerArray, wikiDomain
end mDoubleUp_AtopiaWikiFiles

command mDoubleUp_AtopiaFolder indexView, wikiDomain
   if the optionKey is "down" then breakpoint
   
   display_AtopiaWikiPages wikiDomain
end mDoubleUp_AtopiaFolder



--> Display
-
command display_AtopiaDomainFolders pIndexView
   -- put atopia_FetchAllFolderList() into wikiFolders
   put atopia_ListDomainFolders() into wikiFolders
   
   if pIndexView is empty then
      display_Lines wikiFolders, "Atopia Wiki Folders,atopia_FetchAllFolderList()", "mDoubleUp_AtopiaFolder"
      put the result into pIndexView
      set the title_Menu of pIndexView to "Global | Atopia | Tree | Menu"
      set the line_Menu of pIndexView to "Global | Atopia | Line | Menu"
   end if
   
   _ColourGoodBad pIndexView
end display_AtopiaDomainFolders

command display_AtopiaWikiPages wikiDomain
   set the cursor to watch
   put atopia_FetchWikiPageList (wikiDomain) into wikiPages
   
   put wikiDomain & comma & "atopia_FetchWikiPageList()" into displayTitle
   display_Lines wikiPages, displayTitle, "mDoubleUp_AtopiaWikiFiles"
   put the result into displayView
   --
   set the title_Menu of displayView to "Global | Atopia | Tree | Menu"
   set the line_Menu of displayView to "Global | Atopia | Line | Menu"
   --
   return displayView
end display_AtopiaWikiPages

command display_AtopiaDomainErrorArray
   put atopia_GetDomainErrorArray() into domainErrorArray
   --
   display_Array domainErrorArray, "Domain Error Array,atopia_GetDomainErrorArray()"
end display_AtopiaDomainErrorArray

command display_AtopiaOwnerArray ownerArray, wikiDomain
   display_Array ownerArray, (wikiDomain & ",atopia_FindOwnerArray()")
   put fedwiki_GetOwnerEmail (ownerArray)
end display_AtopiaOwnerArray


--> Props
-
setprop atopia_ColouredLines allFolderNames
   -- this will set a domain list fo an index_View
   -- and check and colour any domains red that are marked bad in the local domainErrorArray
   
   put atopia_GetDomainErrorArray() into domainErrorArray
   url_SortDomainIndex allFolderNames, true
   --
   repeat with lineNum = 1 to the number of lines of allFolderNames
      put line lineNum of allFolderNames into folderName
      if atopia_DomainIsBad (folderName, domainErrorArray) is true then
         put empty into colourArray ["red"][lineNum]
         put lineNum & comma after badNums
      else
         put empty into colourArray ["none"][lineNum]
         put lineNum & comma after goodNums
      end if
   end repeat
   delete char -1 of goodNums
   delete char -1 of badNums
   --
   lock screen
   set the field_Align of the target to "right"
   set the view_Index of the target to allFolderNames
   set the line_Colours of the target to colourArray
   unlock screen
end atopia_ColouredLines


--> Atopia | Domain | Owner
-
function atopia_FindOwnerArray wikiDomain, pConfigArray
   put atopia_FetchOwnerArray (wikiDomain) into ownerArray
   if ownerArray is an array then return ownerArray
   
   -- let's try the config.json
   put atopia_GetOwnerArrayFromConfig (wikiDomain, pConfigArray) into ownerArray
   if ownerArray is an array then return ownerArray
   
   -- let's see if it an old persona site
   put atopia_FetchPersonaEmail (wikiDomain) into personaEmail
   if personaEmail is not empty then
      put fedwiki_ConstructPersonaOwnerArray (personaEmail) into ownerArray
      return ownerArray
   end if
   
   return empty
end atopia_FindOwnerArray

function atopia_FindEmail wikiDomain, pConfigArray
   -- looks in local owner.json and if not for id file specified in config.json
   put atopia_FetchOwnerArray (wikiDomain) into ownerArray
   put fedwiki_GetOwnerEmail (ownerArray) into ownerEmail
   if ownerEmail is not empty then return ownerEmail
   
   -- let's try the config.json
   put atopia_GetOwnerArrayFromConfig (wikiDomain, pConfigArray) into ownerArray
   put fedwiki_GetOwnerEmail (ownerArray) into ownerEmail
   return ownerEmail
end atopia_FindEmail

function atopia_GetOwnerArrayFromConfig wikiDomain, pConfigArray
   if pConfigArray is not an array then
      put atopia_FetchConfigArray() into pConfigArray
   end if
   set the itemdelimiter to "."
   put the number of items of wikiDomain -1 into maxNum
   put wikiDomain into testDomain
   repeat maxNum
      put pConfigArray ["wikiDomains"][testDomain]["id"] into ownerFilePath
      if ownerFilePath is not empty then next repeat
      delete item 1 of testDomain
   end repeat
   
   if ownerFilePath is empty then return empty
   --
   put digitalOcean_FetchFile (ownerFilePath, "Atopia", "root") into ownerJSON
   put json_ToArray (ownerJSON) into ownerArray
   return ownerArray
end atopia_GetOwnerArrayFromConfig

function atopia_FetchOwnerArray wikiDomain
   put atopia_FetchOwnerJson (wikiDomain) into ownerJSON
   put json_ToArray (ownerJSON) into ownerArray
   return ownerArray
end atopia_FetchOwnerArray

function atopia_FetchPersonaEmail wikiDomain
   put atopia_WikiStatusFolder (wikiDomain) into wikiStatusFolder
   put wikiStatusFolder & "persona.identity" into ownerJsonPath
   
   put digitalOcean_FetchFile (ownerJsonPath, "Atopia", "root") into personaData
   return personaData
end atopia_FetchPersonaEmail


--> Atopia | Model | Config
-
function atopia_FetchConfigFolderList
   put atopia_FetchConfigArray() into configArray
   put configArray ["wikidomains"] into wikiDomainArray
   put keys (wikiDomainArray) into wikiDomains
   return wikiDomains
end atopia_FetchConfigFolderList

function atopia_FetchConfigArray
   put atopia_FetchConfigJSON() into configJSON
   put json_ToArray (configJSON) into configArray
   return configArray
end atopia_FetchConfigArray


--> Atopia | DomainArray | Model
-
function atopia_ListDomainFolders pDomainErrorArray
   -- reconstruct from array  
   if pDomainErrorArray is empty then
      put atopia_GetDomainErrorArray() into pDomainErrorArray
   end if
   if pDomainErrorArray is empty then return empty -- ideally should not be?
   
   put atopia_GetGoodArray (pDomainErrorArray) into allArray
   put atopia_GetBadArray (pDomainErrorArray) into badArray
   union allArray with badArray
   
   -- make a cononical sorted list
   put keys (allArray) into allFolderNames
   url_SortDomainIndex allFolderNames, true
   return allFolderNames
end atopia_ListDomainFolders

function atopia_ListBadFolders
   put atopia_GetDomainErrorArray() into domainErrorArray
   put atopia_GetBadArray (domainErrorArray) into badArray
   put keys (badArray) into badFolderNames
   --
   url_SortDomainIndex badFolderNames, true
   return word 1 to -1 of badFolderNames
end atopia_ListBadFolders

function atopia_ListGoodFolders
   put atopia_GetDomainErrorArray() into domainErrorArray
   put atopia_GetGoodArray (domainErrorArray) into goodArray
   put keys (goodArray) into goodFolderNames
   --
   url_SortDomainIndex goodFolderNames, true
   return word 1 to -1 of goodFolderNames
end atopia_ListGoodFolders

function atopia_GetGoodArray domainErrorArray
   put domainErrorArray ["good"] into goodArray
   return goodArray
end atopia_GetGoodArray

function atopia_GetBadArray domainErrorArray
   put domainErrorArray ["bad"] into badArray
   return badArray
end atopia_GetBadArray


--> Private
-
private command _ColourGoodBad indexView
   lock screen
   put atopia_GetDomainErrorArray() into domainErrorArray
   put _GetGoodNums (domainErrorArray) into goodNums
   put _GetBadNums (domainErrorArray) into badNums
   
   set the field_Align of indexView to "right"
   set the line_Colour [badNums] of indexView to red
   set the line_Colour [goodNums] of indexView to empty
   unlock screen
end _ColourGoodBad

private function _GetGoodNums domainErrorArray
   put domainErrorArray ["info"]["goodNums"] into goodNums
   return goodNums
end _GetGoodNums

function _GetBadNums domainErrorArray
   put domainErrorArray ["info"]["badNums"] into badNums
   return badNums
end _GetBadNums
