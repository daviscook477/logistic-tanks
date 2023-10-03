# Logistic Tanks
Connect storage tanks to the logistics network so robots can move fluids around your base without the need for barrels.

# Why
1. Barrels are an extra complication to carrying fluids with logistic robots, and take a bunch of extra space for barreling and unbarreling - especially in a mall.
2. The logistic robots already have a compartment for storing items that they transport around the factory - so why not make the compartment water-tight and capable of directly transporting fluids. When the robot docks with the logistic variants of storage tanks, it fills/empties its internal tank.

# Features
1. Passive provider tank acts like a passive provider chest but for fluids instead of items.
2. Requester tank acts like a requester chest but for fluids instead of items.
2. Smaller 1x1 variants of the passive provider tank and requester tank for providing/requesting fluids within a small footprint.
3. Set the filter on requester tanks to indicate what type of fluid they require.
    - The filter is set with a convenient side GUI when opening the tank GUI.
    - The filter may only be changed if the tank is empty - we don't want mixed fluid networks!
4. Copy/paste requests from assembly machines onto requester tanks just like requester chests.
5. Circuit connections to the tanks read the contents of the tank.
    - The requests of a requester tank cannot be set using the circuit network. This is limited because we don't want mixed fluid networks.
6. Logistic robots recipe includes barrels, since the robots need somewhere to store the fluid they transport.
    - Can be enabled/disabled in mod settings. Defaults to enabled.
7. Minimal UPS impact, only checks up to 10 tanks per tick = 600 tanks per second.
    - Number of tanks checked per tick can be increased to increase throughput of fluids at a potential UPS cost for bases making heavy use of logistic tanks.

# Limitations
1. The active provider, storage, and buffer tanks are intentionally left unimplemented. Due to the internal setup of this mode, an active provider tank could provide to a storage chest or vice versa (similar issue with buffer tanks/chests).
2. Even with the above precaution it is still possible for a storage chest to have fluids inserted directly by logistic robots if the requester tank to which they are transporting fluids is destroyed while they are travelling. In most cases this will resolve itself when the requester tank is rebuilt and the fluid in the storage chest is prioritized over fluid in a passive provider tank due to the priority order of the logistic network.

# Design
1. Storage tank + logistic chest in the same position on the map.
    - The player interacts with the storage tank.
    - The logistic robots interact with the logistic chest.
    - Logistic chest has exactly enough slots to storage an equal amount of fluid in barrels to the amount directly stored by the tank.
2. Lua script equalizes the amount of fluid barrels in the logistic chest to match the amount of fluid in the storage tank.
    - This is calculated by taking the sum of the fluid in the storage tank with the number of fluid in the logistic chest and then dividing in half to determine the actual amount expected to be in each the storage tank and the logistic chest. Since barrels can only be in integer amounts, the logistic chests gets a number of barrels equal to the floor of the sum over two and then the storge tank can just get the remainder.
    - This has the caveat of making each logistic tank capable of storing twice the fluid as a typical storage tank since it has both its fluid storage and the chest storage.
3. Small relative GUI for the interactible storage tank that lets the player pick the filter/request.
    - Interactions with this GUI are propagated to the internal logistic chest.

# TODO
1. Popup GUI for selecting the fluid + amount (should essentially just be the popup for setting a normal logistic request but w/o the tabs since we only want fluids)
3. 1x1 tanks + sprite mask/highlight for them - I don't really like the 1x1 tank that exists on the mod portal. Do I need to make my own 1x1 tank as well for this to work?
7. graphics patch for 3x3 tanks (animation on the logistic chest) some sort of camera lens collapsing animation integrated as a patch on the top if possible
8. when the tank is mined, use the pre-mine event to try to push not just the fluid in the real tank, but also the fluid in the chest as well out into the connected fluid network

# MAYBE
1. Use a different force logistic network so the tanks don't cross with the chests - this allows active provider, buffer, and storage to exist
   - This can also introduce a different logistics robot specifically for transferring fluids - the only problem is that I'd essentially have to turn every roboport into two roboports and the fluid logistic robots wouldn't be accessible from the inventory of the main roboport - really not ideal