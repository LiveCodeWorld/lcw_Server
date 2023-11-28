script "Global | Federation | Tree | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Federation | Tree | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [cameraView]
   return exists (cameraView)
end menu_CheckTarget

private function _GetDomain displayView
   -- put item 1 of the selected_Path of arrayView into wikiDomain
   put the selected_Line of displayView into wikiDomain
   return wikiDomain   
end _GetDomain

private function _SubDomain displayView
   put the top_Line of displayView into subDomain
   -- put the selected_Line of displayView into subDomain
   return subDomain
end _SubDomain

private command _SetInfo displayView, @wikiDomain, @pSlug
   put _SubDomain (displayView) into wikiDomain
   -- put the selected_Line of displayView into pageTitle
   -- put the top_Array of displayView into domainArray
   put the selected_Array of displayView into pageInfoArray
   put pageInfoArray ["slug"] into pSlug
end _SetInfo

getprop disabled_LaunchDomain [arrayView]
   if the title_Text of arrayView = "Federation Model" then
      return false
   else
      return true
   end if
end disabled_LaunchDomain


--> Global | Federation | Tree | Line | Menu
-
on menu_RecentWikiChanges displayView
   _SetInfo displayView, wikiDomain, pSlug
   --
   display_WikiDomain wikiDomain
   display_RecentWikiPages wikiDomain, "2 weeks"
end menu_RecentWikiChanges

on menu_WordCloud displayView
   /*
   curl --request POST 
   --url https://textvis-word-cloud-v1.p.rapidapi.com/v1/textToCloud 
   --header 'accept: application/json' 
   --header 'content-type: application/json' 
   --header 'x-rapidapi-host: textvis-word-cloud-v1.p.rapidapi.com' 
   --header 'x-rapidapi-key: PBcK3YtG6hMBoA2BjGFiPi7GnxjZFuzR' 
   --data '{  "text": "This is a test. I repeat, this is a test. We are only testing the functionality of this api, nothing else. End of test.",  "scale": 0.5,  "width": 400,
   "height": 400,  "colors": ["#375E97", "#FB6542", "#FFBB00", "#3F681C"],  "font": "Tahoma",  "use_stopwords": true,  "language": "en",  "uppercase": false}'
   */
   _SetInfo displayView, wikiDomain, pSlug
   --
   put pageArray_FetchText (wikiDomain, pSlug) into pageText
   -- put "This is a test. I repeat, this is a test. We are only testing the functionality of this api, nothing else. End of test." into pageText
   
   put wordcloud_Fetch (pageText) into someImage
   --
   display_Image someImage
end menu_WordCloud

private on _
end _

on menu_LaunchDomain displayView
   -- put the top_Array of arrayView into serverArray
   put item 1 of the selected_Path of displayView into domainName
   launch url ("http://" & domainName)
end menu_LaunchDomain

on menu_PageKeyPhrases displayView
   _SetInfo displayView, wikiDomain, pSlug
   --
   put azure_FetchPageKeyArray (wikiDomain, pSlug) into responseArray
   --
   display_Data responseArray, "Key Phrases", "Azure"
end menu_PageKeyPhrases

on menu_PageKeyEntities displayView
   _SetInfo displayView, wikiDomain, pSlug
   --
   -- put azure_FetchPageEntityArray (wikiDomain, pSlug) into responseArray
   put azure_FetchPageEntityArray (wikiDomain, pSlug, "v2.1") into responseArray
   --
   display_Data responseArray, "Entities", "Azure"
   --
   put azure_ExtractUniqueEntities (responseArray)
end menu_PageKeyEntities

private on __
end __

on menu_AzureDocs
   launch_AzureDocs
end menu_AzureDocs

on menu_MonkeyDocs
   launch_MonkeyDocs
end menu_MonkeyDocs

private on ___
end ___

on submenu_Dev
   return menu_DevTitle ("Global | Federation | Tree | Line | Menu")
end submenu_Dev
