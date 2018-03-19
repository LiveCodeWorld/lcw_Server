script "lib_URL"
--> MetaData
-
license: GPLv3
name: lib_URL
type: library
version: 0.1


--> Dig
-
function dig_GetNS someDomain
   -- dig fedwiki.org NS +noall +answer +short
   url_MakeTLD someDomain
   put merge ("dig [[someDomain]] NS +noall +answer +short") into someShell
   put shell (someShell) into nameServers
   return word 1 to -1 of nameServers
end dig_GetNS

function dig_GetIP someDomain
   put merge ("dig [[someDomain]] +short") into someShell
   put shell (someShell) into someIP
   return word 1 to -1 of someIP
end dig_GetIP

function dig_GetDomain someIP
   breakpoint
   -- can't get to work
   
   -- dig redhat.com +short
   url_MakeTLD someDomain
   put merge ("dig -x [[someIP]] +short") into someShell
   put shell (someShell) into someIP
   return word 1 to -1 of someIP
end dig_GetDomain


--> URL | Working on
-
command url_SortDomainIndex @domainNames
   set the itemdelimiter to "."
   -- sort domainNames by item -1 of each & item -2 of each & item -3 of each & item -4 of each
   -- sort domainNames by item -2 of each & item -3 of each & item -4 of each & item -1 of each
   sort domainNames by item -2 of each & item -3 of each & item -4 of each
   return word 1 to -1 of domainNames
   
   /*
   -- not right
   repeat for each line domainName in domainNames
      put the number of items of domainName & comma after maxItemList
   end repeat
   put max (maxItemList) into maxNum
   
   -- sort domainNames by item 1 of each 
   repeat with sortItemNum = 1 to maxNum
      put -1 * sortItemNum into backItemNum
      sort domainNames by item backItemNum of each
   end repeat
   put word 1 to -1 of domainNames into domainNames
   */
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
   
function url_ConstructTopLevelDomainArray domainNames
   /*
   gets a reverse-polish style array of domain names
   items keys with ["domain name"] are the domainname
   remove from lists to get subdomains
   */
   
   set the itemdelimiter to "."
   repeat for each line domainName in domainNames
      put item -2 to -1 of domainName into tldName
      
      -- let's reverse the order
      put item 1 to -3 of domainName into subDomainBit
      put 1 into keyNum
      repeat with itemNum = the number of items of subDomainBit down to 1
         put item itemNum of subDomainBit into domainBit
         put domainBit into keyArray [keyNum]
         add 1 to keyNum
      end repeat
      if keyArray is an array then
         put domainName into domainNameArray [tldName][keyArray]["domain name"]
      else
         put domainName into domainNameArray [tldName]["domain name"]
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

command url_MakeTLD @someDomain
   put url_GetTLD (someDomain) into someDomain
end url_MakeTLD

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

function url_Construct someProtocol, urlDomain, urlPath, shortName, fileExtension, userName, pissWord
    put someProtocol & "://" into someUrl
    if userName is not empty then
        put userName & ":" & pissWord & "@" after someUrl
    end if
    put urlDomain after someUrl
    if urlPath is not empty then
        folder_Format someUrl
        if char 1 of urlPath is "/" then delete char 1 of urlPath
        put urlPath after someUrl
    end if
    if shortName is empty then
        -- put "/" after someUrl -- not always a directory can be a web application path / wiki
    else
        folder_Format someUrl
        put shortName after someUrl
         
        if fileExtension is not empty then
            put "." & fileExtension after someUrl
        end if
    end if
    return someUrl
end url_Construct

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

function url_StripProtocol someUrl
    set the itemdelimiter to ":"
    delete item 1 of someUrl
    return someUrl
end url_StripProtocol
 
function url_ConstructBaseUrl baseUrl
    -- was "object_BaseUrlGuess"
    -- create a folder if it does not exist!
    switch baseUrl
    case "local"
        put folder_Above(the filename of this stack) into baseFolder
        put "wiki/" after baseFolder
        if there is not a folder baseFolder then
            folder_CreateNested baseFolder
        end if
        put "file:" & baseFolder into baseUrl
        return baseUrl
    case empty
        put the short name of this card into wikiTitle
        if word 1 to 2 of wikiTitle is "card id" then
            put the short name of this stack into wikiTitle
        end if
        put wiki_GetFolder(wikiTitle) into baseFolder
        put "file:" & baseFolder into baseUrl
        return baseUrl
    default -- leave as is
        return baseUrl
    end switch
end url_ConstructBaseUrl

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

function url_EncodePath somePath
    set the itemdelimiter to "/"
    repeat for each item someItem in somePath
        replace space with "%20" in someItem
        -- put urlencode(someItem) into someItem
        put someItem & "/" after encodedPath
    end repeat
    delete char -1 of encodedPath
    return encodedPath
end url_EncodePath

on url_Deconstruct someUrl, @someProtocol, @urlDomain, @urlPath, @shortName, @fileExtension, @userName, @pissWord
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

function url_Construct someProtocol, urlDomain, urlPath, shortName, fileExtension, userName, pissWord
    put someProtocol & "://" into someUrl
    if userName is not empty then
        put userName & ":" & pissWord & "@" after someUrl
    end if
    put urlDomain after someUrl
    if urlPath is not empty then
        folder_Format someUrl
        if char 1 of urlPath is "/" then delete char 1 of urlPath
        put urlPath after someUrl
    end if
    if shortName is empty then
        -- put "/" after someUrl -- not always a directory can be a web application path / wiki
    else
        folder_Format someUrl
        put shortName after someUrl
         
        if fileExtension is not empty then
            put "." & fileExtension after someUrl
        end if
    end if
    return someUrl
end url_Construct

function url_ExtractFileExtension someUrl
    -- should use regExpression to match only 3 digit extension?
    set the itemdelimiter to "."
    return last item of someUrl
end url_ExtractFileExtension

function url_StripProtocol someUrl
    set the itemDelimiter to ":"
    delete item 1 of someUrl
    return someUrl
end url_StripProtocol
 
function url_ConstructBaseUrl baseUrl
    -- was "object_BaseUrlGuess"
    -- create a folder if it does not exist!
    switch baseUrl
    case "local"
        put folder_AboveFile(the fileName of this stack) into baseFolder
        put "wiki/" after baseFolder
        if there is not a folder baseFolder then
            folder_CreateNested baseFolder
        end if
        put "file:" & baseFolder into baseUrl
        return baseUrl
    case empty
        put the short name of this card into wikiTitle
        if word 1 to 2 of wikiTitle is "card id" then
            put the short name of this stack into wikiTitle
        end if
        put wiki_GetFolder(wikiTitle) into baseFolder
        put "file:" & baseFolder into baseUrl
        return baseUrl
    default -- leave as is
        return baseUrl
    end switch
end url_ConstructBaseUrl

