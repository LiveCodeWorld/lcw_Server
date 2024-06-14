script "Global | Caddy | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Caddy | Menu
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
   -- put display_MenuTarget (tObject) into dView
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Caddy | Menu
-
on menu_StartCaddy
   caddy_ToggleProxy
end menu_StartCaddy

getprop checked_StartCaddy
   return caddy_IsRunning()
end checked_StartCaddy

on menu_StopAllCaddyServers
   caddy_Stop
   put the result into pIDs
   --
   lcw_Notify ("Stopped Caddy servers." && pIDs)
end menu_StopAllCaddyServers

private on _
end _

on menu_SaveJson
   put caddyAsset_Get ("caddy.json")
end menu_SaveJson

on menu_SaveCaddyFile
   put ":2015" into cText
   put CR after cText
   put CR & "respond 'Hello, world!" after cText
   replace "'" with quote in cText
   --
   caddyAsset_Set "Caddyfile", cText
end menu_SaveCaddyFile

private on __
end __

on menu_GetConfigData
   display_CaddyAdmin
   display_CaddyTools
end menu_GetConfigData

on menu_CaddyAdapt
   caddy_Adapt
   put the result
end menu_CaddyAdapt

on menu_TestSet dView
   put lcw_Ask ("What new text?", "Work smarter, not harder.", dView) into newTest
   caddy_TestSetBody newTest
   --
   display_CaddyTools
end menu_TestSet

private on ___
end ___

on menu_PostAdapt
   
end menu_PostAdapt

on menu_DisplayCaddyAdmin
   display_CaddyTools
   --
   put caddy_ConfigUrl() into someUrl
   display_Browser someUrl
end menu_DisplayCaddyAdmin

on menu_CaddyApiHelp
   display_Browser "https://caddyserver.com/docs/api"
end menu_CaddyApiHelp

on menu_Refresh
   display_CaddyTools
end menu_Refresh

on submenu_Dev
   return menu_DevTitle ("Global | Caddy | Menu")
end submenu_Dev
