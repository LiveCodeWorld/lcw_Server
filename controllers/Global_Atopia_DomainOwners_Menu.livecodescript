script "Global_Atopia_DomainOwners_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_DomainOwners_Menu
type: controller
version: 0.1


--> Global | Atopia | DomainOwners | Menu
-
on menu_TestDomainOwners
   put atopia_GetOwnershipArray() into ownershipArray
   set the cursor to busy
   repeat for each key ownerEmail in ownershipArray
      put ownershipArray [ownerEmail]["domains"] into domainArray
      repeat for each key indexNum in domainArray
         put domainArray [indexNum]["domain"] into domainName
         put ownerEmail into domainNameArray [domainName]
      end repeat
   end repeat
   put keys (domainNameArray) into ownerDomainNames
   url_SortDomainIndex ownerDomainNames
   --
   display_AtopiaDomains ownerDomainNames, "Test Owner Domains,Atopia"
end menu_TestDomainOwners

on _
end _

on insert_Menu
   return "Global | Atopia | Tree | Menu"
end insert_Menu


--> Global | Atopia | DomainOwners | Menu | Props
-

--> Global | Atopia | DomainOwners | Menu | Disabled
-
