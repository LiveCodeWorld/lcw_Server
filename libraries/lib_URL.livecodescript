script "lib_URL"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_URL
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> URL
-
function url_GetTLD someDomain
   set the itemdelimiter to "."
   put item -2 to -1 of someDomain into topLevelDomain
   return topLevelDomain
end url_GetTLD

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

function url_Construct siteRoot, pPath, pShortFile
   text_AddTrailing siteRoot, "/"
   put siteRoot into someURL
   if pPath is empty then return someURL -- could add index
   
   text_TopAndTail pPath, "/"
   put pPath after someURL
   
   if pShortFile is empty then return someURL
   
   text_AddTrailing someURL, "/"
   put pShortFile after someURL
   return someURL
end url_Construct

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
      case the number of items of domainName = 2
         put domainName into topDomainName
         put empty into subDomainBit
         break
      default
         put item -2 to -1 of domainName into topDomainName
         put item 1 to -3 of domainName into subDomainBit
   end switch
end url_DeconstructTopDomain

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


