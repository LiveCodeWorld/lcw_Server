script "Global | Server | Menu"
--> MetaData
-
license: GPLv3
name: Global | Server | Menu
type: controller
version: 0.2

/*
*/


--> Menu | Init
-
getprop disabled_DisplayServerArray
   put the server_Array of stack "lib_RemoteServer" into serverArray
   if serverArray is an array then
      return false
   else
      return true
   end if
end disabled_DisplayServerArray

getprop checked_PresentationServer [displayView]
   return presentation_ServerIsRunning()
end checked_PresentationServer


--> Global | Server | Menu
-
on menu_CreateNgrokDomain
   put lcw_Ask("Choose a domain to add:", "wiki.thought.garden", "Ngrok Doamin") into sDomain
   --
   ngrok_CreateDomain sDomain, "eu"
   put the result into rData
end menu_CreateNgrokDomain

on menu_NgrokBearerToken
   put ngrok_GetBearerToken() into ngrokBearerToken
   --
   put lcw_Ask("Set Ngrok bearer token:", ngrokBearerToken, "Authorization: Bearer {API_KEY}") into ngrokBearerToken
   ngrok_SetBearerToken ngrokBearerToken
end menu_NgrokBearerToken

private on ___
end ___

on menu_PresentationServer displayView
   if presentation_ServerIsRunning() then
      presentation_StopServer
   else
      presentation_StartServer
   end if
end menu_PresentationServer

private on _
end _

on menu_ZeroConfServer
   zero_StartServer
end menu_ZeroConfServer

on menu_StartSearch
   zeroconf_StartSearch
end menu_StartSearch

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Server | Menu")
end submenu_Dev
