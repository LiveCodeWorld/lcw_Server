script "lib_MonkeyLearn"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_MonkeyLearn
type: library
version: 0.1


--> Working on
-


--> MonkeyLearn (No longer available)
-
command launch_MonkeyDocs
   launch url "https://monkeylearn.com/api/v3/#train-extractor"
end launch_MonkeyDocs

command monkey_ListExtractors
   /*
   curl -H "Authorization:Token [YOUR_API_KEY]" \
         -H "Content-Type: application/json" \
         -i \
         "https://api.monkeylearn.com/v3/extractors/"
   */
   
   -- put "https://api.monkeylearn.com/v3/extractors/" into restURL
   put monkey_ConstructRestUrl (extractors) into restURL
   put monkey_GetArray (restURL) into rArray
   --
   display_Data rArray, "monkey_ListExtractors()"
end monkey_ListExtractors

function monkey_ExtractKeyWords someText
   put monkey_FetchKeywordData (someText) into rArray
   --
   put rArray [1]["text"] into rText
   put rArray [1][extractions] into extractionArray
   repeat with itemNum = 1 to item 2 of the extents of extractionArray
      put extractionArray [itemNum] into itemArray
      put itemArray ["tag_name"] into tagName
      switch tagName
         case "KEYWORD"
         default
            put itemArray ["parsed_value"] into kWord
            put itemArray into keywordArray [kWord]
      end switch
   end repeat
   put the keys of keywordArray into kWords
   return kWords
end monkey_ExtractKeyWords

function monkey_FetchKeywordData someText
   /*
   curl --data '{"data": ["Elon Musk has shared a photo of the spacesuit designed by SpaceX. This is the second image shared of the new design and the first to feature the spacesuit’s full-body look."]}' \
   -H "Authorization:Token b427331f7ccf3378b5bf8bbef7e31fb8f19d5830" \
         -H "Content-Type: application/json" \
         -D - \
         "https://api.monkeylearn.com/v3/extractors/ex_YCya9nrn/extract/"
   */
   -- put "Elon Musk has shared a photo of the spacesuit designed by SpaceX. This is the second image shared of the new design and the first to feature the spacesuit’s full-body look." into someText
   -- put "Elon Musk has shared a photo of the spacesuit designed by SpaceX." into someText
   put "https://api.monkeylearn.com/v3/extractors/ex_YCya9nrn/extract/" into restURL
   --
   put monkey_ConstructDataArray (someText) into dataArray
   put monkey_PostArray (restURL, dataArray) into rArray
   --
   -- display_Data rArray, "monkey_FetchKeywordData()"
   return rArray
end monkey_FetchKeywordData

function monkey_ConstructDataArray someText
   put someText into dataArray ["data"][1]
   return dataArray
end monkey_ConstructDataArray

function monkey_PostArray restURL, dataArray
   put json_FromArray (dataArray) into pJSON
   --
   monkey_SetHeaders
   post pJSON to url restURL
   put it into rJSON
   --
   put json_ToArray (rJSON) into rArray
   return rArray
end monkey_PostArray

function monkey_GetArray restURL
   -- see also "jsonrpc_GetArray"
   monkey_SetHeaders
   --
   put url restURL into rJSON
   --
   put json_ToArray (rJSON) into rArray
   return rArray
end monkey_GetArray

command monkey_SetHeaders
   put monkey_GetApiKey() into apiKey
   --
   put "Content-type: application/json" into someHeader
   put CR & "Accept: application/json" after someHeader
   put CR & "Accept-Charset: utf-8" after someHeader
   put CR & "Authorization: Token" && apiKey after someHeader
   --
   set the httpHeaders to someHeader
end monkey_SetHeaders

function monkey_GetApiKey
   put secret_Get ("monkeyApiKey") into apiKey
   return apiKey
end monkey_GetApiKey

command monkey_SetApiKey apiKey
   secret_Set "monkeyApiKey", apiKey
end monkey_SetApiKey

function monkey_ConstructRestUrl restVerb
   put "https://api.monkeylearn.com/v3/" into restURL
   put restVerb after restURL
   return restURL
end monkey_ConstructRestUrl


--> Deps
-
