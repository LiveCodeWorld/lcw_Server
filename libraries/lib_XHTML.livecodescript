script "lib_XHTML"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_XHTML
type: library
version: 0.1

/*
This library uses revXML to deal with HTML
Should work will well formed XHTML
Often best to extract the <body> tag before processing as <head> section messes up the node structure.
*/


--> Working on
-
function html_ConstructListXml someHTML, divClassName, iListArray, pFormat
   put html_GetBody (someHTML) into bodyHTML
   body_SetDivList bodyHTML, divClassName, iListArray, pFormat
   html_SetBody someHTML, bodyHTML
   return someHTML
end html_ConstructListXml

function html_ConstructListLines iListArray, pIndentString
   put "            " into pIndentString
   repeat with indexNum = 1 to item 2 of the extents of iListArray
      put iListArray [indexNum]["href"] into hrefURL
      put iListArray [indexNum]["someTag"] into someTag
      --
      put merge ("<li><a href='[[hrefURL]]'>[[someTag]]</a></li>") into newXML
      put pIndentString & newXML & CR after listLines
   end repeat
   delete char -1 of listLines
   replace "'" with quote in listLines
   return listLines
end html_ConstructListLines

command html_AddToListArray @iListArray, someTag, hrefURL
   put (item 2 of the extents of iListArray) + 1 into indexNum
   --
   put someTag into iListArray [indexNum]["someTag"]
   put hrefURL into iListArray [indexNum]["href"]
end html_AddToListArray

function html_GetListXml someHTML, divClassName, pFormat
   put html_GetBody (someHTML) into bodyHTML
   put revXMLCreateTree (bodyHTML, false, true, false) into treeID
   put bodyID_GetListXML (treeID, divClassName, pFormat) into listXml
   revXMLDeleteTree treeID
   return listXml
end html_GetListXml

command body_SetDivList @bodyHTML, divClassName, iListArray, pFormat
   put revXMLCreateTree (bodyHTML, false, true, false) into treeID
   if item 1 of treeID = "xmlerr" then return treeID -- xmlerr, bad document id
   --
   bodyID_SetDivList treeID, divClassName, iListArray
   put the result into listNode
   --
   put revXMLRootNode (treeID) into rootNode
   switch
      case listNode is empty
         return false
      case pFormat = "lines"
         put revXMLText (treeID, rootNode, false) into bodyHTML
         replace "</li><li>" with ("</li>" & CR & "<li>") in bodyHTML
         break
      case pFormat = "pretty"
         put revXMLText (treeID, rootNode, true) into bodyHTML
         break
      default
         put revXMLText (treeID, rootNode, false) into bodyHTML
   end switch
   return true
end body_SetDivList

command bodyID_SetDivList treeID, divClassName, iListArray
   -- looks for  <div class="tagcloud"><ul><li> node and dletes it
   -- replacing it with "<li><a href="1">one</a></li>" items constructed from array
   
   put revXMLRootNode (treeID) into rootNode
   put revXMLMatchingNode (treeID, rootNode, "div", "class", divClassName, -1) into foundNode
   if foundNode is empty then
      return empty
   end if
   
   put foundNode & "/ul" into listNode
   put listNode & "/li" into firstLineNode
   revXMLDeleteNode treeID, firstLineNode
   --
   repeat with indexNum = 1 to item 2 of the extents of iListArray
      put iListArray [indexNum]["href"] into hrefURL
      put iListArray [indexNum]["someTag"] into someTag
      --
      put merge ("<li><a href='[[hrefURL]]'>[[someTag]]</a></li>") into newXML
      replace "'" with quote in newXML
      --
      revXMLAppend treeID, listNode, newXML
   end repeat
   return listNode
end bodyID_SetDivList

function bodyID_GetListXML treeID, divClassName, pFormat
   put revXMLRootNode (treeID) into rootNode
   put revXMLMatchingNode (treeID, rootNode, "div", "class", divClassName, -1) into foundNode
   put foundNode & "/ul" into listNode
   --
   switch pFormat
      case "lines"
         put revXMLText (treeID, listNode, false) into listXml
         replace "</li><li>" with ("</li>" & CR & "<li>") in listXml
         break
      case "pretty"
         put revXMLText (treeID, listNode, true) into listXml
         break
      default
         put revXMLText (treeID, listNode, false) into listXml
   end switch
   return listXml
end bodyID_GetListXML


--> XHTML
-
function xml_ExtractDiv xHtml, divID, pStartNode
   put revXMLCreateTree (xHtml, true, true, false) into xmlID
   put xml_ExtractDivFromID (xmlID, divID, pStartNode) into someXML
   revXMLDeleteTree xmlID
   return someXML
end xml_ExtractDiv

function xml_ExtractDivFromID xmlID, divID, pStartNode
   if pStartNode is empty then
      -- could use body
      put revXMLRootNode(xmlID) into pStartNode
   end if
   put revXMLMatchingNode (xmlID, pStartNode, "div", "id", divID, -1) into foundNode
   if foundNode is empty then
      put empty into someXML
   else
      put revXMLText (xmlID, foundNode, true) into someXML
   end if
   revXMLDeleteTree xmlID
   return someXML
end xml_ExtractDivFromID

command xhtml_TidyNode @someNode
   replace "'" with quote in someNode
   replace ";" with space in someNode -- revXMLAttributes does not like ";"
end xhtml_TidyNode


--> HTML | Nodes
-
function html_ExtractNode someNode, someHTML
   -- similar as "xml_ExtractNode" (differs in strictness of "revXMLCreateTree") 
   -- could tidy someHTML first
   if someHTML is empty then return empty
   put revXMLCreateTree (someHTML, false, true, false) into treeID
   put revXMLText (treeID, someNode) into nodeXml
   revXMLDeleteTree treeID
   return nodeXml
end html_ExtractNode

function html_ExtractNodeContents someNode, someHTML
   if someHTML is empty then return empty
   put revXMLCreateTree (someHTML, false, true, false) into treeID
   put revXMLNodeContents (treeID, someNode) into innerContent -- this is not what I think of as "contents" :)
   revXMLDeleteTree treeID
   return innerContent
end html_ExtractNodeContents

function html_ExtractChildNodeNames someNode, someHTML
   put revXMLCreateTree (someHTML, false, true, false) into treeID
   put revXMLChildNames (treeID, someNode, CR, empty, true) into tNodeNames
   revXMLDeleteTree treeID
   return tNodeNames
end html_ExtractChildNodeNames

function html_ListNodes someHTML
   put revXMLCreateTree (someHTML, false, true, false) into treeID
   put revXMLRootNode (treeID) into rootNode
   put revXMLTree (treeID, rootNode, CR, space, true, -1) into allNodes
   revXMLDeleteTree treeID
   return allNodes
end html_ListNodes

function html_GetImageArray imgTag
   put revXMLCreateTree (imgTag, false, true, false) into treeID
   put xml_TreeNodeAttributeArray ("img", treeID) into imageArray
   revXMLDeleteTree treeID
   return imageArray
end html_GetImageArray

function html_GetIframeSrc iframeHTML
   put revXMLCreateTree (iframeHTML, false, true, false) into treeID
   put xml_TreeNodeAttributeArray ("iframe", treeID) into iframeArray
   revXMLDeleteTree treeID
   --
   return iframeArray ["src"]
end html_GetIframeSrc

--> Html | Favicon
-
function html_ConstructFaviconLink xHTML, someURL
   -- can be "apple-touch-icon"
   if xHTML is empty then return empty
   put revXMLCreateTree (xHTML, false, true, false) into treeID
   --
   put "html/head/title" into someNode
   put html_ExtractNodeContents (someNode, xHTML) into pageTitle
   put revXMLMatchingNode (treeID, "html/head", "link", "rel", "icon", 1) into someNode
   if someNode is empty then
      revXMLDeleteTree treeID
      return empty
   end if
   put revXMLAttribute (treeID, someNode, "href") into faviconLink
   --
   revXMLDeleteTree treeID
   
   set the itemdelimiter to slash
   if token 1 of faviconLink is among the items of "http/https" then
      put faviconLink into faviconURL
   else
      put item 1 to 3 of someURL & faviconLink into faviconURL
   end if
   get "<img src='[[faviconURL]]' style='vertical-align: middle; width:16px; height:16px' /><a target=_blank style='vertical-align: middle; padding-left: 10px; padding-right: 12px; text-decoration: none;' href='[[someURL]]'>[[pageTitle]]</a>"
   put merge (it) into faviconLink
   return faviconLink
end html_ConstructFaviconLink

function html_ExtractFavicon someHTML
   -- <link rel="icon" href="/resources/images/favicon.png">
   -- <link id='favicon' href='/favicon.png' rel='icon' type='image/png'>
   
   /*
   put merge ("<link\sid='favicon'\s(.*)/>") into someReg
   replace "'" with quote in someReg
   --
   if matchText (someHTML, someReg, metaContent) is true then
      return metaContent
   else
      return "Not found"
   end if
   */
   
   put revXMLCreateTree (someHTML, false, true, false) into treeID
   -- put revXMLMatchingNode (treeID, "/head", "link", "rel", "icon", -1) into someNode -- without htmlTidy
   put revXMLMatchingNode (treeID, "html/head", "link", "rel", "icon", 1) into someNode -- if you use htmlTidy
   put revXMLAttribute (treeID, someNode, "href") into faviconLink
   revXMLDeleteTree treeID
   return faviconLink
end html_ExtractFavicon


--> Html
-
function html_ExtractHeaderDescription headerSection
   put revXMLCreateTree (headerSection, false, true, false) into treeID
   --
   put revXMLMatchingNode (treeID, "head", "meta", "name", "description", -1, false) into dNode
   if dNode is empty then
      put empty into metaDescription
   else
      put word 1 to -1 of revXMLAttribute (treeID, dNode, "content") into metaDescription
   end if
   --
   revXMLDeleteTree treeID
   --
   return metaDescription
end html_ExtractHeaderDescription

function html_ListImageNodes someHTML, pNode
   if someHTML is empty then return empty
   if pNode is empty then put "/" into pNode
   
   put revXMLCreateTree (someHTML, false, true, false) into treeID
   put revXMLChildNames (treeID, pNode, CR, "img", true) into childNodes
   revXMLDeleteTree treeID
   --
   repeat for each line childNode in childNodes
      put pNode & childNode & CR after imageNodes
   end repeat
   delete char -1 of imageNodes
   return imageNodes
end html_ListImageNodes

function html_GetNodeAttributeArray someNode, someHTML
   if someHTML is empty then return empty
   put revXMLCreateTree (someHTML, false, true, false) into treeID
   put revXMLAttributes (treeID, someNode, tab, CR) into attributeTable
   revXMLDeleteTree treeID
   --
   split attributeTable with CR and tab
   return attributeTable
end html_GetNodeAttributeArray

--> HTML | Attributes
-
function html_ExtractAttribute attributeName, someNode, someHTML
   -- similar as "xml_ExtractNode" (differs in strictness of "revXMLCreateTree") 
   -- could tidy someHTML first
   if someHTML is empty then return empty
   put revXMLCreateTree (someHTML, false, true, false) into treeID
   put revXMLAttribute (treeID, someNode, attributeName) into nodeXml
   revXMLDeleteTree treeID
   return nodeXml
end html_ExtractAttribute


--> Deps
-
