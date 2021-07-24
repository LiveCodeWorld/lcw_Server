script "Global | Atopia | Author | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Atopia | Author | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init

private command atopia_ConstructOwnershipArray pDeleteExisting, displayView
   put atopia_FetchFolders() into wikiFolders
   set the displayed_Index of displayView to wikiFolders
   --
   if pDeleteExisting is true then
      atopia_SetLocalEmailOwnerData empty
      put empty into ownershipArray
   else
      put atopia_GetLocalEmailOwnerData() into ownershipArray
   end if
   --
   atopia_AddOwnershipToDomainArray ownershipArray, wikiFolders, displayView
   --
   atopia_SetLocalEmailOwnerData ownershipArray
   return ownershipArray
end atopia_ConstructOwnershipArray


--> Global | Atopia | Author | Menu
-
on submenu_Display
   return "Global | Atopia | Author | Display | Menu"
end submenu_Display

on _
end _

on menu_VisitAtopiaAuthorModel
   fedwiki_Launch "roster.fedwiki.org", "Atopia Author Model"
end menu_VisitAtopiaAuthorModel

on menu_VisitFederationAuthorModel
   fedwiki_Launch "roster.fedwiki.org", "Author Model"
end menu_VisitFederationAuthorModel

on _
end _

on menu_CreateAuthorModelFromFedray displayView
   lcw_Answer "Construct federation author model from fedray, and store to Author Model on server?", displayView
   author_CreateModelFromFedray
   put the result into authorArray
   --
   set the line_Menu of displayView to "Global | Federation | Author | Line | Menu"
   set the displayed_Array ["author-model"] of displayView to authorArray
end menu_CreateAuthorModelFromFedray

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayFederationAuthorData
   display_AuthorData
end menu_DisplayFederationAuthorData

on menu_RestoreFedrayFromAuthorData displayView
   put author_FetchModelArray() into authorData
   put authorData ["No name"] into noNameArray
   delete variable authorData ["No name"]
   --
   put noNameArray into fedray
   --
   repeat for each key authorName in authorData
      put authorData [authorName] into authorArray
      repeat for each key wikiDomain in authorArray
         put authorArray [wikiDomain] into fedray [wikiDomain]
      end repeat
   end repeat
   --
   display_Data fedray, "Converted", "Fedray"
   --
   lcw_Answer "Store this recreated fedray? This will overwrite the current fedray.", displayView
   fedray_StoreModel fedray
end menu_RestoreFedrayFromAuthorData

on menu_DisplayFedray
   display_Fedray
end menu_DisplayFedray

on _
end _

on menu_BuildLocalAtopiaOwnershipArray displayView
   lcw_Answer "Do you want to build a local ownership array for each Atopia wiki folder?", displayView
   --
   atopia_ConstructOwnershipArray true, displayView
   put the result into ownershipArray
   --
   fedray_AddOwnershipArray ownershipArray, "atopia.array"
   --
   lcw_Answer "Built and saved local ownership array!", displayView
   --
   display_LocalAuthorNameData
end menu_BuildLocalAtopiaOwnershipArray

on menu_UploadLocalAtopiaAuthorData displayView
   lcw_Answer "Store the displayed local authorData to the wiki json store?", displayView
   --
   put atopia_GetLocalAuthorNameData() into authorNameData
   atopia_StoreAuthorNameData authorNameData
   menu_DisplayRemoteAtopiaAuthorNameData
end menu_UploadLocalAtopiaAuthorData

on menu_TestLastWeeksAuthorDomains displayView
   put "David Bovill,Carlos Yarza,Charlotte Carter" into authorNames
   --
   put atopia_GetLocalAuthorNameData() into authorNameData
   --
   put atopia_FetchPodDomains (authorNames, authorNameData, "1 week") into wikiDomains
   --
   put wikiDomains
end menu_TestLastWeeksAuthorDomains

on menu_UpdateGardenPodActivity displayView
   put "Garden Pod" into podName
   put "David Bovill,Carlos Yarza,Charlotte Carter" into authorNames
   put "1 week" into sincePeriod
   put "mediagarden.org" into wikiDomain
   --
   put atopia_GetLocalEmailOwnerData() into ownershipArray
   atopia_CreatePodActivityPage podName, authorNames, wikiDomain, ownershipArray, sincePeriod
   --
   put the result into shellResult
   if shellResult is empty then
      put podName && "Activity" into pageTitle
      fedwiki_Launch wikiDomain, pageTitle
   else
      return shellResult
   end if  
end menu_UpdateGardenPodActivity
