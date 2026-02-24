  ---
  # 🚨 必读文档 - 每次开发前必须阅读
  ## ⚠️ IMPORTANT: READ BEFORE EVERY DEVELOPMENT SESSION
  ---

  > **🔴 开发必读**：每次开始开发前，请务必阅读此完整游戏设计文档(GDD)。
  > 本文档定义了游戏的核心玩法、美术规范和技术实现方案。
  > 任何代码变更必须符合此文档规范。

  ```markdown
  # 《陆地军事塔防》（Land Military TD）完整游戏设计文档 (GDD) & 开发规范 Prompt

  ## 🎮 游戏概述
  - **类型**：像素风2D Roguelike塔防 + 单位合并（融合War Sea合并机制 + 动态地图扩展 + 建筑摧毁机制）。
  - **平台**：抖音小游戏（HTML5导出，主包≤4MB，整体≤20MB，分包优化）。
  - **引擎**：Godot 4.6.1（HTML5 + 抖音开发者工具一键发布）。
  - **目标**：单局3-8分钟碎片时间，竖屏移动端，爽快合并推土机。高重玩：Roguelike遗物+地图随机生成。
  - **主题**：现代军事陆地战场。玩家指挥人类军队（步兵/坦克/火炮），建造基地摧毁敌方防御塔（机器人/外星入侵）。
  - **核心卖点**：拖拽相同建筑瞬间合并升级（Lv1兵营x2→Lv2兵营→产Lv2重装），建筑自动产兵/金，海量单位自动推进战斗。后期画面挤满坦克弹幕！地图可无限扩展，战略纵深丰富！
  - **模式**：建筑摧毁模式（摧毁敌方基地通关），3指挥官切换（均衡/速产/火力）。
  - **变现**：IAA插屏广告（阶段通关/建筑摧毁）。

  ## ⚙️ 核心玩法循环（30秒上手）
  1. **动态地图建造**：初始2x8网格（两排土地），可购买扩展新土地行。拖拽放置4种建筑，支持右键移除：
    | 建筑 | 功能 | 价格 | 相邻Buff | 移除成本 |
    |------|------|------|----------|----------|
    | 金矿 | 自动产金 | 50 | +20%产出 | 30 |
    | 兵营 | 自动产Lv1步兵 | 100 | +单位速度 | 60 |
    | 炮台 | 远程固定射击 | 150 | +射程 | 90 |
    | 酒馆 | 随机单位 | 200 | +合并率 | 120 |
  2. **资源&商店**：金币买单位/升级商店。建筑联动buff。
  3. **建筑合并**（War Sea核心爽点）：拖拽相同类型+等级建筑叠加→瞬间升级（视觉爆炸+scale 1.5x）。升级后建筑产出更高等级兵种（Lv2兵营→Lv2重装步兵，属性x2）。
  4. **自动战斗**：建筑自动产兵，单位有视野机制，视野内发现敌人/建筑自动移动攻击。从下往上进攻模式。
  5. **地图扩展&Roguelike**：摧毁敌方建筑解锁新地图区域→选1/3遗物（+金/伤害/合并速）。失败=基地被摧毁。
  - **单位5类×3Lv**（克制：步兵克炮、海兵克空军、坦克克步、炮克坦、空军无视地形）：
    | Lv1 | Lv2 | Lv3 | 作用 |
    |-----|-----|-----|------|
    | 步兵（AK枪，快脆） | 重装（机枪，抗打） | 火箭兵（AOE） | 肉盾/清群 |
    | 轻坦（单炮，机动） | 中坦（双炮） | 重坦（三管，碾压） | 远程主力 |
    | 轻炮（榴弹，小AOE） | 加农（穿甲） | 火箭车（全屏轰） | 群控 |
    | 海兵（冲锋舟，速攻） | 巡逻艇（舰炮） | 驱逐舰（导弹） | 水路主力 |
    | 战斗机（机枪，高速） | 轰炸机（炸弹） | 歼击机（导弹） | 空中优势 |
  - **敌人**：4种防御塔类型（步兵塔/坦克塔/无人机塔/巨兽塔），可被摧毁解锁地图扩展。

  ## 🎨 美术&动画规范（AI生成SVG矢量，<1MB总资源）
  - **风格**：16-bit像素艺术（flat colors: 绿/棕/灰/橙军绿色调），sharp vector edges（SVGOMG压缩<1KB/张）。
  - **尺寸**：Tile 32x32；建筑64x64；单位16x32（陆军）/24x16（海军/空军）；UI 128x128。
  - **动画**：2帧逐帧（Godot AnimatedSprite2D，0.1s切换）：
    - Frame1: Idle（微动如旗飘/蒸汽）。
    - Frame2: Action（射击/产兵：recoil 5px + 粒子路径，如炮口闪10px烟雾8px）。
  - **AI Prompt模板**（复制用Leonardo.ai/Ideogram，--ar 1:1 --v6）：
    ```
    Clean vector pixel art [尺寸] [类型]Lv[级] Frame[1/2] ([Idle/Action]): [详细描述，如"步兵Lv1 Frame2: sword arcs 10px slash, impact stars 4 bursts"] 16-bit military retro, flat army greens/browns, sharp edges, viewBox='0 0 [W H]', separate SVG layers.
    ```
  - **资源清单**：10 Tiles + 12建筑(4x3) + 18单位(3x3x2帧) + 8敌方防御塔(4x2帧) + 12UI(包含建筑血条/摧毁进度) = ~80 SVG。

  ## 🛠️ 技术&开发规范（Godot单场景，MVP 1周）

  ### ⚙️ 配置系统规范
  > **🔧 配置管理**：所有游戏固定值（建筑造价、单位属性、波次难度、遗物效果等）必须在 `game/config/game_config.json` 中配置。
  >
  > **📝 配置原则**：
  > - 禁止在代码中硬编码数值
  > - 平衡调整只需修改 JSON，无需改代码
  > - 配置项分类：grid/economy/buildings/units/enemies/combat/battlefield/waves/relics/commanders
  > - 数值验证：启动时加载并校验配置完整性

  - **节点结构**：
    ```
    Main (Node2D, CanvasLayer UI)
    ├── Camera2D (地图拖拽相机)
    ├── DynamicGrid (TileMapLayer 可扩展, 90度旋转)
    ├── BuildingPool (40体，可扩展)
    ├── UnitPool (200体, 对象池+MultiMesh)
    ├── EnemyTowerPool (敌方防御塔管理)
    ├── TerrainManager (地形系统:河流/桥/水域)
    ├── MapExpansionManager (地图扩展控制器)
    └── UILayer (金币/商店/遗物弹窗/建筑血条/加速按钮)
    ```
  - **脚本**：GDScript（TreeShake瘦身）。触控拖拽（InputEventScreenDrag）。性能：60FPS低端，单位上限200。
  - **优化**：
    | 目标 | 技巧 |
    |------|------|
    | <4MB主包 | PNGQuant/SVGOMG + 分包（资源分主/UI） |
    | 加载<2s | 懒载波次 |
    | 移动适配 | TouchScreenButton + UI Scale |
  - **开发计划**（12天）：
    | 天 | 任务 |
    |----|------|
    | 1 | 项目+DynamicGrid拖拽 |
    | 2-3 | 建筑/合并/战斗 |
    | 4 | 敌方防御塔+建筑摧毁 |
    | 5 | 地图扩展系统+遗物 |
    | 6 | 美术导入+动画 |
    | 7 | 优化+真机 |
    | 8 | HTML5分包+抖音工具 |
    | 9-12 | 提审上线 |
  - **导出**：HTML5 (Zstd PCK, no threads/physics)。抖音：自审“无敏感，无赌”。

  ## 🚀 AI开发指令
  - **生成代码**：基于此GDD，输出完整Godot项目.zip（Main.tscn + 13 GDScript: ConfigManager/GameManager/DynamicGridManager/MapExpansionManager/EnemyTowerManager/Unit/Building/Battlefield/HUD/ShopPanel/RelicPopup/CommanderPanel等）。
  - **配置系统**：所有固定值必须从 `game/config/game_config.json` 读取，禁止硬编码。使用 Cfg Autoload 单例访问配置。
  - **生成美术**：用80 Prompt批量SVG（Aseprite导入SpriteFrames），新增敌方防御塔美术。
  - **平衡**：Excel: Lv伤害x2，防御塔血量=tower_level*200，地图扩展解锁金币奖励=expansion_level*100，遗物+20-50%，视野范围=单位类型*base_range，加速倍率=2x，移除返还=建造成本*0.6。
  - **测试**：摧毁5个敌方建筑通关<8min，合并特效爆炸粒子（Godot GPUParticles2D），视野机制正常，地形阻挡生效，加速暂停功能正常。

  **复制此Prompt到AI，即可自动开发/生成资源！** 目标：抖音爆款，月入过万。开始吧！🚀

  **📋 更新日志**：
  - ✅ 移除波次系统，改为建筑摧毁机制
  - ✅ 地图可动态扩展，无限向右延伸
  - ✅ 敌方改为固定防御塔，可被摧毁
  - ✅ 胜利条件：摧毁指定数量敌方建筑
  - ✅ 初始土地改为两排，后续需购买扩展
  - ✅ 单位添加视野机制，自动发现并攻击
  - ✅ 地图旋转90度，从下往上进攻模式
  - ✅ 添加建筑移除功能
  - ✅ 游戏加速功能，选择遗物时暂停
  - ✅ 多兵种系统：步兵/坦克/火炮/海兵/空军
  - ✅ 地形系统：河流阻挡，桥梁通行，水域建设海兵
  - ✅ UI更新：建筑血条、摧毁进度显示
  ```

  **使用方法**：直接复制以上全文到ChatGPT/Claude/Grok，输入“基于此GDD生成[代码/美术/平衡表]”，AI秒懂全盘！需调整？告诉我~