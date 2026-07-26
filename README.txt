EBONHOLD PROFESSIONS 1.6.2
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
   Left-click opens the profession window. Right-click opens a menu for
   locking its position, setting opacity, or hiding it. Right-click-drag moves
   it while unlocked.

2. A standard minimap button.
   Left-click opens the profession window. Right-click opens a menu for
   locking its position, setting opacity, or hiding it. Right-click-drag moves
   it around the minimap while unlocked.

Opacity can be set independently from 10% to 100% for each launcher. A faded
launcher always returns to 100% opacity while the mouse is hovering over it.

The window contains every profession the current character knows. Click a
crafting profession to open its recipe window. Mining opens Smelting. Fishing
activates Fishing. Herbalism and Skinning are displayed with their current
skill ranks, but are not clickable because those gathering skills do not have
recipe windows.

Learned profession utilities are also listed directly beneath their related
profession. These include Prospecting, Disenchant, Milling, Basic Campfire,
Find Herbs, Find Minerals, and Find Fish.

PROFESSION HOTKEYS
------------------
Right-click any clickable profession or utility in the profession window and
choose "Assign hotkey", then press the desired key. Modifier combinations such
as Ctrl-P, Shift-P, and Alt-P are supported.

The assigned key works while the profession window is closed. Without an
allowed item available, assigning P to Prospecting activates Prospecting and
leaves it ready for an ore stack to be selected. With an allowed ore available,
the same key press also targets that stack automatically.

Right-click the entry and choose "Reset hotkey to default" to remove its
override and restore the key's normal WoW behavior. Escape cancels assignment;
Backspace or Delete clears the selected entry's hotkey.

ALLOWED ITEM LISTS
------------------
Prospecting, Milling, and Disenchant each have an editable allowed-item list.

1. Right-click Prospecting, Milling, or Disenchant in the profession window.
2. Choose "Edit allowed items".
3. Open a bag and drag an item into the blue drop area.
4. Right-click an item in the list to remove it, or use "Clear List".

When at least one allowed item is available in the bags, clicking that utility
or pressing its assigned hotkey casts the profession ability and targets the
next eligible stack in one secure action. Prospecting and Milling require a
stack of at least 5; Disenchant requires one item.

WoW requires one physical key press for each operation. The add-on will never
loop or process items unattended. Repeatedly press the assigned hotkey to work
through the allowed bag items without opening the bags again.

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
