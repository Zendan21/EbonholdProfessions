EBONHOLD PROFESSIONS 1.10.2
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

The main window, settings window, buttons, section headings, and blacklist
editor use the same dark panels, thin borders, muted text, and gold accents as
Ravioli Family Activity Finder.

The profession window is divided into four sections:

1. Main Professions - primary crafting and gathering professions.
2. Sub Professions - Cooking, Fishing, and First Aid.
3. Tracking - Find Fish, Find Herbs, and Find Minerals.
4. Ability Types - Basic Campfire, Disenchant, Milling, and Prospecting.

Empty sections are hidden automatically. Characters with many learned
professions can use the mouse wheel over the grouped list to scroll it.

RESIZABLE WINDOW
----------------
Drag the grip in the bottom-right corner to resize the profession window. Its
size is saved automatically. At wider sizes, whole profession groups are
balanced across two section columns; narrower sizes return to one stacked
section column. Very wide sections can also display two buttons per group.

Right-click the resize grip to restore the automatic default size.
Press Escape at any time to close the profession window.

PROFESSION HOTKEYS
------------------
Right-click any clickable profession or utility in the profession window and
choose "Assign hotkey", then press the desired key. Modifier combinations such
as Ctrl-P, Shift-P, and Alt-P are supported.

The assigned key works while the profession window is closed. Assigning P to
Prospecting, for example, finds the first eligible non-blacklisted ore stack
and prospects it with the same key press.

Right-click the entry and choose "Reset hotkey to default" to remove its
override and restore the key's normal WoW behavior. Escape cancels assignment;
Backspace or Delete clears the selected entry's hotkey.

AUTOMATIC PROCESSING AND BLACKLISTS
-----------------------------------
Prospecting, Milling, and Disenchant automatically scan the character's bags.
Clicking the utility or pressing its hotkey selects the first unlocked eligible
item and processes it in one secure action. Prospecting and Milling require a
stack of at least 5; Disenchant requires one eligible equipment item.

Automatic bag targeting can be turned on or off from the Settings button in
the profession window. It is enabled by default. The same option is available
from a launcher button's right-click menu and from the right-click menu for
Prospecting, Milling, or Disenchant. When disabled, clicking or pressing the
hotkey activates the ability for normal manual item targeting. Existing
blacklists remain saved.

1. Right-click Prospecting, Milling, or Disenchant in the profession window.
2. Choose "Edit blacklist".
3. Open a bag and drag any item that must never be processed into the blue area.
4. Right-click a blacklisted item to remove it, or use "Clear Blacklist".

Blacklists are stored separately for Prospecting, Milling, and Disenchant. If
no eligible item is found, the ability remains available for manual targeting.

WoW requires one physical key press for each operation. The add-on will never
loop or process items unattended. Repeatedly press the assigned hotkey to work
through eligible bag items without opening the bags again.

COMMANDS
--------
/ehp             Toggle the profession window
/ehp show        Show the window
/ehp hide        Hide the window
/ehp refresh     Rescan learned professions
/ehp debug       Report profession API scan results
/ehp settings    Open or close the settings window
/ehp button      Show or hide the movable launcher
/ehp minimap     Show or hide the minimap launcher

/professions is an alternative to /ehp.
