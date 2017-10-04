# SnagaLoatheb
Loatheb healing rotation addon 
Minor modifications made for v 1.12 compatibility

Loatheb Addon that helps setting up a healing rotation for the MT. Fully customizable list.
The list will contain healers in their class colors so you can see who is next in line for healing. Once someone heals and therefore has the healing debuff they will show as RED, if theyre dead they will show as GREY.
This way you can always see whos turn it is to heal, without use of macros. It will also allow to make up for mistakes in the rotation easily.

/loatheb on
turns on the mod

/loatheb master
used to set up the list for everyone (only 1 person in the raid does this)

Shift+Drag to move the window.

How it works: Everyone that wants to see the list installs the addon.

1 person enables the master mode with "/loatheb master" and generates the healing-list by clicking on the names in the order he wishes.
He then presses "save" and the list should be sent to everyone in the raid.
Both the "BC" (broadcast) and "request" buttons should be obsolete, as the list will be broadcast on changes automatically.
To edit the list, press "edit" in master-mode. Players that have newly joined the raid in the meantime will show up at the end of the "generating-list".

The addon should be pretty stable in regard to raidcomposition changing. if healers leave the raid and are in the list still, they will be marked with two "!!" so the player in master-mode knows he should edit the list to get rid of them.
If non-healers leave and join the raid, all should stay the same.

Still, dont change raid composition midfight as some updatefunctions are disabled then to improve performance.

Note:
The healing list has a limit of 15 players at the moment, if you have more healers in the raid for loatheb youre doing something wrong anyway. but keep that in mind if you test the addon outside the loatheb fight.

Warning:
You can and should use the "/loatheb master" command again to "sign off" master mode, before someone else becomes new master, as the program will bug otherwise. 
