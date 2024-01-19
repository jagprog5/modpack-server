# needs to bring a player there to load the chunk so it can be modified
tp @s 100001 4096 100001

# for limbo effect
scoreboard objectives add in_limbo dummy
scoreboard objectives add just_out_limbo dummy

# global static effects
scoreboard objectives add buff_timer dummy

fill 100000 0 100000 100015 40 100015 air
fill 100000 40 100000 100015 80 100015 air
fill 100000 80 100000 100015 120 100015 air
fill 100000 120 100000 100015 160 100015 air
fill 100000 160 100000 100015 200 100015 air
fill 100000 200 100000 100015 240 100015 air
fill 100000 240 100000 100015 255 100015 air

fill 100000 0 100000 100015 255 100000 bedrock
fill 100015 0 100015 100015 255 100000 bedrock
fill 100000 0 100000 100000 255 100015 bedrock
fill 100015 0 100015 100000 255 100015 bedrock
fill 100000 0 100000 100015 0 100015 bedrock
fill 100000 255 100000 100015 255 100015 bedrock
setblock 100006 10 100006 minecraft:repeating_command_block facing=down replace {Command:"/scoreboard players add dummy_player_username buff_timer 1",TrackOutput:0b,auto:1b}
setblock 100006 9 100006 minecraft:chain_command_block facing=down replace {Command:"/scoreboard players test dummy_player_username buff_timer 200 2147483647",TrackOutput:0b,auto:1b}
setblock 100006 8 100006 minecraft:chain_command_block conditional=true,facing=down replace {Command:"/scoreboard players set dummy_player_username buff_timer 0",TrackOutput:0b,auto:1b}
setblock 100006 7 100006 minecraft:chain_command_block conditional=true,facing=down replace {Command:"/function modpack-server:apply-status-effects",TrackOutput:0b,auto:1b}

# Notch was opped in install-functions.sh (unused op account needed to own spot loader)
setblock 100008 7 100008 chickenchunks:chunk_loader 1 replace {owner: "Notch"}

# the spot loader isn't active until after the chunk has been loaded from disk (due to setblock being used).
# this can be done by unloading the chunk then loading the chunk. the best way of doing that is to stop the server;
# then on next login the player will load the cmd chunk
tell @s "cmd chunk reload required"
tell @s "TYPE 'yes' IN THE TERMINAL"
