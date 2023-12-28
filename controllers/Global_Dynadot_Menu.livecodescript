script "Global | Dynadot | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dynadot | Menu
type: controller
version: 0.1


--> Menu | Props
-
on mDouble_Dynadot indexView, domainName
   display_DynadotDomainInfo domainName
end mDouble_Dynadot

private function _DisplayDisabled testTitle, indexView
   put the title_Text of indexView into titleText
   if titleText = testTitle then
      return "delete"
   else
      return false
   end if
end _DisplayDisabled

getprop documentation_Params
   return "Simple Dynadot API,Advanced Dynadot API,Dynadot API Settings"
end documentation_Params

getprop disabled_DynadotDomains [indexView]
   return _DisplayDisabled ("Dynadot Domains", indexView)
end disabled_DynadotDomains

getprop disabled_DynadotManagedDomains [indexView]
   return _DisplayDisabled ("Managed Domains", indexView)
end disabled_DynadotManagedDomains

getprop disabled_DynadotOceanDomains [indexView]
   return _DisplayDisabled ("Ocean Domains", indexView)
end disabled_DynadotOceanDomains


--> Global | Dynadot | Menu
-
on menu_Filter displayView
   put the wiki_Filter of displayView into wikiFilter
   put lcw_Ask ("Filter domains...", wikiFilter, "Wiki Filter", displayView) into wikiFilter
   set the wiki_Filter of displayView to wikiFilter
   --
   display_Dynadot displayView, wikiFilter
end menu_Filter

on menu_DynadotDomains indexView
   display_Dynadot indexView
end menu_DynadotDomains

private on _
end _

on menu_DynadotManagedDomains indexView
   display_DynadotManaged indexView
end menu_DynadotManagedDomains

on menu_DynadotOceanDomains indexView
   display_DynadotOcean indexView
end menu_DynadotOceanDomains

on menu_DynadotParkedDomains indexView
   display_DynadotParked indexView
end menu_DynadotParkedDomains

private on __
end __

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
   return menu_DevTitle ("Global | Dynadot | Menu")
end submenu_Dev
