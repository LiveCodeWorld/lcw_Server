script "lib_Azure"
--> MetaData
-
license: GPLv3
name: lib_Azure
type: library
version: 0.1

/*
The "Text Analytics API" from Microsof's Azure service offering has a free tier offereing 5,000 free transactions per month.

- https://docs.microsoft.com/en-gb/azure/cognitive-services/text-analytics/overview
- https://northeurope.dev.cognitive.microsoft.com/docs/services/TextAnalytics-V2-1-Preview/operations/5ac4251d5b4ccd1554da7634/console
- https://azure.microsoft.com/en-gb/pricing/details/cognitive-services/text-analytics/
- https://fedwiki.cognitiveservices.azure.com/

- https://uksouth.dev.cognitive.microsoft.com/docs/services/TextAnalytics-v2-1/operations/56f30ceeeda5650db055a3c6/console

POST https://uksouth.api.cognitive.microsoft.com/text/analytics/v2.1/keyPhrases?showStats=In 1975, Bill Gates III and Paul Allen founded the company. HTTP/1.1
Host: uksouth.api.cognitive.microsoft.com
Content-Type: application/json
Ocp-Apim-Subscription-Key: ••••••••••••••••••••••••••••••••


https://uksouth.api.cognitive.microsoft.com/text/analytics/v2.1/keyPhrases?showStats=In 1975, Bill Gates III and Paul Allen founded the company.

RESPONSE
Transfer-Encoding: chunked
csp-billing-usage: CognitiveServices.TextAnalytics.BatchScoring=3
x-envoy-upstream-service-time: 24
apim-request-id: 145b1184-300b-4b14-84c5-7e5728f775c0
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
x-content-type-options: nosniff
Date: Wed, 02 Sep 2020 08:08:54 GMT
Content-Type: application/json; charset=utf-8

Resource endpoints are as follows (your region may vary):

https://westus.api.cognitive.microsoft.com/text/analytics/v2.1/sentiment
https://westus.api.cognitive.microsoft.com/text/analytics/v2.1/keyPhrases
https://westus.api.cognitive.microsoft.com/text/analytics/v2.1/languages
https://westus.api.cognitive.microsoft.com/text/analytics/v2.1/entities
Set the three request headers:

Ocp-Apim-Subscription-Key: your access key, obtained from Azure portal.
Content-Type: application/json.
Accept: application/json.

See also "lib_Gephi"
*/


--> Variables
-
constant AzureRestUrl = "https://fedwiki.cognitiveservices.azure.com/"
constant AzureLocation = "uksouth"
local AzureApiVersion = "v3.0" -- "v2.1"


--> Working on
-

--> Display | Azure
-
command Azure_Test
   put "daisy.world" into wikiDomain
   --
   put azure_FetchAndConvertSitemap (wikiDomain, "combine") into docArray
   --
   display_Data docArray
end Azure_Test

command launch_AzureDocs
   launch url "https://azure.microsoft.com/en-gb/pricing/details/cognitive-services/text-analytics/"
end launch_AzureDocs

command display_AzureEntities wikiDomain, pDisplayView
   local someText
   if wikiDomain is empty then return empty
   --
   put azure_FetchAndConvertSitemap (wikiDomain, "combine") into docArray
   if docArray is empty then
      lcw_AnswerWarning merge ("Could not fetch sitemap for domain '[[wikiDomain]]'!"), pDisplayView
      return empty
   end if
   --
   put azure_FetchEntities (docArray) into resultArray
   if the keys of resultArray contains "error" then
      display_Data resultArray, "Error"
      exit to top
   end if
   --
   put azure_ExtractUniqueEntities (resultArray) into wikipediaTitles
   --
   display_Array resultArray, wikiDomain, "Azure Entities"
   put the result into displayView
   display_SetInteractions displayView, "Azure | Tree", ""
   return displayView
end display_AzureEntities

command display_AzurePhrases wikiDomain
   local someText
   if wikiDomain is empty then return empty
   put wikiDomain & ",Azure Phrases" into someTitle
   --
   put azure_FetchWikiKeyPhrases (wikiDomain) into resultArray
   display_Array resultArray, wikiDomain, "Global | Azure | Tree | Menu"
   put the result into displayView
   display_SetInteractions displayView, "Azure | Tree", ""
   return displayView
end display_AzurePhrases

function azure_FetchWikipediaTitles pageText
   local docArray
   azure_AddTextToDocArray docArray, pageText
   put azure_FetchEntities (docArray) into resultArray
   put azure_ExtractUniqueEntities (resultArray) into wikipediaTitles
   return wikipediaTitles
end azure_FetchWikipediaTitles


--> Azure | Entities
-
function azure_FetchPageRelated wikiDomain, pSlug
   if pSlug is empty then
      put azure_FetchAndConvertSitemap (wikiDomain, "combine") into docArray
   else
      put azure_FetchAndConvertPageArray (wikiDomain, pSlug) into docArray
   end if
   put azure_FetchEntities (docArray) into resultArray
   put azure_ExtractUniqueEntities (resultArray) into wikipediaTitles
   return wikipediaTitles
end azure_FetchPageRelated

function azure_ExtractUniqueEntities resultArray
   put azure_ConstructEntityConceptArray (resultArray) into conceptArray
   put keys (conceptArray) into wikipediaTitles
   replace CR with (comma & space) in wikipediaTitles
   --
   return wikipediaTitles
end azure_ExtractUniqueEntities

function azure_ConstructEntityConceptArray resultArray
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
                  put entityType & ":" && someName into conceptArray [wikipediaTitle]
                  break
               case "URL"
               case "Quantity"
                  next repeat
                  break
               default -- ""
                  breakpoint
            end switch
         else
            put entityArray into conceptArray [wikipediaTitle]
         end if
      end repeat
   end repeat
   return conceptArray
end azure_ConstructEntityConceptArray


--> Azure | Entities
-
/*
Not available anuy more ?
*/

function azure_FetchPageEntityArray wikiDomain, pSlug, pApiVersion
   local docArray
   put pageArray_Fetch (wikiDomain, pSlug) into pageArray
   put pageArray_ConstructText (pageArray) into pageText
   azure_AddTextToDocArray docArray, pageText
   --
   put azure_FetchEntities (docArray, pApiVersion) into responseArray
   --
   return responseArray
end azure_FetchPageEntityArray

function azure_FetchEntities docArray, pApiVersion
   if pApiVersion is empty then
      put azure_ConstructRestUrl ("entities/recognition/general") into restURL
   else
      put azure_ConstructRestUrl ("entities", pApiVersion) into restURL -- v2.1
   end if
   put azure_FetchArray (docArray, restURL) into resultArray
   return resultArray
end azure_FetchEntities


--> Azure | KeyPhrase
-
function azure_FetchWikiKeyPhrases wikiDomain
   put azure_FetchAndConvertSitemap (wikiDomain, "combine") into docArray
   put azure_FetchKeyPhraseArray (docArray) into resultArray
   return resultArray
end azure_FetchWikiKeyPhrases

function azure_FetchPageKeyArray wikiDomain, pSlug
   local docArray
   
   put pageArray_FetchText (wikiDomain, pSlug) into pageText
   azure_AddTextToDocArray docArray, pageText
   --
   put azure_FetchKeyPhraseArray (docArray) into responseArray
   --
   return responseArray
end azure_FetchPageKeyArray

function azure_FetchKeyPhraseArray docArray
   put azure_ConstructRestUrl ("keyPhrases") into restURL
   put azure_FetchArray (docArray, restURL) into resultArray
   return resultArray
end azure_FetchKeyPhraseArray


--> Azure | DocArray | Private
-
function azure_FetchAndConvertPageArray wikiDomain, pSlug
   put pageArray_Fetch (wikiDomain, pSlug) into pageArray
   put azure_ConstructDocArray (pageArray) into docArray
   return docArray
end azure_FetchAndConvertPageArray

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

function azure_ConstructDocArray pageArray
   local docArray
   
   put pageArray ["story"] into storyArray
   put item 2 of the extents of storyArray into maxItem
   repeat with itemNum = 1 to maxItem
      put storyArray [itemNum]["text"] into itemText
      azure_AddTextToDocArray docArray, itemText
   end repeat
   return docArray
end azure_ConstructDocArray

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


--> Azure | Private
-
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


--> Azure | Rest
-
function azure_ConstructRestUrl restVerb, pApiVersion
   -- put "https://northeurope.api.cognitive.microsoft.com/text/analytics/v2.1-preview/keyPhrases" into restURL
   if pApiVersion is empty then put AzureApiVersion into pApiVersion
   --
   put merge ("https://[[AzureLocation]].api.cognitive.microsoft.com/") into restURL
   put "text/analytics/" after restURL
   put pApiVersion & "/" after restURL
   --
   put restVerb after restURL
   return restURL   
end azure_ConstructRestUrl

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


--> Deps
-
-- function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get

command fedwiki_DeconstructSitemapArray itemArray, @pageTitle, @firstPara, @pageSlug, @mDate
   put itemArray ["title"] into pageTitle
   put itemArray ["synopsis"] into firstPara
   put itemArray ["slug"] into pageSlug
   put itemArray ["date"] into mDate
end fedwiki_DeconstructSitemapArray

command pageArray_CleanText @itemText
   replace "[[" with empty in itemText
   replace "]]" with empty in itemText
   --
   replace "# " with empty in itemText
   --
   put replaceText (itemText, "\[.*\]", empty) into itemText
end pageArray_CleanText
