script "Global | Azure | Tree | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Azure | Tree | Line | Menu
type: controller
version: 0.1


--> Global | Azure | Tree | Line | Menu
-
on menu_DisplayLinkArray arrayView
   put the top_Array of arrayView into pageArray
   put pageArray_ExtractLinkArray (pageArray) into linkArray
   --
   display_Array linkArray, "pageArray_ExtractLinkArray()"
end menu_DisplayLinkArray

on menu_DisplayPageArray arrayView
   put the top_Array of arrayView into pageArray
   put pageArray_ExtractForkArray
   --
   display_Array pageArray
end menu_DisplayPageArray


--> Global | Azure | Tree | Line | Menu | Props
-

--> Global | Azure | Tree | Line | Menu | Disabled
-
