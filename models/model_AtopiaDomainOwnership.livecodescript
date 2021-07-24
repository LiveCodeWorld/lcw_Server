script "model_AtopiaDomainOwnership"
--> MetaData
-
copyright: David bovill
license: GPLv3
name: model_AtopiaDomainOwnership
type: model
version: 0.2


--> Working on
-
command atopia_AddOwnershipToDomainArray @ownershipArray, wikiFolders, pIndexView
   -- slow builds local array
   local indexedArray
   
   put atopia_FetchConfigArray() into configArray
   sort lines of wikiFolders -- we cant display domain ordered arrays
   repeat for each line wikiFolder in wikiFolders
      display_Spin wikiFolder, pIndexView
      --
      put atopia_FetchDomainOwnerArray (wikiFolder, configArray) into domainOwnerArray
      atopia_AddDomainToOwnershipArray ownershipArray, wikiFolder, domainOwnerArray
   end repeat
end atopia_AddOwnershipToDomainArray


--> Atopia | OwnershipArray | Model | Create
-
function atopia_ConstructAuthorNameArray ownershipArray
   repeat for each key someEmail in ownershipArray
      put ownershipArray [someEmail]["domains"] into indexedDomainArray
      repeat for each key indexNum in indexedDomainArray
         set the cursor to busy
         --
         put indexedDomainArray [indexNum]["domain"] into domainName
         put indexedDomainArray [indexNum]["ownerArray"] into ownerArray
         --
         fedwiki_DeconstructOwnerArray ownerArray, ownerEmail, accountType, ownerID, ownerName
         put _MapOwnerName (ownerName, ownerEmail) into ownerName
         --
         if ownerName is empty then
            put ownerEmail into ownerName
         end if
         --
         put ownerArray into authorNameArray [ownerName]["domains"][domainName]
         put empty into authorNameArray [ownerName]["emails"][ownerEmail][domainName]
      end repeat
   end repeat
   return authorNameArray
end atopia_ConstructAuthorNameArray

function atopia_ListLocalDomainOwners
   put atopia_GetLocalEmailOwnerData() into ownershipArray
   put keys (ownershipArray) into domainOwners
   sort domainOwners
   return domainOwners
end atopia_ListLocalDomainOwners


--> Atopia | OwnershipArray | Model
-
command atopia_AddToOwnershipArray wikiFolder
   put atopia_GetLocalEmailOwnerData() into ownershipArray
   --
   put atopia_FetchConfigArray() into configArray
   --
   put atopia_FetchDomainOwnerArray (wikiFolder, configArray) into domainOwnerArray
   atopia_AddDomainToOwnershipArray ownershipArray, wikiFolder, domainOwnerArray
   --
   atopia_SetLocalEmailOwnerData ownershipArray
   return ownershipArray
end atopia_AddToOwnershipArray

command atopia_UpdateOwnershipArray wikiFolder
   put atopia_GetLocalEmailOwnerData() into ownershipArray
   put atopia_FetchConfigArray() into configArray
   --
   atopia_DeleteDomainFromOwnershipArray ownershipArray, wikiFolder
   put atopia_FetchDomainOwnerArray (wikiFolder, configArray) into domainOwnerArray
   atopia_AddDomainToOwnershipArray ownershipArray, wikiFolder, domainOwnerArray
   --
   atopia_SetLocalEmailOwnerData ownershipArray
   return ownershipArray
end atopia_UpdateOwnershipArray

command atopia_DeleteDomainFromOwnershipArray @ownershipArray, wikiFolder
   repeat for each key someEmail in ownershipArray
      put ownershipArray [someEmail]["domains"] into indexedDomainArray
      --
      repeat for each key indexNum in indexedDomainArray
         put indexedDomainArray [indexNum]["domain"] into foundDomainName
         if foundDomainName = wikiFolder then
            _DeleteAndReindex indexedDomainArray, indexNum, someEmail
            put indexedDomainArray into ownershipArray [someEmail]["domains"]
            
            -- return true -- assume there is only one owner?
         end if
      end repeat
   end repeat
   return false
end atopia_DeleteDomainFromOwnershipArray

command atopia_AddDomainToOwnershipArray @ownershipArray, wikiFolder, domainOwnerArray
   put atopia_GetOwnerEmail (domainOwnerArray) into ownerEmail
   if ownerEmail is empty then
      put "No email" into ownerEmail
   end if
   
   put ownershipArray [ownerEmail]["domains"] into indexedDomainArray
   --
   repeat for each key indexNum in indexedDomainArray
      put indexedDomainArray [indexNum]["domain"] into foundDomainName
      if foundDomainName = wikiFolder then
         -- let's update domainOwnerArray
         put domainOwnerArray into ownershipArray [ownerEmail]["domains"][indexNum]["ownerArray"]
         return indexNum
      end if
   end repeat
   
   -- let's add it as it is not there
   put item 2 of the extents of indexedDomainArray into indexNum
   add 1 to indexNum
   --
   put wikiFolder into ownershipArray [ownerEmail]["domains"][indexNum]["domain"]
   put domainOwnerArray into ownershipArray [ownerEmail]["domains"][indexNum]["ownerArray"]
end atopia_AddDomainToOwnershipArray

function atopia_GetLocalEmailOwnerData
   put atopia_GetArray ("owner") into ownershipArray
   return ownershipArray
end atopia_GetLocalEmailOwnerData

command atopia_SetLocalEmailOwnerData ownershipArray
   atopia_SetArray ownershipArray, "owner"
   put the result into modelDataFile
   return modelDataFile
end atopia_SetLocalEmailOwnerData


--> Atopia | Model | Build
-
command atopia_AddToDomainErrorArray @atopiaData, wikiFolders, pMinNum
   if pMinNum is empty then put 1 into pMinNum
   
   repeat for each line wikiFolder in wikiFolders
      set the cursor to busy
      if wikiFolder is among the items of ReservedFolderNames then next repeat
      --
      put atopia_ListWikiPages (wikiFolder) into wikiPages
      if the number of lines of wikiPages > pMinNum then
         put wikiPages into atopiaData ["good"][wikiFolder]
         delete variable atopiaData ["bad"][wikiFolder]
      else
         put wikiPages into atopiaData ["bad"][wikiFolder]
         delete variable atopiaData ["good"][wikiFolder]
         put wikiFolder & CR after addedBadFolders
      end if
      add 1 to lineNum
   end repeat
   delete char -1 of addedBadFolders
   
   -- not needed now?
   -- put _ConstructGoodBadNumArray (atopiaData, pMinNum) into domainInfoArray
   -- put domainInfoArray into atopiaData ["info"]
   return addedBadFolders
end atopia_AddToDomainErrorArray

function atopia_FetchAndBuildArray pMinNum, pWikiFolders
   -- really, really slow (consider using cli "tree" thing)
   
   if pMinNum is empty then put 1 into pMinNum
   if pWikiFolders is empty then
      put atopia_FetchFolders() into pWikiFolders
   end if
   
   put 1 into lineNum
   repeat for each line wikiFolder in pWikiFolders
      set the cursor to busy
      if wikiFolder is among the items of ReservedFolderNames then next repeat
      --
      put atopia_ListWikiPages (wikiFolder) into wikiPages
      if the number of lines of wikiPages > pMinNum then
         put wikiPages into atopiaData ["good"][wikiFolder]
      else
         put wikiPages into atopiaData ["bad"][wikiFolder]
      end if
      add 1 to lineNum
   end repeat
   
   -- not deeded?
   put _ConstructGoodBadNumArray (atopiaData, pMinNum) into domainInfoArray
   put domainInfoArray into atopiaData ["info"]
   
   return atopiaData
end atopia_FetchAndBuildArray


--> Atopia | Model | Construct
-
command atopia_ConstructDnsArray pDeleteExisting
   put atopia_FetchFolders() into wikiFolders
   if pDeleteExisting is true then
      atopia_SetDomainDnsArray empty
      put empty into dnsArray
   else
      put atopia_GetDomainDnsArray() into dnsArray
   end if
   --
   atopia_AddDnsToDomainArray dnsArray, wikiFolders
   --
   atopia_SetDomainDnsArray dnsArray
   put the result into modelDataFile
   return modelDataFile
end atopia_ConstructDnsArray

command atopia_AddDnsToDomainArray @dnsArray, wikiFolders
   repeat for each line wikiFolder in wikiFolders
      set the cursor to busy
      if wikiFolder is among the items of ReservedFolderNames then next repeat
      --
      put dig_GetIP (wikiFolder) into testIP
      put dig_GetNS (wikiFolder) into nsList
      --
      put nsList into dnsArray [wikiFolder]["NS"]
      put testIP into dnsArray [wikiFolder]["A record"]
   end repeat
end atopia_AddDnsToDomainArray


--> Private
-
private function _ConstructGoodBadNumArray @atopiaData, pMinNum
   /*
   Not needed now??
   
   This is a crappy way to index things
   As given that each domain must be unique, we don't need to care about the order?
   Use numbered arrays instead? Or work out dynamically
   */
   
   put atopia_ListLocalWikiFolders (atopiaData) into wikiFolders
   put 1 into lineNum
   repeat for each line wikiFolder in wikiFolders
      put atopia_DomainIsBadInDomainArray (wikiFolder, atopiaData) into isBad
      if isBad is true then
         put lineNum & comma after badNums
      else
         put lineNum & comma after goodNums
      end if
      add 1 to lineNum
   end repeat
   
   -- think this is not needed
   put pMinNum into domainInfoArray ["minNum"]
   put goodNums into domainInfoArray ["goodNums"]
   put badNums into domainInfoArray ["badNums"]
   return domainInfoArray
end _ConstructGoodBadNumArray

private command _DeleteAndReindex @indexedDomainArray, indexNum, someEmail
   put item 2 of the extents of indexedDomainArray into lastIndexNum
   --
   breakpoint -- there is a bug in this code
   --
   delete variable indexedDomainArray [indexNum]
   --
   repeat with rNum = (indexNum + 1) to lastIndexNum
      get indexedDomainArray [rNum]
      put rNum -1 into pNum
      put it into indexedDomainArray [pNum]
   end repeat
   delete variable indexedDomainArray [lastIndexNum]["ownerArray"]
end _DeleteAndReindex

private function _MapOwnerName ownerName, pOwnerEmail
   -- we iagine this being read from a stored fedwiki author card
   -- so that we can customise the card to do manual mapping of emails to names
   
   switch ownerName
      case "ksenya b"
         return "Ksenya"
      case "aaaaaa@gmail.com"
         return "Andrew Orford"
      case "carlosyarza"
         return "Carlos Yarza"
      case "vincent.vanderlubbe"
         return "Vincent van der Lubbe"
      case "mike hales"
      case "matt kuderski"
      case "duke crawford"
         put the number of words of ownerName into wordMax
         repeat with wordNum = 1 to wordMax
            put toUpper (char 1 of word wordNum of ownerName) into char 1 of word wordNum of ownerName
         end repeat
         return ownerName
      default
         return ownerName
   end switch
end _MapOwnerName

function _AtopiaAuthorMerge authorName, authorDomains
   -- set author domain roster
   put authorName & CR & CR & authorDomains into rosterText
   put rosterText into curlyData ["id"]["46fefa6edbe8111f"]
   
   put _AuthorRosterItemID() into rosterItemID
   put authorName & CR & CR & authorDomains into rosterText
   put rosterText into curlyData ["id"][rosterItemID]
   
   -- set author metadata
   put _AtopiaAuthorStatText (authorName, authorDomains, pageTotal) into curlyData ["id"]["988ad6e34d9ba4c8"]
   return curlyData
end _AtopiaAuthorMerge

function _AtopiaAuthorStatText authorName, authorDomains
   put fedray_Construct (authorDomains) into fedray
   --
   put the number of lines of authorDomains into siteNum
   if siteNum = 1 then
      put "one site" into siteText
   else
      put siteNum && "sites" into siteText
   end if
   
   put federation_SiteLastModified (authorDomains, fedray) into lastActive
   date_ConvertMilliseconds lastActive
   --
   put federation_SiteFirstDate (authorDomains, fedray) into fedStartDate
   date_ConvertMilliseconds fedStartDate
   --
   put federation_SiteTotalPageNum (authorDomains, fedray) into pageTotal
   --
   put "[[authorName]] has __[[siteText]]__, and has been writing in the federation since [[fedStartDate]].  He has created a total of __[[pageTotal]] wiki-pages__," into mTemplate
   put space & "and was last active in the federation on [[lastActive]]" after mTemplate
   put "." after mTemplate
   put merge (mTemplate) into authorStatText
   return authorStatText
end _AtopiaAuthorStatText

private function _AuthorRosterItemID
   return "46fefa6edbe8111f"
end _AuthorRosterItemID
