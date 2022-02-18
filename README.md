# Logistic Tanks
Connect storage tanks to the logistics network so robots can move fluids around your base w/o the use of barrels.

# Why
1. Barrels are an annoying complication to the carrying of fluids around a logistic robot base, where barrels must be kept in supply and an extra set of provider/request chest + inserters + assembler must be used to barrel/unbarrel the fluids for recipes. It makes recipes that use fluids take up a needlessly large amount of space compared to the non-fluid counterparts.
2. The logistic robots can have their internal item storage made water-tight and corrosion-resistant so it can directly hold the fluids, w/o the need for the barrelling/unbarrelling process. Instead the robot's internal tank gets filled/unfilled when it docks with the logistic-specific fluid tanks.

# Features
1. All 5 logistic chest types (active provider, passive provider, storage, buffer, and requester) have a corresponding storage tank for fluids.
2. Smaller 1x1 variants of the storage tank in each logistic chest variant, for requesting/providing liquids within a small footprint.
3. Set the filter on storage, buffer, and requester tanks to indicate what type of fluid they require.
    - The filter is set with a convenient side GUI when opening the tank GUI.
    - The filter may only be changed if the tank is empty.
4. Copy/paste requests from assembly machines onto requester tanks just like requester chests.
5. Circuit connections to the tanks read the contents of the tank.
    - The requests of a requester tank cannot be set using the circuit network. This is limited because each fluid network can only contain one type of fluid.
6. Logistic robots recipe includes barrels, since the robots need somewhere to store the liquid they transport.
    - Can be enabled/disabled in mod settings. Defaults to enabled.
7. Minimal UPS impact, optimized to only check tanks with script infrequently.
    - Interval between checks can be increased to decrease UPS impact at the cost of decreased throughput of fluids.

# Design
1. Storage tank + logistic chest in the same position on the map.
    - The player interacts with the storage tank.
    - The logistic robots interact with the logistic chest.
    - Logistic chest has exactly enough slots to storage an equal amount of fluid in barrels to the amount directly stored by the tank.
2. Lua script equalizes the amount of fluid barrels in the logistic chest to match the amount of fluid in the storage tank.
3. Small relative GUI for the interactible storage tank that lets the player pick the filter/request.
    - Interactions with this GUI are propagated to the internal logistic chest.