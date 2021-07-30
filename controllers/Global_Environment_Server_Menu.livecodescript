script "Global | Environment | Server | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Environment | Server | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_IsSimple
   return mArray_GetSimple()
end menu_IsSimple

getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target


--> Global | Environment | Server | Menu
-
on menu_SshToAtopiaInTerminal
   put "ssh root@fedwiki.org" into shellScript
   --
   terminal_PasteInNewTab shellScript
end menu_SshToAtopiaInTerminal

on menu__RestartWiki
   put "restart wiki" into shellScript
   --
   terminal_PasteScript shellScript
end menu__RestartWiki

on _
end _

on menu__SshToLivecodeWorldInTerminal
   -- put "ssh root@rest.livecode.world" into shellScript -- also works
   terminal_PasteInNewTab "cd ~/.ssh;ssh -i root root@rest.livecode.world"
end menu__SshToLivecodeWorldInTerminal

on menu__PasteCertbotScript
   terminal_PasteScript "./tmp/certbot-auto --apache --no-redirect"
end menu__PasteCertbotScript

on _
end _

on menu_CdToModulesFolder
   put "cd" && atopia_ModulesFolder() into shellScript
   --
   terminal_PasteScript shellScript
end menu_CdToModulesFolder

on menu__InstallModule
   put "npm i" && "wiki-plugin-map" into shellScript
   --
   terminal_PasteScript shellScript
end menu__InstallModule


