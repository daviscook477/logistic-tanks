# Logistic Tanks
Connect storage tanks to the logistics network so robots can move fluids around your base without the need for barrels. Additionally provides logistic versions of Anicha's 1x1 minibuffers for compact fluid delivery.
![](mod-portal/between_tanks.png)

## Motivation
1. Barrels are an extra complication to carrying fluids with logistic robots, and take a bunch of extra space for barreling and unbarreling - especially in a mall.
2. The logistic robots already have a compartment for storing items that they transport around the factory - so why not make the compartment water-tight and capable of directly transporting fluids. When the robot docks with the logistic variants of storage tanks, it fills/empties its internal tank.

## Features
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
7. Limited UPS impact, only checks up to 10 tanks per tick = 600 tanks per second.
    - Number of tanks checked per tick can be increased to increase throughput of fluids at a potential UPS cost for bases making heavy use of logistic tanks.

## Limitations
1. The active provider, storage, and buffer tanks are intentionally left unimplemented. Due to the internal setup of this mod, an active provider tank could provide to a storage chest or vice versa (similar issue with buffer tanks/chests).
2. Even with the above precaution it is still possible for a storage chest to have fluids inserted directly by logistic robots if the requester tank to which they are transporting fluids is destroyed while they are travelling. In most cases this will resolve itself when the requester tank is rebuilt and the fluid in the storage chest is prioritized over fluid in a passive provider tank due to the priority order of the logistic network.
3. 

## TODO
1. Turns out the only type of tank we can't have is active provider tank. Storage and buffer tanks can be used without trouble if the chests are *always* filtered - i.e. it will need a system to destroy/create the chest when the filter changes in the GUI
2. When trying to use the GUI to change the filter, also check the internal logistic chest and immediately equalize if it contains fluid. Then performthe same fluid check for changing the filter.
3. Test to ensure no crashes or wonky behavior with multiple fluid networks.
4. The logistic network actually produces a read signal for each of the fluid items in it, but because these are hidden items they aren't comparable in combinators. Additionally, even if I unhide them, they are different signals than the actual fluid signals. There are a couple ways to deal with this an none of them are good.
    - Ignore the problem and list it as a limitation. The amount of fluid in the logistic network cannot be read at all. This will still leave the signals present in the output circuit signal and in the logistic network GUI.
    - Stop marking the items as hidden. Create a new group for them. Since no recipe unlocks these items, they won't be visible in the course of normal gameplay. But now we have different signals for real fluids (in pipes/tanks) and logistic network fluids that are not equivalent but share signal icons.
    - The same as the above idea but figure out some good alternate icon for the logistic network fluids to distinguish them. Are the barreled versions of each fluid a reasonable icon? This would conflict with the barrel signals instead which isn't that much of an improvement. What if I just legitimately use the barrel items as the logistic network fluid item? Those are normal items so the player can simply request them in a normal logistic chest. To prevent that the item either has to be hidden, or have no recipe. Making the item hidden defeats the whole purpose of what I'm trying to do here, so what if I have barrels but without recipes to unlock any fluid-specific barrel items. Now any mod that uses fluid-specific barrel items in their recipes will be incompatible with logistic tanks. And any player that wants to use barrels for legitimate non logistic tank purposes will find this mod incompatible.
    - Create a combinator-esque building with circuit connections that transforms the signals from the roboport into normal fluid signals - this is fairly usable but adds a combinator-esque building which either updates really slowly or is terrible for UPS so I don't really like it. Also duplicate icon signals are still an issue since adding the normal roboport signals to the result of this combinator will result in both the real fluid signals and the logisic fluid signals being present on the wire.
    - An even worse idea is to put a hidden constant combinator under every roboport and automatically update it with the right fluid signal values and connect it to the placed roboport automatically. This is like the combinator-esque building idea above but even worse for UPS.
    - Stop marking the items as hidden. Create a new group for them. Since no recipe unlocks these items, they won't be visible in the course of normal gameplay. But now we have different signals for real fluids (in pipes/tanks) and logistic network fluids that are not equivalent. This idea is actually a terrible idea since always control deals with logistic requests and signals the same "Always show the item in selection lists (item filter, logistic request etc.) even when locked recipe for that item is present" so we can't actually do this. If the player is able to interact with the signal directly - they will be able to request the fluids to normal chests - which defeats the whole idea of the mod.
    - So the only real solution is to have some sort of script that is converting the signals. Do I want to do that? Not really. Of course I could just make the items into barrels and let the player request them into normal chests if they really want to. And then it's up to players themself to avoid doing anything cheating with the mod.

## Credits
1. [test447](https://mods.factorio.com/user/test447) - code, minibuffer mask, tech icon
2. [Kirazy](https://mods.factorio.com/user/Kirazy) - storage tank mask
3. [Anicha](https://mods.factorio.com/user/Anicha) - minibuffer dependency
