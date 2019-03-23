script "Global_Federation_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Federation_Line_Menu
type: controller
version: 0.1


--> Global | Federation | Line | Menu
-
on menu_LaunchDomain arrayView
   -- put the top_Array of arrayView into serverArray
   put item 1 of the selected_Path of arrayView into domainName
   launch url ("http://" & domainName)
end menu_LaunchDomain


--> Global | Federation | Line | Menu | Props
-

--> Global | Federation | Line | Menu | Disabled
-
getprop disabled_LaunchDomain [arrayView]
   if the title_Text of arrayView = "Federation Model" then
      return false
   else
      return true
   end if
end disabled_LaunchDomain
