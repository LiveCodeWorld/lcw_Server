script "Global | Azure | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Azure | Tree | Menu
type: controller
version: 0.1


--> Global | Azure | Tree | Menu
-
on menu_DisplayAzureEntities arrayView
   put the title_Text of arrayView into wikiDomain
   put lcw_Ask ("What wiki domain do you want to index...", wikiDomain) into wikiDomain
   --
   display_AzureEntities wikiDomain
   if the result is empty then
      lcw_AnswerWarning "Not a wiki domain?", arrayView
   end if
end menu_DisplayAzureEntities

on menu_ConstructDomainArray arrayView
   put the title_Text of arrayView into wikiDomain
   put lcw_Ask ("What wiki domain do you want to index...", wikiDomain) into wikiDomain
   --
   put wikiDomain & ",domainArray_Construct()" into someTitle
   put domainArray_Construct (wikiDomain) into domainArray
   display_Array domainArray, someTitle, "Global | Azure | Tree | Menu"
end menu_ConstructDomainArray

on menu_FetchDomainLinkArray arrayView
   -- put the title_Text of arrayView into wikiDomain
   put the displayed_Array of arrayView into domainArray
   put domainLinkArray_FetchFromSitemaps (domainArray, true) into domainLinkArray
   -- 
   put wikiDomain & ",domainLinkArray_FetchFromSitemaps()" into someTitle
   display_Array domainLinkArray, someTitle, "Global | Azure | Tree | Menu"
end menu_FetchDomainLinkArray

on _
end _

on menu_ExtractDispayedEntities arrayView
   put the displayed_Array of arrayView into docResultArray
   put azure_ExtractUniqueEntities (docResultArray)
end menu_ExtractDispayedEntities

on menu_EmptyCachedUrls
   repeat for each line someURL in the cachedurls
      set the cursor to busy
      unload url someURL
   end repeat
end menu_EmptyCachedUrls


--> Global | Azure | Tree | Menu | Props
-

--> Global | Azure | Tree | Menu | Disabled
-
