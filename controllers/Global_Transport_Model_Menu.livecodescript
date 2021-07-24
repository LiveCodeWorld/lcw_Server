script "Global | Transport | Model | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Transport | Model | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Events
-
on doubleUp_TransportModel dispplayView, shortModelFile
   put transport_FetchModelFromShortFile (shortModelFile) into modelData
   --
   display_Data modelData, shortModelFile, "Transport Model"
end doubleUp_TransportModel


--> Menu | Props
-
getprop menu_Target [tObject]
   -- called first
   put the display_View of tObject into displayView
   put the displayed_Data of displayView into LocalArray ["dataArray"]
   --
   return displayView
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget


--> Global | Transport | Model | Menu
-
on menu_DisplayTransportModels
   put transport_ListModelFiles() into shortFiles
   --
   display_Data shortFiles, "Models", "Transport Server"
   put the result into displayView
   --
   display_SetInteractions displayView, "Transport | Model", "doubleUp_TransportModel"
   return displayView
end menu_DisplayTransportModels

on menu_DisplayAtopiaCatModel
   display_AtopiaCatModel
end menu_DisplayAtopiaCatModel

on _
end _

on menu_StoreAtopiaCatArray
   -- put atopia_GetLastUpDate() into laterThanSeconds
   put federation_GetLastUpDate() into laterThanSeconds
   put atopia_ConstructCatModel (laterThanSeconds) into atopiaCatModel
   --
   transport_PostAtopiaCatModel atopiaCatModel
   put the result into rPageArray
   --
   put transport_FetchAtopiaCatModel() into atopiaCatModel
   display_Data atopiaCatModel, "Categorised Date Array", "Atopia Server"
   display_PageArray rPageArray
end menu_StoreAtopiaCatArray

on menu_UpdateLastAtopiaUpdate
   -- put atopia_GetLastUpDate() into laterThanSeconds
   put federation_GetLastUpDate() into laterThanSeconds
   put atopia_ConstructCatModel (laterThanSeconds) into atopiaCatModel
   --
   atopia_SetLastAtopiaUpdateRosters catDateArray
end menu_UpdateLastAtopiaUpdate

on _
end _

on menu_PostFederationUpdate
   put "http://rest.livecode.world/scrape" into postURL
   --
   put the seconds into postArray ["date"]
   --
   put 58105 into postArray ["scan"]["pages"]
   put 1229 into postArray ["scan"]["sites"]
   --
   put 7619 into postArray ["index"]["counts"]
   put 2321 into postArray ["index"]["sites"]
   put 42532 into postArray ["index"]["slugs"]
   --
   put json_FromArray (postArray) into someJSON
   put jsonrpc_Post (someJSON, postURL)
end menu_PostFederationUpdate

on _
end _

on menu_CreateTransportModel
   put atopia_FetchDomainArray() into modelData
   -- put pageArray_FetchByTitle ("roster.fedwiki.org", "Register Sites Template") into modelData
   --
   transport_PostProtectedModel modelData, "bosmeg"
   put the result into rPageArray
   --
   display_PageArray rPageArray
end menu_CreateTransportModel

on menu_CreateTransportPage
   breakpoint
   -- put transport_FetchRosterPageArray ("Register Sites Template", "oneworld.wiki") into pageArray
   put pageArray_FetchByTitle ("roster.fedwiki.org", "Register Sites Template") into pageArray
   pageArray_Rename pageArray, "One World Sites", "roster.fedwiki.org,fedwiki.org"
   --
   put json_FromArray (pageArray) into pageJSON
   put jsonrpc_Post (pageJSON, "https://rest.livecode.world/register/writePageJson") into rPageJson
   --
   display_JSON rPageJson
end menu_CreateTransportPage

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_SshToAtopiaInTerminal
   put "ssh root@fedwiki.org" into shellScript
   --
   terminal_PasteInNewTab shellScript
end menu_SshToAtopiaInTerminal

on menu_CdToModulesFolder
   put "cd" && atopia_ModulesFolder() into shellScript
   --
   terminal_PasteScript shellScript
end menu_CdToModulesFolder

on menu_InstallModule
   put "npm i" && "wiki-plugin-map" into shellScript
   --
   terminal_PasteScript shellScript
end menu_InstallModule

on menu_RestartWiki
   put "restart wiki" into shellScript
   --
   terminal_PasteScript shellScript
end menu_RestartWiki

on _
end _

on menu_SshToLivecodeWorldInTerminal
   -- put "ssh root@rest.livecode.world" into shellScript -- also works
   terminal_PasteInNewTab "cd ~/.ssh;ssh -i root root@rest.livecode.world"
end menu_SshToLivecodeWorldInTerminal

on menu_PasteCertbotScript
   terminal_PasteScript "./tmp/certbot-auto --apache --no-redirect"
end menu_PasteCertbotScript

on _
end _

on menu_NodeModulesPath
   -- npm list -g --depth=0
   put "ssh -t root@fedwiki.org" into shellScript
   put atopia_ModulesFolder() into mFolder
   put space & kwote ("ls" && mFolder, "'") after shellScript
   put space & ";" after shellScript
   put space & "bash --login" after shellScript
   --
   terminal_PasteInNewTab shellScript
end menu_NodeModulesPath
