EBONHOLD PROFESSIONS 1.2.0
====================

For the Wrath of the Lich King 3.3.5 client used by Project Ebonhold.

INSTALL
-------
Copy the EbonholdProfessions folder into:

    World of Warcraft\Interface\AddOns\

Restart WoW or log out and back in. Enable "Ebonhold Professions" on the
character-selection AddOns screen.

LAUNCHER BUTTONS
----------------
The add-on provides two launcher buttons and does not create or modify macros:

1. A movable square button that can be positioned beside an action bar.
   Left-click opens the profession window; right-drag moves the button.

2. A standard minimap button.
   Left-click opens the profession window; right-drag moves it around the map.

The window contains every profession the current character knows. Click a
crafting profession to open its recipe window. Mining opens Smelting. Fishing
activates Fishing. Herbalism and Skinning are displayed with their current
skill ranks, but are not clickable because those gathering skills do not have
recipe windows.

Learned profession utilities are also listed directly beneath their related
profession. These include Prospecting, Disenchant, Milling, Basic Campfire,
Find Herbs, Find Minerals, and Find Fish.

COMMANDS
--------
/ehp             Toggle the profession window
/ehp show        Show the window
/ehp hide        Hide the window
/ehp refresh     Rescan learned professions
/ehp debug       Report profession API scan results
/ehp button      Show or hide the movable launcher
/ehp minimap     Show or hide the minimap launcher

/professions is an alternative to /ehp.
