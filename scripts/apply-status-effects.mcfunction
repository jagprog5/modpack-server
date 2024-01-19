# global static buffs
effect @e[type=player] minecraft:haste 11 3 true
effect @e[type=villager_golem] minecraft:regeneration 11 1 true
effect @e[type=villager_golem] minecraft:speed 11 2 true

# limbo additions:
# gives some buffs upon entering back into the world from limbo
scoreboard players set @a[score_in_limbo_min=1] just_out_limbo 1 {Dimension:0}
title @a[score_just_out_limbo_min=1] actionbar {"text": "Welcome Back", "color":"gold"}
effect @a[score_just_out_limbo_min=1] clear
effect @a[score_just_out_limbo_min=1] minecraft:jump_boost 240 1 true
effect @a[score_just_out_limbo_min=1] minecraft:speed 240 8 true
effect @a[score_just_out_limbo_min=1] minecraft:glowing 240 255 true
effect @a[score_just_out_limbo_min=1] minecraft:invisibility 240 255 true
scoreboard players set @a just_out_limbo 0

# gives large speed boost so players can find there way out of limbo easier
scoreboard players set @a in_limbo 0
scoreboard players set @a in_limbo 1 {Dimension:684}
effect @a[score_in_limbo_min=1] minecraft:speed 11 20 true
effect @a[score_in_limbo_min=1] minecraft:jump_boost 11 1 true
