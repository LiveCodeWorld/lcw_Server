script "Global_Federation_Author_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Federation_Author_Line_Menu
type: controller
version: 0.1


--> Global | Federation | Author | Line | Menu
-
on menu_PublishAuthor arrayView
   put item 1 of the selected_Path of arrayView into authorName
   put the top_Array of arrayView into authorArray
   put keys (authorArray) into authorDomains
   put text_InitialCaps (authorName) into authorName
   put lcw_Ask ("Create or update author page for:", authorName) into authorName
   --
   federation_AuthorCreate authorName, authorDomains
end menu_PublishAuthor


--> Global | Federation | Author | Line | Menu | Props
-

--> Global | Federation | Author | Line | Menu | Disabled
-
