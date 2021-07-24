script "Global | Dynadot | DomainInfo | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dynadot | DomainInfo | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init

getprop documentation_Params
   return "Simple Dynadot API,Advanced Dynadot API,Dynadot API Settings"
end documentation_Params

getprop disabled_SetParked [displayView]
   put the title_Text of displayView into domainName
   return dynadot_IsParked(domainName)
end disabled_SetParked


--> Global | Dynadot | DomainInfo | Menu
-
on menu_SetDigitalOcean displayView
   put the title_Text of displayView into domainName
   --
   dynadot_SetDigitalOceanNameServers domainName
   --
   display_DynadotDomainInfo domainName, displayView
end menu_SetDigitalOcean

on menu_SetParked displayView
   put the title_Text of displayView into domainName
   --
   dynadot_SetParked domainName
   --
   display_DynadotDomainInfo domainName, displayView
end menu_SetParked

on menu_SetDynadotFolder displayView
   put the title_Text of displayView into domainName
   --    
   dynadot_SetFolder domainName, "Atopia"
   --
   display_DynadotDomainInfo domainName, displayView
end menu_SetDynadotFolder

on _
end _

on menu_Refresh displayView
   put the title_Text of displayView into domainName
   --
   display_DynadotDomainInfo domainName, indexView
end menu_Refresh

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


--> Dev | Menu
-
on menu_FetchAtopiaConfig
   display_AtopiaConfigJson
end menu_FetchAtopiaConfig

on menu_Dig displayView
   put the title_Text of displayView into domainName
   --
   put dig_GetIP (domainName) into someIP
   put dig_GetNS (domainName) into nameServers
   --
   put atopia_CheckIP (someIP) into isAtopia
   --
   put someIP & CR & nameServers & CR & isAtopia
end menu_Dig

on _
end _

on menu_DisplayNameServers displayView
   put the title_Text of displayView into domainName
   --
   put dynadot_GetNameServers (domainName)
end menu_DisplayNameServers

on menu_SetDefaultFolder displayView
   breakpoint -- not sure what default is use "menu_SetParked"
   put the title_Text of displayView into domainName
   --    
   dynadot_SetFolder domainName, "Default"
   --
   display_DynadotDomainInfo domainName, displayView
end menu_SetDefaultFolder
--> Deps
-
