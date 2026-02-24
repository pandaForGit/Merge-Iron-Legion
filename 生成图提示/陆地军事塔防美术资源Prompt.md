# 《陆地军事塔防》AI生成美术资源Prompt列表

专为**陆地军事塔防**游戏设计的完整美术资源生成指南，新增**敌方防御塔、地形系统、多兵种单位**。采用**16-bit像素艺术风格**，AI生成SVG矢量图，确保总资源<1MB。

## 🎨 统一风格要求

每个Prompt末尾必须包含：
```
Clean vector pixel art [尺寸] [类型]Lv[级] Frame[1/2] ([Idle/Action]): [详细描述], 16-bit military retro, flat army greens/browns/grays/oranges, sharp edges, viewBox='0 0 [W H]', separate SVG layers, SVG export.
```

**AI工具**：Leonardo.ai (Vector+Animation mode) 或 Ideogram (SVG+multi-frame)
**压缩**：生成后用SVGOMG压缩<1KB/张
**格式**：Frame 1 (Idle/Base) + Frame 2 (Action/Attack)

## 🗺️ 1. Tiles (10种静态地貌，32x32 SVG)

1. **Grass Field Tile**: Clean vector pixel art 32x32 grass plain tile, military battlefield, flat green/brown colors, viewBox='0 0 32 32', SVG export.
2. **Mud Road Tile**: Clean vector pixel art 32x32 muddy dirt road tile, tire tracks, battlefield terrain, viewBox='0 0 32 32', SVG.
3. **Sand Dunes Tile**: Clean vector pixel art 32x32 sandy desert dunes, military advance, beige colors, viewBox='0 0 32 32', SVG.
4. **Forest Edge Tile**: Clean vector pixel art 32x32 forest tree line, camouflage green, military ambush, viewBox='0 0 32 32', SVG.
5. **Rocky Terrain Tile**: Clean vector pixel art 32x32 jagged rocks and boulders, defensive positions, gray/brown, viewBox='0 0 32 32', SVG.
6. **Urban Ruins Tile**: Clean vector pixel art 32x32 destroyed city buildings, war-torn concrete, viewBox='0 0 32 32', SVG.
7. **River Crossing Tile**: Clean vector pixel art 32x32 shallow river with military bridge, water obstacles for ground units, blue water with waves, viewBox='0 0 32 32', SVG.
8. **Water Terrain Tile**: Clean vector pixel art 32x32 deep water area, naval passage for marine units, dark blue with whitecaps, viewBox='0 0 32 32', SVG.
9. **Barbed Wire Tile**: Clean vector pixel art 32x32 defensive barbed wire obstacles, military fortifications, viewBox='0 0 32 32', SVG.
9. **Trenches Tile**: Clean vector pixel art 32x32 dug military trenches, defensive lines, earth tones, viewBox='0 0 32 32', SVG.
10. **Command Post Tile**: Clean vector pixel art 32x32 military base camp, tents and vehicles, strategic point, viewBox='0 0 32 32', SVG.

## 🏭 2. 建筑 (4种 × 3级 = 12种，64x64 SVG，2帧动画)

### 金矿 (Gold Mine) - 产金建筑
11. **Gold Mine Lv1 Frame 1 (Idle)**: Clean vector pixel art 64x64 gold mine Lv1 Frame 1 idle: small military supply depot with crates, subtle flag waving, army green/brown, 16-bit military retro, flat colors, sharp edges, viewBox='0 0 64 64', SVG.
12. **Gold Mine Lv1 Frame 2 (Produce)**: Clean vector pixel art 64x64 gold mine Lv1 Frame 2 produce: supply crates opening, gold coins floating out with particle trails, depot shaking slightly, viewBox='0 0 64 64', SVG.
13. **Gold Mine Lv2 Frame 1 (Idle)**: Clean vector pixel art 64x64 gold mine Lv2 Frame 1 idle (scale 1.3x): larger supply warehouse with conveyor belt static, enhanced military styling, viewBox='0 0 64 64', SVG.
14. **Gold Mine Lv2 Frame 2 (Produce)**: Clean vector pixel art 64x64 gold mine Lv2 Frame 2 produce: conveyor activating, multiple coins flowing with mechanical sounds implied, warehouse lights flashing, viewBox='0 0 64 64', SVG.
15. **Gold Mine Lv3 Frame 1 (Idle)**: Clean vector pixel art 64x64 gold mine Lv3 Frame 1 idle (scale 1.6x, gold glow): fortress supply bunker with heavy doors, reinforced concrete, glowing gold accents, viewBox='0 0 64 64', SVG.
16. **Gold Mine Lv3 Frame 2 (Produce)**: Clean vector pixel art 64x64 gold mine Lv3 Frame 2 produce: massive gold shipment doors opening, coin avalanche with epic particles, bunker trembling, viewBox='0 0 64 64', SVG.

### 兵营 (Barracks) - 产步兵建筑
17. **Barracks Lv1 Frame 1 (Idle)**: Clean vector pixel art 64x64 barracks Lv1 Frame 1 idle: basic military tent with flag, soldier silhouettes inside, army green canvas, viewBox='0 0 64 64', SVG.
18. **Barracks Lv1 Frame 2 (Spawn)**: Clean vector pixel art 64x64 barracks Lv1 Frame 2 spawn: tent flap opening, single soldier marching out with dust clouds, flag waving stronger, viewBox='0 0 64 64', SVG.
19. **Barracks Lv2 Frame 1 (Idle)**: Clean vector pixel art 64x64 barracks Lv2 Frame 1 idle (scale 1.3x): concrete barrack building with antennas, multiple windows, enhanced military architecture, viewBox='0 0 64 64', SVG.
20. **Barracks Lv2 Frame 2 (Spawn)**: Clean vector pixel art 64x64 barracks Lv2 Frame 2 spawn: doors opening wide, squad of soldiers deploying in formation, building lights activating, viewBox='0 0 64 64', SVG.
21. **Barracks Lv3 Frame 1 (Idle)**: Clean vector pixel art 64x64 barracks Lv3 Frame 1 idle (scale 1.6x, red glow): fortress command center with radar dishes, armored walls, strategic military complex, viewBox='0 0 64 64', SVG.
22. **Barracks Lv3 Frame 2 (Spawn)**: Clean vector pixel art 64x64 barracks Lv3 Frame 2 spawn: massive deployment bay opening, platoon of elite soldiers charging out, explosion of deployment particles, viewBox='0 0 64 64', SVG.

### 炮台 (Cannon Tower) - 远程炮击建筑
23. **Cannon Lv1 Frame 1 (Idle)**: Clean vector pixel art 64x64 cannon Lv1 Frame 1 idle: basic field artillery piece on wheeled carriage, barrel horizontal, military green/gray, viewBox='0 0 64 64', SVG.
24. **Cannon Lv1 Frame 2 (Fire)**: Clean vector pixel art 64x64 cannon Lv1 Frame 2 fire: barrel recoiling back 5px, muzzle flash expanding 10px radial, smoke cloud rising 8px, cannonball trail forward, viewBox='0 0 64 64', SVG.
25. **Cannon Lv2 Frame 1 (Idle)**: Clean vector pixel art 64x64 cannon Lv2 Frame 1 idle (scale 1.3x): armored self-propelled artillery, elevated barrel, reinforced gun shield, viewBox='0 0 64 64', SVG.
26. **Cannon Lv2 Frame 2 (Fire)**: Clean vector pixel art 64x64 cannon Lv2 Frame 2 fire: dual recoil motion, enhanced flash 12px, double smoke trails, larger cannonball with spin effect, viewBox='0 0 64 64', SVG.
27. **Cannon Lv3 Frame 1 (Idle)**: Clean vector pixel art 64x64 cannon Lv3 Frame 1 idle (scale 1.6x, fire glow): massive railway artillery fortress, super heavy barrel, glowing ammunition ready, viewBox='0 0 64 64', SVG.
28. **Cannon Lv3 Frame 2 (Fire)**: Clean vector pixel art 64x64 cannon Lv3 Frame 2 fire: enormous recoil 10px with screen shake lines, epic flash 20px filling frame, volcano-like smoke 15px, shockwave ring expanding, viewBox='0 0 64 64', SVG.

### 酒馆 (Tavern) - 随机单位建筑
29. **Tavern Lv1 Frame 1 (Idle)**: Clean vector pixel art 64x64 tavern Lv1 Frame 1 idle: military mess hall tent with swinging sign, lanterns glowing, army green canvas, viewBox='0 0 64 64', SVG.
30. **Tavern Lv1 Frame 2 (Random Summon)**: Clean vector pixel art 64x64 tavern Lv1 Frame 2 summon: sign spinning 360°, magical recruitment glow expanding 12px from door, random unit shadow materializing, lantern flares with spark particles, viewBox='0 0 64 64', SVG.
31. **Tavern Lv2 Frame 1 (Idle)**: Clean vector pixel art 64x64 tavern Lv2 Frame 1 idle (scale 1.3x): expanded military canteen building with neon signs, multiple entrances, enhanced recruitment center, viewBox='0 0 64 64', SVG.
32. **Tavern Lv2 Frame 2 (Random Summon)**: Clean vector pixel art 64x64 tavern Lv2 Frame 2 summon: signs swirling in formation, larger recruitment portal 15px with energy vortex, unit materializing with confetti particles, building shaking with power, viewBox='0 0 64 64', SVG.
33. **Tavern Lv3 Frame 1 (Idle)**: Clean vector pixel art 64x64 tavern Lv3 Frame 1 idle (scale 1.6x, mystic glow): legendary war heroes hall fortress, grand archways, mystical recruitment runes glowing, viewBox='0 0 64 64', SVG.
34. **Tavern Lv3 Frame 2 (Random Summon)**: Clean vector pixel art 64x64 tavern Lv3 Frame 2 summon: fortress gates phasing open 20°, massive recruitment rift 20px spinning with legendary particles, epic hero unit descending with beam light, ground cracking effects, viewBox='0 0 64 64', SVG.

## ⚔️ 3. 单位 (5种 × 3级 = 15种，16x32陆军/24x16海军空军 SVG，2帧：走/攻)

### 步兵 (Infantry) - 近战肉盾
35. **Infantry Lv1 Frame 1 (Walk)**: Clean vector pixel art 16x32 infantry Lv1 Frame 1 walk: basic soldier with AK-47, marching step forward, dust trail 3px, side military view, army green uniform, viewBox='0 0 16 32', SVG.
36. **Infantry Lv1 Frame 2 (Attack)**: Clean vector pixel art 16x32 infantry Lv1 Frame 2 attack: rifle firing recoil, muzzle flash 5px, bullet tracers forward 8px, soldier stance firm, viewBox='0 0 16 32', SVG.
37. **Infantry Lv2 Frame 1 (Walk)**: Clean vector pixel art 16x32 infantry Lv2 Frame 1 walk (scale 1.3x): heavy armored soldier with machine gun, confident stride, enhanced armor plating, viewBox='0 0 16 32', SVG.
38. **Infantry Lv2 Frame 2 (Attack)**: Clean vector pixel art 16x32 infantry Lv2 Frame 2 attack: sustained burst fire, multiple tracers 12px, shell casings ejecting, armored stance, viewBox='0 0 16 32', SVG.
39. **Infantry Lv3 Frame 1 (Walk)**: Clean vector pixel art 16x32 infantry Lv3 Frame 1 walk (scale 1.6x): elite super soldier with rocket launcher, powered armor glow, massive presence, viewBox='0 0 16 32', SVG.
40. **Infantry Lv3 Frame 2 (Attack)**: Clean vector pixel art 16x32 infantry Lv3 Frame 2 attack: rocket launch with backblast 10px, explosion trail 15px, ground crater forming, heroic pose, viewBox='0 0 16 32', SVG.

### 坦克 (Tank) - 重型远程火力
41. **Tank Lv1 Frame 1 (Move)**: Clean vector pixel art 16x32 tank Lv1 Frame 1 move: light reconnaissance tank advancing, treads rolling, dust clouds 4px, military green armor, viewBox='0 0 16 32', SVG.
42. **Tank Lv1 Frame 2 (Fire)**: Clean vector pixel art 16x32 tank Lv1 Frame 2 fire: main gun barrel flash 8px, shell trajectory line forward 12px, recoil shake 3px, viewBox='0 0 16 32', SVG.
43. **Tank Lv2 Frame 1 (Move)**: Clean vector pixel art 16x32 tank Lv2 Frame 1 move (scale 1.3x): medium battle tank with enhanced armor, dual exhaust smoke, imposing advance, viewBox='0 0 16 32', SVG.
44. **Tank Lv2 Frame 2 (Fire)**: Clean vector pixel art 16x32 tank Lv2 Frame 2 fire: twin gun salvo, double flash 10px, intersecting shell trails, enhanced recoil effects, viewBox='0 0 16 32', SVG.
45. **Tank Lv3 Frame 1 (Move)**: Clean vector pixel art 16x32 tank Lv3 Frame 1 move (scale 1.6x): super heavy tank fortress, reactive armor panels glowing, massive treads crushing terrain, viewBox='0 0 16 32', SVG.
46. **Tank Lv3 Frame 2 (Fire)**: Clean vector pixel art 16x32 tank Lv3 Frame 2 fire: main battery barrage, screen-filling flash 15px, multiple shell arcs with explosion anticipation, earth-shaking recoil, viewBox='0 0 16 32', SVG.

### 火炮 (Artillery) - 远程群伤
47. **Artillery Lv1 Frame 1 (Position)**: Clean vector pixel art 16x32 artillery Lv1 Frame 1 position: light mobile mortar team, cannon aimed, crew positioning, military deployment, viewBox='0 0 16 32', SVG.
48. **Artillery Lv1 Frame 2 (Bombard)**: Clean vector pixel art 16x32 artillery Lv1 Frame 2 bombard: mortar tube firing upward, shell arc trajectory 10px high, impact explosion 6px radius, viewBox='0 0 16 32', SVG.
49. **Artillery Lv2 Frame 1 (Position)**: Clean vector pixel art 16x32 artillery Lv2 Frame 1 position (scale 1.3x): self-propelled howitzer, elevated barrel, armored cabin, tactical positioning, viewBox='0 0 16 32', SVG.
50. **Artillery Lv2 Frame 2 (Bombard)**: Clean vector pixel art 16x32 artillery Lv2 Frame 2 bombard: high-angle fire, shell with smoke trail arcing 15px, ground burst 8px with shrapnel, viewBox='0 0 16 32', SVG.
51. **Artillery Lv3 Frame 1 (Position)**: Clean vector pixel art 16x32 artillery Lv3 Frame 1 position (scale 1.6x): railway siege gun, massive reinforced barrel, fortress-like base, apocalyptic firepower, viewBox='0 0 16 32', SVG.
52. **Artillery Lv3 Frame 2 (Bombard)**: Clean vector pixel art 16x32 artillery Lv3 Frame 2 bombard: orbital bombardment simulation, shell with mushroom cloud trail 20px, massive crater 12px, shockwave rings expanding, viewBox='0 0 16 32', SVG.

### 海兵 (Marines) - 水路突击，水域专家
53. **Marine Lv1 Frame 1 (Move)**: Clean vector pixel art 24x16 marine Lv1 Frame 1 move: speedboat with soldiers, water wake trail 4px, naval assault craft, blue/gray military colors, viewBox='0 0 24 16', SVG.
54. **Marine Lv1 Frame 2 (Attack)**: Clean vector pixel art 24x16 marine Lv1 Frame 2 attack: boat-mounted gun firing, muzzle flash 6px, bullet tracers over water, amphibious assault, viewBox='0 0 24 16', SVG.
55. **Marine Lv2 Frame 1 (Move)**: Clean vector pixel art 24x16 marine Lv2 Frame 1 move (scale 1.3x): patrol boat with heavy armament, radar spinning, enhanced naval presence, viewBox='0 0 24 16', SVG.
56. **Marine Lv2 Frame 2 (Attack)**: Clean vector pixel art 24x16 marine Lv2 Frame 2 attack: naval cannon barrage, shell splashes in water, explosive impacts, coastal bombardment, viewBox='0 0 24 16', SVG.
57. **Marine Lv3 Frame 1 (Move)**: Clean vector pixel art 24x16 marine Lv3 Frame 1 move (scale 1.6x): destroyer-class warship, massive wake, missile launchers ready, naval supremacy, viewBox='0 0 24 16', SVG.
58. **Marine Lv3 Frame 2 (Attack)**: Clean vector pixel art 24x16 marine Lv3 Frame 2 attack: missile launch with smoke trails, explosion sequence over target area, ship rocking from recoil, viewBox='0 0 24 16', SVG.

### 空军 (Air Force) - 空中优势，无视地形
59. **Air Force Lv1 Frame 1 (Fly)**: Clean vector pixel art 24x16 air force Lv1 Frame 1 fly: fighter jet in flight, contrails 8px, high-speed aerial combat, silver/gray military aircraft, viewBox='0 0 24 16', SVG.
60. **Air Force Lv1 Frame 2 (Attack)**: Clean vector pixel art 24x16 air force Lv1 Frame 2 attack: machine gun strafing, bullet tracers downward 10px, aerial gunfire pattern, dogfighting maneuvers, viewBox='0 0 24 16', SVG.
61. **Air Force Lv2 Frame 1 (Fly)**: Clean vector pixel art 24x16 air force Lv2 Frame 1 fly (scale 1.3x): bomber aircraft, heavy payload visible, strategic bombing run, enhanced wingspan, viewBox='0 0 24 16', SVG.
62. **Air Force Lv2 Frame 2 (Attack)**: Clean vector pixel art 24x16 air force Lv2 Frame 2 attack: bomb drop sequence, explosives falling with trails, ground impact anticipation, tactical strike, viewBox='0 0 24 16', SVG.
63. **Air Force Lv3 Frame 1 (Fly)**: Clean vector pixel art 24x16 air force Lv3 Frame 1 fly (scale 1.6x): advanced fighter-bomber, missile pods loaded, supersonic contrails, air superiority fighter, viewBox='0 0 24 16', SVG.
64. **Air Force Lv3 Frame 2 (Attack)**: Clean vector pixel art 24x16 air force Lv3 Frame 2 attack: missile salvo launch, multiple trails converging on target, explosion cloud formation, precision strike, viewBox='0 0 24 16', SVG.

## 🏰 4. 敌方防御塔 (4种，64x64 SVG，2帧动画：Idle/Attack)

53. **Defense Cannon Tower Frame 1 (Idle)**: Clean vector pixel art 64x64 defense cannon tower Frame 1 idle: military bunker with rotating turret, reinforced concrete walls, red warning lights, army green/gray, viewBox='0 0 64 64', SVG.
54. **Defense Cannon Tower Frame 2 (Attack)**: Clean vector pixel art 64x64 defense cannon tower Frame 2 attack: turret barrel flash 12px, shell trajectory line forward 15px, recoil shake 5px, smoke cloud rising 8px, viewBox='0 0 64 64', SVG.
55. **Tank Bunker Frame 1 (Idle)**: Clean vector pixel art 64x64 tank bunker Frame 1 idle (scale 1.2x): armored fortress with multiple gun ports, heavy steel doors, defensive emplacements, olive drab armor, viewBox='0 0 64 64', SVG.
56. **Tank Bunker Frame 2 (Attack)**: Clean vector pixel art 64x64 tank bunker Frame 2 attack: simultaneous gun port flashes 8px each, intersecting shell trails, bunker trembling with firepower, viewBox='0 0 64 64', SVG.
57. **Drone Hive Frame 1 (Idle)**: Clean vector pixel art 64x64 drone hive Frame 1 idle: mechanical nest with antenna arrays, glowing energy cores, automated defense systems, metallic blue/gray, viewBox='0 0 64 64', SVG.
58. **Drone Hive Frame 2 (Attack)**: Clean vector pixel art 64x64 drone hive Frame 2 attack: energy beams firing 10px, drone launch portals opening with particle effects, hive pulsing with power, viewBox='0 0 64 64', SVG.
59. **Beast Citadel Frame 1 (Idle)**: Clean vector pixel art 64x64 beast citadel Frame 1 idle (scale 1.4x): monstrous fortress with organic armor plating, glowing red eyes, alien defense structure, dark purple/black, viewBox='0 0 64 64', SVG.
60. **Beast Citadel Frame 2 (Attack)**: Clean vector pixel art 64x64 beast citadel Frame 2 attack: massive energy blast 15px, tentacle-like weapons extending, ground cracking effects, apocalyptic power, viewBox='0 0 64 64', SVG.

## 🎮 5. UI元素 (14种，128x128 SVG，静态)

65. **Gold Coin Icon**: Clean vector pixel art 128x128 military gold coin icon, eagle and stars, subtle rotation, game currency, viewBox='0 0 128 128', SVG.
66. **Shop Button**: Clean vector pixel art 128x128 military supply shop button, crates and weapons, pressed state ready, viewBox='0 0 128 128', SVG.
67. **Relic Speed Icon**: Clean vector pixel art 128x128 speed boot relic, lightning effects, military enhancement, viewBox='0 0 128 128', SVG.
68. **Relic Damage Icon**: Clean vector pixel art 128x128 damage fist relic, explosion particles, combat power-up, viewBox='0 0 128 128', SVG.
69. **Relic Gold Icon**: Clean vector pixel art 128x128 gold magnet relic, coin attraction field, economy boost, viewBox='0 0 128 128', SVG.
70. **Relic Merge Icon**: Clean vector pixel art 128x128 merge hammer relic, fusion energy, upgrade catalyst, viewBox='0 0 128 128', SVG.
71. **Speed Button**: Clean vector pixel art 128x128 game speed control button, fast forward arrows, military stopwatch, tactical acceleration, viewBox='0 0 128 128', SVG.
72. **Remove Building Icon**: Clean vector pixel art 128x128 building removal tool icon, demolition hammer, refund coins, construction management, viewBox='0 0 128 128', SVG.
73. **Pause Button**: Clean vector pixel art 128x128 military pause button, crossed rifles, tactical halt, viewBox='0 0 128 128', SVG.
74. **Victory Banner**: Clean vector pixel art 128x128 victory flag icon, stars and stripes, mission accomplished, viewBox='0 0 128 128', SVG.
75. **Tower Health Bar Frame**: Clean vector pixel art 128x128 enemy tower health bar frame, military targeting reticle, damage indicators, viewBox='0 0 128 128', SVG.
76. **Map Expansion Icon**: Clean vector pixel art 128x128 map expansion unlock icon, unfolding battlefield, strategic advancement, viewBox='0 0 128 128', SVG.
77. **Tower Destroy Progress**: Clean vector pixel art 128x128 tower destruction progress indicator, crumbling fortress, victory meter, viewBox='0 0 128 128', SVG.
78. **Base Defense Alert**: Clean vector pixel art 128x128 base under attack alert, warning siren, defensive perimeter, viewBox='0 0 128 128', SVG.

## 📝 生成使用指南

1. **批量生成**：使用Leonardo.ai的批量Prompt功能，一次生成多个资源
2. **动画导入**：Godot中将Frame 1/2导入为AnimatedSprite2D，设置0.1s切换
3. **压缩优化**：所有SVG用SVGOMG压缩，目标<1KB/文件，总计<500KB
4. **风格一致性**：确保所有资源使用统一的军绿色/棕色/灰色调色板
5. **测试导入**：生成后立即在Godot中测试动画流畅度和视觉效果

**总资源清单**：11 Tiles + 12建筑 + 15单位 + 8敌方防御塔 + 14UI = 60个SVG文件

使用这些Prompt，AI将自动生成符合游戏军事主题的完整美术资源！🚀