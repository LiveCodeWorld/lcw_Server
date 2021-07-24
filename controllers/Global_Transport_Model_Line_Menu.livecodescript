script "Global | Transport | Model | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Transport | Model | Line | Menu
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
   -- called first
   put the display_View of tObject into displayView
   --
   return displayView
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

private function _ShortModelFile displayView
   put the selected_Line of displayView into shortModelFile
   return shortModelFile
end _ShortModelFile


--> Global | Transport | Model | Line | Menu
-
on menu_DisplayModel displayView
   put _ShortModelFile (displayView) into shortModelFile
   --
   put transport_FetchModelFromShortFile (shortModelFile) into modelData
   display_Data modelData, shortModelFile, "Transport Model"
end menu_DisplayModel

on _
end _

on menu_DeleteModel displayView
   put _ShortModelFile (displayView) into shortModelFile
   --
   lcw_Answer "Are you sure you want to delete the model [[shortModelFile]]?", displayView, shortModelFile
   set the cursor to watch
   --
   transport_PostDeleteShortModelFile shortModelFile
   /*
   put the result into rArray
   display_Data rArray, "Delete Model Result", "Transport Server"
   */
   display_TransportModels
end menu_DeleteModel

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Deps
-
