script "Global_Dynadot_Menu"
--> MetaData
-
license: GPLv3
name: Global_Dynadot_Menu
type: controller
version: 0.1


--> Global | Dynadot | Menu
-
on menu_DynadotManagedDomains
   put dynadot_ListManagedDomainNames (true) into domainNames
   --
   _DisplayDomains domainNames, "Managed Domains,dynadot_ListManagedDomainNames()"
end menu_DynadotManagedDomains

on menu_DynadotOceanDomains
   put dynadot_ListOceanDomainNames() into domainNames
   --
   _DisplayDomains domainNames, "Ocean Domains,dynadot_ListOceanDomainNames()"
end menu_DynadotOceanDomains

on menu_DynadotParkedDomains
   put dynadot_ListParkedDomainNames() into domainNames
   --
   _DisplayDomains domainNames, "Parked Domains,dynadot_ListParkedDomainNames()"
end menu_DynadotParkedDomains

on menu_DynadotDomains
   put dynadot_ListDomainNames() into domainNames
   --
   _DisplayDomains domainNames, "Dynadot Domains,dynadot_ListDomainNames()"
end menu_DynadotDomains

on _
end _

on menu_Documentation indexView, whichDocs
   switch whichDocs
      case "Simple Dynadot API"
         launch url "https://www.dynadot.com/domain/api2.html"
         break
      case "Advanced Dynadot API"
         launch url "https://www.dynadot.com/domain/api3.html"
         break
      case "Dynadot API Settings"
         launch url "https://www.dynadot.com/account/domain/setting/api.html"
         break
   end switch
end menu_Documentation

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Dynadot | Menu | Props
-

--> Global | Dynadot | Menu | Disabled
-
getprop disabled_DynadotManagedDomains
   get dynadot_GetIndexedDomainArray()
   if it is an array then
      return false
   else
      return true
   end if
end disabled_DynadotManagedDomains


--> Dev | Menu
-
on menu_StoredDynadotArray
   put dynadot_FetchIndexedDomainArray() into domainArray
   --
   display_Array domainArray, "dynadot_FetchIndexedDomainArray()"
end menu_StoredDynadotArray


--> Events
-
on mDouble_Dynadot indexView, domainName
   display_DynadotDomainInfo domainName
end mDouble_Dynadot


--> Private
-
private command _DisplayDomains domainNames, displayTitle
   display_Lines domainNames, displayTitle, "mDouble_Dynadot"
   put the result into displayView
   set the title_Menu of displayView to "Global | Ocean | Tree | Menu"
   set the line_Menu of displayView to "Global | Ocean | Line | Menu"
end _DisplayDomains
