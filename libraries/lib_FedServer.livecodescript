script "lib_FedServer"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_FedServer
type: library
version: 0.1

/*Some help*/


--> Display | Fedserver
-
command display_AtopiaSeverFedray
   put fedserver_FetchFedray ("Atopia") into serverFedray
   display_Data serverFedray, "New Atopia fedray"
end display_AtopiaSeverFedray


--> Working on
-

--> Fedserver | Model | Build | Page
-
command federation_UpdateServerPage serverName, federationServerModel
   federation_UpdateServerModel federationServerModel, serverName
   put the result into summaryText
   --
   put _ConstructServerCurlyData (serverName, federationServerModel, summaryText) into curlyData
   put "sites.fedwiki.club,roster.fedwiki.club,author.fedwiki.club" into forkDomains
   put serverName && "Server" into pageTitle
   federation_UpdateTemplate pageTitle, "server.fedwiki.club", curlyData, forkDomains
   put the result into pageArray
   --
   put federationServerModel [serverName] into fedserverModel
   fedserver_StoreModel serverName, fedserverModel
   --
   return pageArray
end federation_UpdateServerPage


--> Fedserver
-
function fedserver_GetAuthorNames serverName, serverModel
   put serverModel [serverName]["domains"] into domainArray
   repeat for each key domainName in domainArray
      put domainArray [domainName]["owner"] into ownerName
      put empty into authorArray [ownerName]
   end repeat
   put keys (authorArray) into authorNames
   sort authorNames by word -1 of each
   return word 1 to -1 of authorNames
end fedserver_GetAuthorNames


--> Private
-
private function _ConstructServerCurlyData serverName, serverModel, summaryText
   _DeconstructModel serverModel, serverName, serverDomains, domainNum, serverPageNum, createdDate, ipAddress
   put the result into rosterText
   put fedserver_GetAuthorNames (serverName, serverModel) into authorNames
   --
   put serverName into curlyData ["all"]["serverName"]
   put _ServerMeta (domainNum, serverPageNum, ipAddress, createdDate) into curlyData ["id"]["da8cf69872f38050"] -- meta
   put rosterText into curlyData ["id"]["741a0fcdd3ff76b2"] -- roster
   put markdown_LinkedBullets (serverDomains) into curlyData ["id"]["0458144c09a51968"] -- index
   put markdown_LinkedBullets (authorNames) into curlyData ["id"]["3b90e7841cc695fa"] -- authors
   --
   return curlyData
end _ConstructServerCurlyData

private command _DeconstructModel serverModel, serverName, @serverDomains, @domainNum, @serverPageNum, @createdDate, @ipAddress
   put serverModel [serverName] into serverDomainArray
   --
   put serverDomainArray ["ipAddress"] into ipAddress
   put serverDomainArray ["domains"] into domainArray
   put serverDomainArray ["domainNum"] into domainNum
   put serverDomainArray ["pageNum"] into serverPageNum
   put serverDomainArray ["created"] into createdDate
   put keys (domainArray) into serverDomains
   url_SortDomainIndex serverDomains
   put serverName && "sites" & CR & CR & serverDomains into rosterText
   return rosterText
end _DeconstructModel

private function _ServerMeta domainNum, pageNum, ipAddress, pCreatedDate
   if pCreatedDate is empty then put "not known" into pCreatedDate
   put "Domains:" && domainNum into serverMeta
   put CR & "Pages:" && pageNum after serverMeta
   put CR & "Created:" && pCreatedDate after serverMeta
   put CR & "IP Address:" && ipAddress after serverMeta
   put CR & "Updated:" && the internet date after serverMeta
   return serverMeta
end _ServerMeta
