script "model_AtopiaFiles"
--> MetaData
-
license: GPLv3
name: model_AtopiaFiles
type: model
version: 0.2

/*
This model provides access to files and folders on the Atopia server on DigitalOcean.
As this server is a Fedwiki Farm, most of these files are page-json files for wiki.
*/


--> Atopia | Shell
-
function atopia_FetchWikiJson pageSlug, fedwikiDomain, pUseSSH
   if pUseSSH is true then
      put fedwiki_ConstructPath (fedwikiDomain, pageSlug) into wikiPagePath
      put atopia_FetchData (wikiPagePath) into someJSON
   else
      put fedwiki_FetchPageJson (fedwikiDomain, pageSlug) into someURL
   end if
   return someJSON
end atopia_FetchWikiJson

command atopia_StoreWikiPageArray fedwikiDomain, pageSlug, pageArray
   put json_FromArray (pageArray) into pageJSON
   atopia_StoreWikiJson fedwikiDomain, pageSlug, pageJSON
   put the result into shellResult
   return shellResult -- should be empty unless an error
end atopia_StoreWikiPageArray

command atopia_StoreWikiJson fedwikiDomain, pageSlug, pageJSON
   put fedwiki_ConstructPath (fedwikiDomain, pageSlug) into wikiPagePath
   --
   atopia_StoreData wikiPagePath, pageJSON
   put the result into shellResult
   if shellResult is not empty then return shellResult
   
   -- now should update the sitemap
   atopia_DeleteWikiSitemap fedwikiDomain
   return shellResult -- should be empty unless an error
end atopia_StoreWikiJson

command atopia_DeleteWikiJSON fedwikiDomain, pageSlug
   put fedwiki_ConstructPath (fedwikiDomain, pageSlug) into wikiPagePath
   --
   atopia_DeleteFile wikiPagePath
   --
   put the result into shellResult
   return shellResult
end atopia_DeleteWikiJSON

command atopia_DeleteWikiSitemap fedwikiDomain
   put fedwiki_ConstructSitemapPath (fedwikiDomain) into sitemapPath
   --
   atopia_DeleteFile sitemapPath
   --
   put the result into shellResult
   return shellResult
end atopia_DeleteWikiSitemap


--> Atopia | Model | Files and Folders
-
function atopia_WikiStatusFolder wikiDomain
   -- absolute path for safety
   put wikiDomain & "/status/" into relFolder
   return atopia_WikiFolder (relFolder)
end atopia_WikiStatusFolder

function atopia_WikiPageFolder wikiDomain
   -- absolute path for safety
   put wikiDomain & "/pages/" into relFolder
   return atopia_WikiFolder (relFolder)
end atopia_WikiPageFolder

function atopia_WikiDomainFolder wikiDomain
   -- absolute path for safety
   put atopia_WikiFolder (wikiDomain) into domainFolder
   put slash after domainFolder
   return domainFolder
end atopia_WikiDomainFolder

function atopia_UnhostedFolder
   return atopia_WikiFolder ("_unhosted_sites/")
end atopia_UnhostedFolder

function atopia_FolderInTrashFolder wikiDomain
   -- hard wired absolute path for safety
   put atopia_TrashFolder() & wikiDomain & slash into folderInTrashFolder
   return folderInTrashFolder
end atopia_FolderInTrashFolder

function atopia_TrashFolder
   -- hard wired absolute path for safety
   return atopia_WikiFolder ("_trash/")
end atopia_TrashFolder

function atopia_WikiFolder pRelativePath
   -- absolute path for safety
   put atopia_WikiRootFolder() into wikiRootFolder
   put pRelativePath after wikiRootFolder
   return wikiRootFolder
end atopia_WikiFolder

function atopia_WikiRootFolder
   -- absolute path for safety
   put "/root/.wiki/" into wikiRootFolder
   return wikiRootFolder
end atopia_WikiRootFolder
