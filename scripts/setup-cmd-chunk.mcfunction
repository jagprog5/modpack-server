# needs to bring a player there to load the chunk so it can be modified
tp @s 100001 4096 100001

# global static effects
scoreboard objectives add buff_timer dummy

# for owned wolf selection
scoreboard objectives add wolf_owned dummy

# for tamed horse selection
scoreboard objectives add horse_tamed dummy

fill 99984 0 99984 100031 10 100031 air
fill 99984 10 99984 100031 20 100031 air
fill 99984 20 99984 100031 30 100031 air
fill 99984 30 99984 100031 40 100031 air
fill 99984 40 99984 100031 50 100031 air
fill 99984 50 99984 100031 60 100031 air
fill 99984 60 99984 100031 70 100031 air
fill 99984 70 99984 100031 80 100031 air
fill 99984 80 99984 100031 90 100031 air
fill 99984 90 99984 100031 100 100031 air

fill 99984 100 99984 100031 110 100031 air
fill 99984 110 99984 100031 120 100031 air
fill 99984 120 99984 100031 130 100031 air
fill 99984 130 99984 100031 140 100031 air
fill 99984 140 99984 100031 150 100031 air
fill 99984 150 99984 100031 160 100031 air
fill 99984 160 99984 100031 170 100031 air
fill 99984 170 99984 100031 180 100031 air
fill 99984 180 99984 100031 190 100031 air
fill 99984 190 99984 100031 200 100031 air

fill 99984 200 99984 100031 210 100031 air
fill 99984 210 99984 100031 220 100031 air
fill 99984 220 99984 100031 230 100031 air
fill 99984 230 99984 100031 240 100031 air
fill 99984 240 99984 100031 250 100031 air
fill 99984 250 99984 100031 255 100031 air

fill 99984 0 99984 100031 255 99984 bedrock
fill 100031 0 100031 100031 255 99984 bedrock
fill 99984 0 99984 99984 255 100031 bedrock
fill 100031 0 100031 99984 255 100031 bedrock
fill 99984 0 99984 100031 0 100031 bedrock
fill 99984 255 99984 100031 255 100031 bedrock
fill 99984 1 99984 100031 1 100031 minecraft:wooden_slab

setblock 100006 11 100006 minecraft:wooden_slab
setblock 100006 10 100006 minecraft:repeating_command_block facing=down replace {Command:"/scoreboard players add dummy_player_username buff_timer 1",TrackOutput:0b,auto:1b}
setblock 100006 9 100006 minecraft:chain_command_block facing=down replace {Command:"/scoreboard players test dummy_player_username buff_timer 200 2147483647",TrackOutput:0b,auto:1b}
setblock 100006 8 100006 minecraft:chain_command_block conditional=true,facing=down replace {Command:"/scoreboard players set dummy_player_username buff_timer 0",TrackOutput:0b,auto:1b}
setblock 100006 7 100006 minecraft:chain_command_block conditional=true,facing=down replace {Command:"/function modpack-server:apply-status-effects",TrackOutput:0b,auto:1b}

setblock 100008 8 100008 minecraft:wooden_slab
setblock 100008 7 100008 railcraft:worldspike
kill @s
