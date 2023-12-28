script "Global | Dynadot | Tree | Line | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dynadot | Tree | Line | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Dynadot | Tree | Line | Dev | Menu
-
on menu_SetAstralSubdomain indexView
   put the selected_Line of indexView into domainName
   --
   put lcw_Ask ("What sudomain would you liek to set?", "www") into subDomainName
   put "a2v0pgisrrpogjv.cname.eu.loclx.io" into cNameValue
   dynadot_SetDns domainName, subDomainName, cNameValue
   put the result into dnsData
   --
   display_Data dnsData, "dynadot_GetDns()", domainName
end menu_SetAstralSubdomain

on menu_XposeDomain displayView
   put the selected_Line of displayView into domainName
   ---
   put astral_FetchPeopleSubDomainList() into aSubDomains
   --
   put dynadot_GetDns (domainName) into dnsData
   --
   tunnel_ReserveLocalDomain domainName, "eu"
   put the result into cNameValue
   put "jfwwfydq93tktzy.cname.eu.loclx.io"  into cNameValue
   --
   -- dynadot_SetDns domainName, aSubDomains, cNameValue
   repeat for each item subDomainName in aSubDomains
      set the cursor to busy
      dynadot_AddSubdomain domainName, subDomainName, cNameValue
   end repeat
   --
   display_DynadotDomain domainName
end menu_XposeDomain

on menu_SymLinkAndRegister displayView
   put the selected_Line of displayView into domainName
   put lcw_Ask ("Create Dynadot CNAME?", domainName, "Dynadot", displayView) into dynSubDomain
   --
   dynadot_AddSubdomain domainName, dynSubDomainName, "yhdhcbundskxzwc.eu.loclx.io"
   --
   gitwiki_CreateSymLink gitWikiDomain, dynSubDomain
   --
   display_EarthWikis
   diplay_GitWikiFolders pDisplayView, pWikiFilter
end menu_SymLinkAndRegister
