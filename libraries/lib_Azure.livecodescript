script "lib_Azure"
--> MetaData
-
license: GPLv3
name: lib_Azure
type: library
version: 0.1

/*
The "Text Analytics API" from Microsof's Azure service offering has a free tier offereing 5,000 free transactions per month.

- https://northeurope.dev.cognitive.microsoft.com/docs/services/TextAnalytics-V2-1-Preview/operations/5ac4251d5b4ccd1554da7634/console
- https://azure.microsoft.com/en-gb/pricing/details/cognitive-services/text-analytics/
*/


--> Fedwiki | Azure
-
function fedwiki_FetchAzureRelated wikiDomain, pSlug
   if pSlug is empty then
      put azure_FetchAndConvertSitemap (wikiDomain, "combine") into docArray
   else
      put azure_FetchAndConvertPageArray (wikiDomain, pSlug) into docArray
   end if
   put azure_FetchRelated (docArray) into resultArray
   put azure_ExtractUniqueEntities (resultArray) into wikipediaTitles
   return wikipediaTitles
end fedwiki_FetchAzureRelated

function fedwiki_FetchAzureKeyPhrases wikiDomain
   put azure_FetchAndConvertSitemap (wikiDomain, "combine") into docArray
   put azure_FetchKeyPhraseArray (docArray) into resultArray
   return resultArray
end fedwiki_FetchAzureKeyPhrases

command fedwiki_DeconstructSitemapArray itemArray, @pageTitle, @firstPara, @pageSlug, @mDate
   put itemArray ["title"] into pageTitle
   put itemArray ["synopsis"] into firstPara
   put itemArray ["slug"] into pageSlug
   put itemArray ["date"] into mDate
end fedwiki_DeconstructSitemapArray


--> Azure
-
function azure_FetchAndConvertPageArray wikiDomain, pSlug
   local docArray
   put pageArray_Fetch (wikiDomain, pSlug) into pageArray
   put pageArray ["story"] into storyArray
   repeat for each key itemNum in storyArray
      put storyArray [itemNum]["text"] into itemText
      azure_AddTextToDocArray docArray, itemText
   end repeat
   return docArray
end azure_FetchAndConvertPageArray

function azure_ExtractUniqueEntities resultArray
   put resultArray ["documents"] into docResultArray
   put item 1 of the extents of docResultArray into maxNum
   repeat for each key itemNum in docResultArray
      put docResultArray [itemNum]["id"] into docID
      put docResultArray [itemNum]["entities"] into entityArray
      repeat for each key entityNum in entityArray
         put entityArray [entityNum]["wikipediaURL"] into wikipediaURL
         put entityArray [entityNum]["wikipediaID"] into wikipediaTitle
         put entityArray [entityNum]["name"] into someName
         put entityArray [entityNum]["matches"] into matchArray
         put entityArray [entityNum]["type"] into entityType
         --
         if wikipediaTitle is empty then
            switch entityType
               case "Person"
               case "DateTime"
               case "Organization"
               case "Location"
                  put entityType & ":" && someName into uniqueTitleArray [wikipediaTitle]
                  break
               case "URL"
               case "Quantity"
                  next repeat
                  break
               default -- ""
                  breakpoint
            end switch
         else
            put entityArray into uniqueTitleArray [wikipediaTitle]
         end if
      end repeat
   end repeat
   put keys (uniqueTitleArray) into wikipediaTitles
   replace CR with (comma & space) in wikipediaTitles
   --
   return wikipediaTitles
end azure_ExtractUniqueEntities

function azure_FetchAndConvertSitemap wikiDomain, pHow
   local docArray
   put fedwiki_FetchSitemapArray (wikiDomain) into sitemapArray
   if sitemapArray is empty then return empty
   --
   repeat for each key indexNum in sitemapArray
      put sitemapArray [indexNum] into itemArray
      fedwiki_DeconstructSitemapArray itemArray, pageTitle, firstPara, pageSlug, mDate
      switch pHow
         case "combine"
            put pageTitle & CR & firstPara & CR into nextText
            if the number of chars of oneBigText + the number of chars of nextText > 5119 then
               azure_AddTextToDocArray docArray, oneBigText
               put nextText into oneBigText 
            else
               put nextText after oneBigText
            end if
            break
         default
            put pageTitle & CR & firstPara into someText
            azure_AddTextToDocArray docArray, someText
      end switch
   end repeat
   --
   switch pHow
      case "combine"
         azure_AddTextToDocArray docArray, oneBigText
         return docArray
      default
         return docArray
   end switch
end azure_FetchAndConvertSitemap

function azure_ConstructDocJson someText
   local docArray
   if someText is empty then
      azure_AddTextToDocArray docArray, "Microsoft released Windows 10"
      azure_AddTextToDocArray docArray, "In 1975, Bill Gates III and Paul Allen founded the company."
   else
      azure_AddTextToDocArray docArray, someText
   end if
   put json_FromArray (docArray) into someJSON
   return someJSON
end azure_ConstructDocJson

command azure_AddTextToDocArray @docArray, someText, pLang, pID
   if pLang is empty then put "en" into pLang
   put docArray ["documents"] into dArray
   put item 2 of the extents of dArray + 1 into indexNum
   if pID is empty then   
      -- could use item-id
      put indexNum into pID
   end if
   --
   put pID into docArray ["documents"][indexNum]["id"]
   put pLang into docArray ["documents"][indexNum]["language"]
   put someText into docArray ["documents"][indexNum]["text"]
end azure_AddTextToDocArray

function azure_FetchKeyPhraseArray docArray
   put "https://northeurope.api.cognitive.microsoft.com/text/analytics/v2.1-preview/keyPhrases" into restURL
   put azure_FetchArray (docArray, restURL) into resultArray
   return resultArray
end azure_FetchKeyPhraseArray

function azure_FetchRelated docArray
   put json_FromArray (docArray) into someJSON
   put azure_FetchRelatedJson (someJSON) into jsonResult
   put json_ToArray (jsonResult) into resultArray
   return resultArray
end azure_FetchRelated

function azure_FetchRelatedJson someJSON
   -- Text Analytics: 5,000 free transactions per month
   put azure_GetApiKey() into apiKey
   put "https://northeurope.api.cognitive.microsoft.com/text/analytics/v2.1-preview/entities" into restURL
   put "Ocp-Apim-Subscription-Key" into headerKey
   put headerKey & ":" && apiKey into extraHeaders
   put jsonrpc_POST (someJSON, restUrl, empty, empty, extraHeaders) into jsonResult
   return jsonResult
end azure_FetchRelatedJson

function azure_FetchArray docArray, restURL
   put azure_GetApiKey() into apiKey
   put "Ocp-Apim-Subscription-Key" into headerKey
   put headerKey & ":" && apiKey into extraHeaders
   --
   put json_FromArray (docArray) into someJSON
   put jsonrpc_POST (someJSON, restUrl, empty, empty, extraHeaders) into jsonResult
   --
   if jsonResult is empty then return empty
   put json_ToArray (jsonResult) into resultArray
   if jsonResult is false then
      return empty
   else
      return resultArray
   end if
end azure_FetchArray

function azure_GetApiKey
   put secret_Get ("Azure") into apiKey
   return apiKey
end azure_GetApiKey

command azure_SetApiKey apiKey
   secret_Set "Azure", apiKey
   return the result
end azure_SetApiKey
