script "Global | Caddy | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Caddy | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget

command caddy_TestSetBody sBody
   -- caddy_TestSetBody "Work smarter, not harder."
   put caddy_ConstructCurl (sBody) into sShell
   put shell (sShell) into sResult
   
   /*
   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
   Dload  Upload   Total   Spent    Left  Speed
   
   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
   100   106  100    79  100    27   5240   1790 --:--:-- --:--:-- --:--:--  7066
   {"error":"invalid traversal path at: config/apps/http/servers/example/routes"}
   */
   put line 1 to 3 of sResult into sHeader
   delete line 1 to 3 of sResult
   return sResult
end caddy_TestSetBody


--> Global | Caddy | Dev | Menu
-
on menu_TestSet dView
   put lcw_Ask ("What new text?", "Work smarter, not harder.", dView) into newTest
   caddy_TestSetBody newTest
   --
   display_CaddyTools
end menu_TestSet

on menu_SaveJson
   put caddyAsset_Get ("caddy.json")
end menu_SaveJson
