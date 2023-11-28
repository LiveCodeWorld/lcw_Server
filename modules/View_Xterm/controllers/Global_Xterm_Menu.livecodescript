script "Global | Xterm | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Xterm | Menu
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
   put xterm_ProcessID() into LocalArray ["TtydProcessID"]
   return the browser_View of tObject
end menu_Target

getprop checked_StartXterm [browserView]
   return LocalArray ["TtydProcessID"] is not empty
end checked_StartXterm


--> Global | Xterm | Menu
-
on menu_StartXterm browserView
   if xterm_IsRunning() is true then
      xterm_Stop false
      set the browser_URL of browserView to empty
   else
      xterm_Start
      put the result into pID
      --
      display_Xterm browserView
   end if
end menu_StartXterm

private on _
end _

on menu_CreateTunnels xtermView
   breakpoint
   put "people,project" into subNames
   repeat for each item subName in subNames
      put subName & ".astralship.wiki" into wDomain
      --
      put merge ("loclx tunnel http --reserved-domain '[[wDomain]]'") into shellLine
      replace "'" with quote in shellLine
      put shellLine & ";" after someShell
   end repeat
   delete char -2 to -1 of someShell
   --
   shell_Do someShell, "paste", xtermView
end menu_CreateTunnels

on menu_XtermClear xtermView
   ttyd_Execute "clear", xtermView
end menu_XtermClear

private on __
end __

on submenu_Tunnel
   return "Global | Tunnel | Install | Menu"
end submenu_Tunnel

on submenu_InstallWhisper
   return "Global | Whisper | Install | Menu"
end submenu_InstallWhisper

on submenu_InstallWiki
   return "Global | Wiki | Install | Menu"
end submenu_InstallWiki

on submenu_Nvm
   return "Global | NVM | Menu"
end submenu_Nvm

on submenu_Dev
   return menu_DevTitle()
end submenu_Dev
