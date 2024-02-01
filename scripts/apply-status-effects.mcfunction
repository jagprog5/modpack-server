# global static buffs
effect @e[type=player] minecraft:haste 11 3 true
effect @e[type=villager_golem] minecraft:regeneration 11 1 true

# slow regen (1 hp per 10 second)
effect @e[type=villager] minecraft:regeneration 1 2 true

# conditional buffs on wolf being owned
# all wolves get it to set 1
scoreboard players set @e[type=wolf] wolf_owned 1
# unowned wolves get it set to 0
scoreboard players set @e[type=wolf] wolf_owned 0 {OwnerUUID:""}
# slow regen (1 hp per 10 second)
effect @e[score_wolf_owned_min=1] minecraft:regeneration 1 2 true
# speed
effect @e[score_wolf_owned_min=1] minecraft:speed 11 1 true

# conditional buffs on tamed horse
scoreboard players set @e[type=horse] horse_tamed 1 {Tame:1b}
# slow regen (1 hp per 10 second)
effect @e[score_horse_tamed_min=1] minecraft:regeneration 1 2 true
