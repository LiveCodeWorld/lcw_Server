﻿script "lib_URL"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_URL
type: library
version: 0.3


--> Working on
-


--> Browser
-
function browser_AppPath
   -- answer file "Select application"
   -- put it into appPath
   --
   set the itemdelimiter to slash
   put application_Folder() into appFolder
   --
   put appFolder & "Firefox.app" into appPath
   if there is a folder appPath then
      return appPath
   else
      return empty
   end if
end browser_AppPath

function application_Folder
   set the itemdelimiter to slash
   put the engine folder into appFolder
   put empty into item -3 to -1 of appFolder
   return appFolder
end application_Folder


--> URL
-
function url_AddCorsProxy sURL
   return "https://corsproxy.io/?" & sURL
end url_AddCorsProxy

function is_Url testUrl
   -- quick hack
   set the itemdelimiter to ":"
   put item 1 of testUrl into urlProtocol
   set the itemdelimiter to ","
   if urlProtocol is among the items of "file,http,https,ftp" then
      return true
   else
      return false
   end if
end is_Url

command url_FilterDomains @shortWikiFolders, pFilterDomain, pSimple
   if pFilterDomain is not empty then
      put pFilterDomain is among the lines of shortWikiFolders into addTLD
      
      if pSimple is true then
         filter shortWikiFolders with pFilterDomain
      else
         put "*." & pFilterDomain into sFilter
         filter shortWikiFolders with sFilter
      end if
      
      # Add Root
      set the wholeMatches to true
      if addTLD then
         put pFilterDomain & CR before shortWikiFolders
      end if
   end if
end url_FilterDomains

command url_FilterDomainIndex @domainIndex, topDomain
   if topDomain is empty then return empty
   put "*." & topDomain into someFilter
   set the wholematches to true
   put topDomain is among the lines of domainIndex into topThere
   filter domainIndex with someFilter
   if topThere then
      put topDomain & CR before domainIndex
   end if
   return someFilter
end url_FilterDomainIndex

function url_FilterByItem testItem, sDomains
   set the itemdelimiter to "."
   repeat for each line sDomain in sDomains
      if testItem is among the items of sDomain then
         put sDomain & CR after fDomains
      end if
   end repeat
   delete char -1 of fDomains
   return fDomains
end url_FilterByItem


--> URL | Protocol
-
function url_GetProtocol someUrl
   set the itemdelimiter to ":"
   return item 1 of someUrl
end url_GetProtocol

command url_SetProtocol @someUrl, sProtocol
   set the itemdelimiter to ":"
   put sProtocol into item 1 of someUrl
end url_SetProtocol

function url_StripProtocol someUrl
   set the itemdelimiter to ":"
   delete item 1 of someUrl
   return someUrl
end url_StripProtocol


--> URL | TLD
-
function url_GetTLD someDomain
   -- was "url_GetTopDomain"
   url_DeconstructTopDomain someDomain, topDomainName, subDomainBit
   return topDomainName
end url_GetTLD

command url_MakeTLD @someDomain
   put url_GetTLD (someDomain) into someDomain
end url_MakeTLD

function url_ListTopLevelDomains someDomains
   put url_ConstructTldArray (someDomains) into tldArray
   put keys (tldArray) into toplevelDomains
   url_SortDomainIndex toplevelDomains
   return toplevelDomains
end url_ListTopLevelDomains

function url_ConstructTlDArray someDomains
   repeat for each line someDomain in someDomains
      put url_GetTLD (someDomain) into tldDomain
      put empty into tldArray [tldDomain][wikiDomain]
   end repeat
   return tldArray
end url_ConstructTlDArray

command url_DeconstructTopDomain domainString, @topDomainName, @subDomainBit
   -- a quick hack
   set the itemdelimiter to ":"
   put item 1 of domainString into domainName
   -- put item 2 of domainString into somePort
   
   set the itemdelimiter to "."
   switch
      case item -2 to -1 of domainName = "co.uk"
         put item -3 to -1 of domainName into topDomainName
         put item 1 to -4 of domainName into subDomainBit
         break
      case the number of items of domainName = 2
         put domainName into topDomainName
         put empty into subDomainBit
         break
      default
         put item -2 to -1 of domainName into topDomainName
         put item 1 to -3 of domainName into subDomainBit
   end switch
end url_DeconstructTopDomain

function url_ConstructTopLevelDomainArray domainNames
   /*
   gets a reverse-polish style array of domain names
   items keys with ["domain name"] are the domainname
   remove from lists to get subdomains
   */
   
   set the itemdelimiter to "."
   repeat for each line domainName in domainNames
      set the cursor to busy
      url_DeconstructTopDomain domainName, topDomainName, subDomainBit
      
      -- let's reverse the order
      put 1 into keyNum
      put true into isIpAdress
      repeat with itemNum = the number of items of subDomainBit down to 1
         put item itemNum of subDomainBit into domainBit
         if domainBit is not a number then
            put false into isIpAdress
         end if
         put domainBit into keyArray [keyNum]
         add 1 to keyNum
      end repeat
      
      if isIpAdress is true then
         put empty into domainNameArray [topDomainName]
         next repeat
      end if
      
      if keyArray is an array then
         put domainName into domainNameArray [topDomainName]["subdomain"][keyArray]["domain name"]
      else
         put domainName into domainNameArray [topDomainName]["domain"]["domain name"]
      end if
      delete variable keyArray
   end repeat
   return domainNameArray
end url_ConstructTopLevelDomainArray


--> URL
-
function url_GetDomain someURL
   -- url_Deconstruct wikiURL, someProtocol, wikiDomain, urlPath, shortName, fileExtension, uName, pWord
   set the itemdelimiter to slash
   get item 3 of someURL
   
   # Might be no slash and ?
   set the itemdelimiter to "?"
   put item 1 of it into urlDomain
   
   return urlDomain
end url_GetDomain

function url_Construct sDomain, pPort, pProtocol
   if pProtocol is empty then put "http" into pProtocol
   --
   put pProtocol & "://" & sDomain into sURL
   switch pPort
      case emty
      case 80
         break
      default
         put ":" & pPort after sURL
   end switch
   return sURL
end url_Construct

function url_AddPath someURL, pPath, pShortFile
   text_AddTrailing someURL, "/"
   if pPath is empty then return someURL -- could add index
   
   text_TopAndTail pPath, "/"
   put pPath after someURL
   if pShortFile is empty then return someURL
   
   put pShortFile after someURL
   return someURL
end url_AddPath


--> URL
-
function url_DecodePath routeIndex
   set the itemdelimiter to "/"
   repeat with itemNum = 1 to the number of items of routeIndex
      put item itemNum of routeIndex into someRoute
      put urldecode (someRoute) into item itemNum of somePath
   end repeat
   return somePath
end url_DecodePath

function url_EncodePath somePath
   replace space with "%20" in somePath
   return somePath
   
   set the itemdelimiter to "/"
   repeat with itemNum = 1 to the number of items of somePath
      put  item itemNum of somePath into pathItem
      put urlencode (pathItem) into item itemNum of somePath
   end repeat
   return somePath
end url_EncodePath

function url_ListTopDomains domainNames
   put url_ConstructTopLevelDomainArray (domainNames) into domainNameArray
   put keys (domainNameArray) into topDomainNames
   url_SortDomainIndex topDomainNames
   return topDomainNames
end url_ListTopDomains

function url_FileEnding droppedURL
   set the itemdelimiter to "?"
   get item 1 of droppedURL
   set the itemdelimiter to "."
   put item -1 of it into qEnd
   return qEnd
end url_FileEnding

command url_CheckDomainIndex @domainNames
   -- could have option to test actual domains
   -- quick check to remove pages without "."
   repeat for each line domainName in domainNames
      if domainName contains "." is true then
         put domainName & CR after goodDomains
      end if
   end repeat
   delete char -1 of goodDomains
   put goodDomains into domainNames
   return true
end url_CheckDomainIndex

command url_SortDomainIndex @domainNames
   set the itemdelimiter to "."
   sort domainNames by item -2 of each & item -3 of each & item -4 of each & item -5 of each
   put word 1 to -1 of domainNames into domainNames
   line_DeleteTail domainNames
   return domainNames
end url_SortDomainIndex

function url_ListFilteredDomains domainIndex, topDomains
   repeat for each item topDomain in topDomains
      put domainIndex into domainsToFilter
      url_FilterIndexOnce domainsToFilter, topDomain
      put domainsToFilter & CR after filteredDomains
   end repeat
   delete char -1 of filteredDomains
   return filteredDomains
end url_ListFilteredDomains

command url_FilterIndexOnce @domainIndex, topDomain
   put "*." & topDomain into someFilter
   set the wholematches to true
   put topDomain is among the lines of domainIndex into topThere
   filter domainIndex with someFilter
   --
   -- url_SortDomainIndex domainIndex
   
   -- lets add topDomain back as filter "*." & topDomain will remove it
   switch
      case topThere is false
         return false
      case topThere and (domainIndex is empty)
         put topDomain into domainIndex
         return true
      case topThere is true
         put topDomain & CR before domainIndex
         return true
   end switch
end url_FilterIndexOnce

command url_FilterDomainIndex @domainIndex, topDomain
   url_SortDomainIndex domainIndex
   if topDomain is empty then return empty
   --
   url_FilterIndexOnce domainIndex, topDomain
   return someFilter
end url_FilterDomainIndex


--> From HTML5
-
function url_FileEnding droppedURL
   set the itemdelimiter to "?"
   get item 1 of droppedURL
   set the itemdelimiter to "."
   put item -1 of it into qEnd
   return qEnd
end url_FileEnding

command url_DeconstructTopDomain domainString, @topDomainName, @subDomainBit
   -- a quick hack
   -- could check it is a url first
   
   set the itemdelimiter to ":"
   put item 1 of domainString into domainName
   -- put item 2 of domainString into somePort
   
   set the itemdelimiter to "."
   switch
      case item -2 to -1 of domainName = "co.uk"
         put item -3 to -1 of domainName into topDomainName
         put item 1 to -4 of domainName into subDomainBit
         break
      default
         put item -2 to -1 of domainName into topDomainName
         put item 1 to -3 of domainName into subDomainBit
   end switch
end url_DeconstructTopDomain


--> URL | Top
-
/*
It is very hard to actually extract the "top" conanical domain - the thing you register.
There are complex libraries to this effect
So this is a quick hack
*/

function url_ExtractDomainNames urlIndex
   set the itemdelimiter to slash
   repeat for each line someURL in urlIndex
      put item 3 of someURL & CR after domainNames
   end repeat
   delete char -1 of domainNames
   return domainNames
end url_ExtractDomainNames

function url_ListTopDomains domainNames
   put url_ConstructTopLevelDomainArray (domainNames) into domainNameArray
   put keys (domainNameArray) into topDomainNames
   url_SortDomainIndex topDomainNames
   return topDomainNames
end url_ListTopDomains

function url_ConstructTopLevelDomainArray domainNames
   /*
   gets a reverse-polish style array of domain names
   items keys with ["domain name"] are the domainname
   remove from lists to get subdomains
   */
   
   set the itemdelimiter to "."
   repeat for each line domainName in domainNames
      set the cursor to busy
      url_DeconstructTopDomain domainName, topDomainName, subDomainBit
      
      -- let's reverse the order
      put 1 into keyNum
      put true into isIpAdress
      repeat with itemNum = the number of items of subDomainBit down to 1
         put item itemNum of subDomainBit into domainBit
         if domainBit is not a number then
            put false into isIpAdress
         end if
         put domainBit into keyArray [keyNum]
         add 1 to keyNum
      end repeat
      
      if isIpAdress is true then
         next repeat
      end if
      
      if keyArray is an array then
         put domainName into domainNameArray [topDomainName]["subdomain"][keyArray]["domain name"]
      else
         put domainName into domainNameArray [topDomainName]["domain"]["domain name"]
      end if
      delete variable keyArray
   end repeat
   return domainNameArray
end url_ConstructTopLevelDomainArray

function url_ConstructDomainArray domainNames
   /*
   gets a reverse-polish style array of domain names
   items keys with ["domain name"] are the domainname
   remove from lists to get subdomains
   */
   
   set the itemdelimiter to "."
   repeat for each line domainName in domainNames
      -- let's reverse the order
      put 1 into keyNum
      repeat with itemNum = the number of items of domainName down to 1
         put item itemNum of domainName into domainBit
         put domainBit into keyArray [keyNum]
         add 1 to keyNum
      end repeat
      put domainName into domainNameArray [keyArray]["domain name"]
      delete variable keyArray
   end repeat
   return domainNameArray
end url_ConstructDomainArray


--> URL
-
command url_CheckDomainIndex @domainNames
   -- quick check to remove pages without "."
   repeat for each line domainName in domainNames
      if domainName contains "." is true then
         put domainName & CR after goodDomains
      end if
   end repeat
   delete char -1 of goodDomains
   put goodDomains into domainNames
   --
   url_SortDomainIndex domainNames
   return true
end url_CheckDomainIndex

command url_SortDomainIndex @domainNames
   set the itemdelimiter to "."
   sort domainNames by item -2 of each & item -3 of each & item -4 of each & item -5 of each
   put word 1 to -1 of domainNames into domainNames
   line_DeleteTail domainNames
   return domainNames
end url_SortDomainIndex

function url_ListSubdomains domainName, domainNameIndex
   put url_ConstructTopLevelDomainArray (domainNameIndex) into domainNameArray
   put url_GetSubdomainArray (domainName, domainNameArray) into subDomainArray
   put keys (subDomainArray) into subDomainIndex
   sort subDomainIndex
   return subDomainIndex
end url_ListSubdomains

function url_GetSubdomainArray domainName, domainNameArray
   put domainNameArray [domainName] into subDomainArray
   delete variable subDomainArray ["domain name"]
   return subDomainArray
end url_GetSubdomainArray

function url_GetTLD someDomain
   set the itemdelimiter to "."
   put item -2 to -1 of someDomain into topLevelDomain
   return topLevelDomain
end url_GetTLD

command url_EmptyCache
   repeat for each line someURL in the cachedurls 
      unload url someURL 
   end repeat
end url_EmptyCache

function url_ConstructParamArray someUrl
   set the itemdelimiter to "?"
   put item 1 of someUrl into urlRoot
   put item 2 to -1 of someUrl into postData
   put url_ConstructPostArray (postData) into paramArray
   return paramArray
end url_ConstructParamArray

function url_ConstructPostArray postData
   split postData by "&" and "="
   repeat for each line postKey in the keys of postData
      put postData [postKey] into postValue
      put urldecode(postValue) into paramArray [postKey]
   end repeat
   return paramArray
end url_ConstructPostArray

function url_ExtractFileExtension someUrl
   -- should use regExpression to match only 3 digit extension?
   set the itemdelimiter to "."
   return last item of someUrl
end url_ExtractFileExtension

function url_EncodeUrlPaths someURL
   put "https://vector.im/beta room/#/room/#fedwiki:matrix.org" into someURL
   -- https://vector.im/beta/%23/room/%23fedwiki%3Amatrix.org
   set the itemdelimiter to "/"
   repeat with itemNum = 3 to the number of items of someURL
      put item itemNum of someURL into someItem
      -- replace space with "%20" in someItem
      put urlencode (someItem) into someItem
      replace "+" with "%20" in someItem
      put someItem into item itemNum of someURL
   end repeat
   return someURL
end url_EncodeUrlPaths

command url_Deconstruct someUrl, @someProtocol, @urlDomain, @urlPath, @shortName, @fileExtension, @userName, @pissWord
   set the itemDelimiter to ":"
   put item 1 of someUrl into someProtocol
   if someProtocol is among the items of "file:binFile:ftp:http:https" then
      put someUrl into someFile
      delete item 1 of someFile
      if char 1 to 2 of someFile = "//" then delete char 1 to 2 of someFile
      
      get offset("@", someFile)
      if it = 0 then
         put empty into userName
         put empty into pissWord
      else
         put char 1 to (it - 1) of someFile into authBit
         repeat while char 1 of authBit is "/"
            delete char 1 of authBit
         end repeat
         delete char 1 to it of someFile
         put item 1 of authBit into userName
         put item 2 of authBit into pissWord
      end if
      file_Deconstruct someFile, someRoot, shortName, fileExtension
      
      set the itemDelimiter to "/"
      put item 1 of someRoot into urlDomain
      put item 2 to -1 of someRoot into urlPath
      return true
   else
      put empty into someProtocol
      put empty into urlDomain
      put empty into urlPath
      put empty into shortName
      put empty into fileExtension
      return false
   end if
end url_Deconstruct
