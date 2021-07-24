script "Global | Atopia | Top | Menu"
--> MetaData
-
license: GPLv3
name: Global | Atopia | Top | Menu
type: controller
version: 0.1


--> Global | Atopia | Top | Menu
-
on submenu_Atopia
   return "Global | Atopia | Display | Menu"
end submenu_Atopia

on _
end _

on menu_CheckFarms indexView
   put the displayed_Index of indexView into domainNames
   --
   atopia_ConstructFarmArray domainNames, configArray, farmArray, colourArray
   --
   set the line_Colours of indexView to colourArray
   atopia_SetFarmArray farmArray
   --
   display_Array farmArray, "Farm Array"
end menu_CheckFarms

on _
end _

on menu_ListForks
   local forkArray
   put fedray_GetArray() into federationArray
   -- 
   put federationArray ["slug"] into slugArray
   put fedray_SortSlugArray (slugArray) into rankTable
   put line 1 to 40 of rankTable
end menu_ListForks

on menu_ListDomains
   put fedray_GetArray() into federationArray
   --
   put federationArray ["domain"] into dArray
   repeat for each key fedDomain in dArray
      set the cursor to busy
      put dArray [fedDomain] into slugArray
      put keys (slugArray) into domainSlugs
      put the number of lines of domainSlugs into slugNum
      --
      put fedDomain & tab & slugNum & CR after dTable
   end repeat
   delete char -1 of dTable
   --
   set the itemdelimiter to tab
   sort numeric descending lines of dTable by item 2 of each
   put line 1 to 50 of dTable
end menu_ListDomains

on _
end _

on menu_ConstructFederationArrays
   local federationArray
   --
   put fedwiki_FetchAllDomainNames() into allDomainNames
   -- fedwiki_AddDomainsToFederationArray federationArray, allDomainNames
   fedwiki_SetFederationArrayDomains federationArray, allDomainNames
   --
   fedray_SetArray federationArray
   display_Array federationArray, "Federation Array", "Global | Atopia | Top | Menu"
end menu_ConstructFederationArrays

on menu_ConstructAtopiaArrays
   breakpoint
   local federationArray
   --
   put atopia_FetchFolders() into atopiaDomains
   -- put fedray_GetArray ("atopia.array") into federationArray
   --
   fedwiki_SetFederationArrayDomains federationArray, atopiaDomains
   --
   fedray_SetArray federationArray, "atopia.array"
   display_Array federationArray, "Atopia Array", "Global | Atopia | Top | Menu"
end menu_ConstructAtopiaArrays

on _
end _

on menu_UpdateOceanDomainInfo
   digitalocean_UpdateDomainInfoArray
   put the result into domainInfoArray
   if the result is not an array then
      lcw_AnswerWarning "There was a problem updating the domain info array!"
      exit to top
   end if
   --
   display_Array domainInfoArray, "digitalocean_UpdateDomainInfoArray"
end menu_UpdateOceanDomainInfo

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Atopia | Top | Menu | Props
-

--> Global | Atopia | Top | Menu | Disabled
-
getprop disabled_DisplayAtopiaArray
   put fedray_GetArrayFile ("atopia.array") into modelDataFile
   return there is not a file modelDataFile
end disabled_DisplayAtopiaArray

getprop disabled_DisplayFederationArray
   put fedray_GetArrayFile() into modelDataFile
   return there is not a file modelDataFile
end disabled_DisplayFederationArray

getprop disabled_SaveFederationArray
   put fedray_GetArrayFile() into modelDataFile
   return there is not a file modelDataFile
end disabled_SaveFederationArray


--> Dev | menu
-
on menu_ExtractOwner 
   put fedwiki_FetchOwnerName ("sites.fed.wiki") 
end menu_ExtractOwner

on _
end _

on menu_AddDomainMetadata
   put fedray_GetArray("atopia.array") into federationArray
   put fedwiki_ExtractDomainNames (federationArray) into domainNames
   repeat for each line domainName in domainNames
      set the cursor to busy
      fedwiki_AddDomainMetadata federationArray, domainName
   end repeat
   fedray_SetArray federationArray, "atopia.array"
end menu_AddDomainMetadata

on menu_AddAtopiaForkEvents arrayView
   put fedray_GetArray ("atopia.array") into federationArray
   --
   fedwiki_AddForksFederationArray federationArray
   --
   set the displayed_Array of arrayView to federationArray
   breakpoint
   fedray_SetArray federationArray, "atopia.array"
end menu_AddAtopiaForkEvents

on menu_DisplayAtopiaArray arrayView
   display_Fedray
end menu_DisplayAtopiaArray

on menu_SaveAtopiaArray arrayView
   put the displayed_Array of arrayView into federationArray
   --
   fedray_SetArray federationArray, "atopia.array"
   put the result into dataFile
   put dataFile
end menu_SaveAtopiaArray

on menu_DeleteAtopiaArray arrayView
   fedray_SetArray empty, "atopia.array"
   put the result into dataFile
   put dataFile
end menu_DeleteAtopiaArray

on _
end _

on menu_CseSearch
   put lcw_Ask ("What do you want to search for...:", "wiki") into searchTerm
   put cse_SearchAndConstructPageArray (searchTerm) into pageArray
   --
   display_Array pageArray
end menu_CseSearch

on menu_DrawGraph displayView
   answer folder "Select folder..."
   put it into oFolder
   put "hierarchical" into oStyle
   --
   put the displayed_Array of displayView into linkArray
   --
   put overlayArray_FromLinkArray (linkArray) into overlayArray
   overlayArray_CreateAndDisplayGraph overlayArray, oStyle, oFolder
end menu_DrawGraph

on menu_ConstructForkArray displayView
   put the displayed_Array of displayView into federationArray
   --
   put fedray_ConstructForkArray (federationArray) into linkArray
   display_Array linkArray, "Fork Array", "Global | Atopia | Top | Menu"
   --
   put fedray_ConstructLinkArray (federationArray) into linkArray
   display_Array linkArray, "Link Array", "Global | Atopia | Top | Menu"
end menu_ConstructForkArray

on _
end _

on menu_AddFederationForkEvents arrayView
   put fedray_GetArray() into federationArray
   --
   fedwiki_AddForksFederationArray federationArray
   --
   set the displayed_Array of arrayView to federationArray
   breakpoint
   fedray_SetArray federationArray
end menu_AddFederationForkEvents

on menu_DisplayFederationArray arrayView
   put fedray_GetArray() into federationArray
   --
   display_Array federationArray, "Federation Array", "Global | Atopia | Top | Menu"
end menu_DisplayFederationArray

on menu_SaveFederationArray arrayView
   put the displayed_Array of arrayView into federationArray
   --
   fedray_SetArray federationArray
   put the result
end menu_SaveFederationArray

on _
end _

on menu_FetchAllWikiDomains
   put fedwiki_FetchAllDomainNames() into allDomainNames
   --
   put atopia_FetchFolders() into atopiaDomains         
   repeat for each line testDomain in atopiaDomains
      set the cursor to busy
      if testDomain is among the lines of allDomainNames then
         put empty into goodBadArray ["good"][testDomain]
      else
         put empty into goodBadArray ["bad"][testDomain]
      end if
   end repeat
   put goodBadArray ["bad"] into badArray
   put keys (badArray) into missingDomains
   sort missingDomains
   
   repeat for each line missingDomian in missingDomains
      set the cursor to busy
      put fedwiki_FetchSitemap (missingDomian) into sitemapJSON
      put json_ToArray (sitemapJSON) into sitemapArray
      put item 2 of the extents of sitemapArray into pageNum
      if pageNum > 3 then
         put sitemapArray into goodMissingDomainArray [missingDomian]
      end if
   end repeat
   --
   display_Array goodMissingDomainArray, "Missing Domains"
   --
   put keys (goodMissingDomainArray) into goodMissingDomains
   put the number of lines of goodMissingDomains & CR & CR & goodMissingDomains
end menu_FetchAllWikiDomains

--> Deps
-
