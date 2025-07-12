script "lib_KeyWord"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_KeyWord
type: library
version: 0.1


--> Working on
-
function wikiPage_KeywordSection wikiDomain, pSlug, pModel, pProtocol, pPort
   # Fetch Wiki page text
   put wikiPage_FetchText (wikiDomain, pSlug, pPort, pProtocol) into sText
   put keyword_ConstructLinkSection (sText, pModel, pProtocol, pPort) into kWordSection
   return kWordSection
end wikiPage_KeywordSection

function wikiPage_Keywords wikiDomain, pSlug, pModel, pProtocol, pPort
   /* -- for getting text from local files
   put prompt_Get ("extract-keywords") into sPrompt
   put wikiPage_GetText (wikiDomain, pSlug) into userText
   */
   
   # Fetch Wiki page text
   put wikiPage_FetchText (wikiDomain, pSlug, pPort, pProtocol) into sText
   put keyword_ProcessText (sText, pModel, pProtocol, pPort) into kWords
   return kWords
end wikiPage_Keywords


--> Keyword
-
function keyword_ConstructLinkSection sText, pModel, pProtocol, pPort
   -- put monkey_ExtractKeyWords (sText) into kWords
   put keyword_ProcessText (sText, pModel, pProtocol, pPort) into kWords
   put markdown_KeyWordLinkSection (kWords) into keyWordSection
   return keyWordSection
end keyword_ConstructLinkSection

function keyword_ProcessText sText, pModel, pProtocol, pPort
   # Fetch Prompt
   put prompt_Fetch ("extract-keywords", pProtocol, pPort) into sPrompt
   
   # Get ChatGPT reply
   put openAI_FetchChatData (sText, sPrompt, pModel) into rData
   if rData is not an array then
      return empty
   else
      put rData ["choices"][1]["message"]["content"] into sText
      return sText
   end if
end keyword_ProcessText

command pageArray_AddKeyWordSection @pageArray, someText
   put keyword_ConstructLinkSection (someText) into kwordSection
   if kwordSection is empty then return empty
   --
   pageArray_AddMarkdown pageArray, "# Keywords"
   pageArray_AddMarkdown pageArray, kwordSection
   --
   return kwordSection
end pageArray_AddKeyWordSection


--> KeyWord
-


--> Deps
-
