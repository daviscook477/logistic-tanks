# Logistic Tanks
Connect storage tanks to the logistics network so robots can move fluids around your base without the need for barrels. Additionally provides logistic versions of Anicha's 1x1 minibuffers for compact fluid delivery.

# Motivation
1. Barrels are an extra complication to carrying fluids with logistic robots, and take a bunch of extra space for barreling and unbarreling - especially in a mall.
2. The logistic robots already have a compartment for storing items that they transport around the factory - so why not make the compartment water-tight and capable of directly transporting fluids. When the robot docks with the logistic variants of storage tanks, it fills/empties its internal tank.

# Features
1. Passive provider tank acts like a passive provider chest but for fluids instead of items.
2. Requester tank acts like a requester chest but for fluids instead of items.
2. Passive provider/requester variants of Anicha's 1x1 minibuffers for providing/requesting fluids within a small footprint.
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

# Credits
1. [test447](https://mods.factorio.com/user/test447) - code, minibuffer mask, tech icon
2. [Kirazy](https://mods.factorio.com/user/Kirazy) - storage tank mask
3. [Anicha](https://mods.factorio.com/user/Anicha) - minibuffer dependency
