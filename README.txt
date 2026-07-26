EBONHOLD PROFESSIONS 1.1.0
====================

For the Wrath of the Lich King 3.3.5 client used by Project Ebonhold.

INSTALL
-------
Copy the EbonholdProfessions folder into:

    World of Warcraft\Interface\AddOns\

Restart WoW or log out and back in. Enable "Ebonhold Professions" on the
character-selection AddOns screen.

ACTION-BAR BUTTON
-----------------
The add-on creates a character macro named "Professions" when you log in.

1. Type /macro
2. Select the Professions macro
3. Drag it onto any action-bar slot

If that macro name is already used, the add-on creates "Ebon Prof" instead.
It never overwrites an existing macro.

The action-bar macro opens and closes a single window containing every
profession the current character knows. Click a crafting profession to open
its recipe window. Mining opens Smelting. Fishing activates Fishing.
Herbalism and Skinning are displayed with their current skill ranks, but are
not clickable because those gathering skills do not have recipe windows.

Learned profession utilities are also listed directly beneath their related
profession. These include Prospecting, Disenchant, Milling, Basic Campfire,
Find Herbs, Find Minerals, and Find Fish.

COMMANDS
--------
/ehp             Toggle the profession window
/ehp show        Show the window
/ehp hide        Hide the window
/ehp macro       Create the action-bar macro if it is missing
/ehp refresh     Rescan learned professions
/ehp debug       Report profession API scan results
/ehp button      Show or hide the movable fallback launcher

/professions is an alternative to /ehp.
