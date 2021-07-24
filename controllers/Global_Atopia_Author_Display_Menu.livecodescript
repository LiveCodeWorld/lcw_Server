script "Global | Atopia | Author | Display | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Atopia | Author | Display | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-


--> Global | Atopia | Author | Display | Menu
-
on menu_DisplayNoNames displayView
   -- put author_FetchModelData() into authorData
   put author_ConstructFromFedray() into authorData
   --
   put authorData ["No name"] into noNameArray
   set the displayed_Data ["No name"] of displayView to noNameArray
end menu_DisplayNoNames

on _
end _

on menu_DisplayAuthorModelFromFedray displayView
   put author_ConstructFromFedray() into authorArray
   --
   display_AuthorData authorArray, "Constructed Author Array", "Fedray"
end menu_DisplayAuthorModelFromFedray

on menu_DisplayAuthorModelData
   put author_FetchModelData() into authorModelData
   --
   display_AuthorData authorModelData, "author-model", "roster.fedwiki.org"
end menu_DisplayAuthorModelData

on menu_DisplayAtopiaAuthorNameData
   put atopia_FetchAuthorNameData() into atopiaAuthorNameData
   --
   display_AuthorData atopiaAuthorNameData, "atopia-author-model", "roster.fedwiki.org"
end menu_DisplayAtopiaAuthorNameData


--> Dev | Menu
-
on menu_UploadLocalAtopiaAuthorData displayView
   lcw_Answer "Store the dsplayed local authorData to the 'atopia-author-model' wiki json store?", displayView
   --
   put atopia_GetLocalAuthorNameData() into authorNameData
   --
   atopia_StoreAuthorNameData authorNameData
   --
   menu_DisplayRemoteAtopiaAuthorNameData
end menu_UploadLocalAtopiaAuthorData

on _
end _

on menu_DisplayLocalAuthorNameData
   display_LocalAuthorNameData
end menu_DisplayLocalAuthorNameData

on menu_DisplayLocalAtopiaAuthorIndex
   display_LocalAtopiaAuthors
end menu_DisplayLocalAtopiaAuthorIndex


--> Deps
-
