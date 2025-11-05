local RecipeDatabase = {}

RecipeDatabase.AllRecipes = {
	-- Weapons
	{
		id = "wooden_spear",
		name = "Wooden Spear",
		category = "Weapons",
		requiredItems = {
			{item = "Stick", amount = 2},
			{item = "Cloth Strip", amount = 1},
			{item = "Knife", amount = 1, tool = true},
		},
		outputItem = {item = "Wooden Spear", amount = 1},
		station = "None",
	},
	{
		id = "barbed_bat",
		name = "Barbed Bat",
		category = "Weapons",
		requiredItems = {
			{item = "Wooden Plank", amount = 1},
			{item = "Nails", amount = 5},
			{item = "Duct Tape", amount = 1},
		},
		outputItem = {item = "Barbed Bat", amount = 1},
		station = "Workbench",
	},
	{
		id = "makeshift_knife",
		name = "Makeshift Knife",
		category = "Weapons",
		requiredItems = {
			{item = "Scrap Metal", amount = 1},
			{item = "Cloth Strip", amount = 1},
			{item = "Sharp Rock", amount = 1},
		},
		outputItem = {item = "Makeshift Knife", amount = 1},
		station = "Campfire",
	},
	{
		id = "shank",
		name = "Shank",
		category = "Weapons",
		requiredItems = {
			{item = "Scrap Metal", amount = 1},
			{item = "Duct Tape", amount = 1},
		},
		outputItem = {item = "Shank", amount = 1},
		station = "None",
	},
	{
		id = "pipe_wrench_club",
		name = "Pipe Wrench Club",
		category = "Weapons",
		requiredItems = {
			{item = "Wrench", amount = 1},
			{item = "Duct Tape", amount = 1},
			{item = "Nails", amount = 2},
		},
		outputItem = {item = "Pipe Wrench Club", amount = 1},
		station = "None",
	},
	{
		id = "nail_gun",
		name = "Nail Gun",
		category = "Weapons",
		requiredItems = {
			{item = "Scrap Metal", amount = 2},
			{item = "Wires", amount = 1},
			{item = "Battery", amount = 1},
		},
		outputItem = {item = "Nail Gun", amount = 1},
		station = "Electronics Table",
	},
	{
		id = "reinforced_axe",
		name = "Reinforced Axe",
		category = "Weapons",
		requiredItems = {
			{item = "Hatchet", amount = 1},
			{item = "Scrap Metal", amount = 2},
			{item = "Rope", amount = 1},
		},
		outputItem = {item = "Reinforced Axe", amount = 1},
		station = "Workbench",
	},
	{
		id = "crossbow",
		name = "Crossbow",
		category = "Weapons",
		requiredItems = {
			{item = "Stick", amount = 3},
			{item = "Rope", amount = 1},
			{item = "Scrap Metal", amount = 1},
			{item = "Screwdriver", amount = 1, tool = true},
		},
		outputItem = {item = "Crossbow", amount = 1},
		station = "Workbench",
	},
	{
		id = "bow",
		name = "Bow",
		category = "Weapons",
		requiredItems = {
			{item = "Stick", amount = 2},
			{item = "Rope", amount = 1},
			{item = "Knife", amount = 1, tool = true},
		},
		outputItem = {item = "Bow", amount = 1},
		station = "Workbench",
	},
	{
		id = "arrows",
		name = "Arrows (x5)",
		category = "Weapons",
		requiredItems = {
			{item = "Stick", amount = 1},
			{item = "Sharp Rock", amount = 1},
			{item = "Feather", amount = 2},
		},
		outputItem = {item = "Arrow", amount = 5},
		station = "Workbench",
	},
	{
		id = "scrap_blade",
		name = "Scrap Blade",
		category = "Weapons",
		requiredItems = {
			{item = "Scrap Metal", amount = 2},
			{item = "Cloth", amount = 1},
			{item = "Tape", amount = 1},
		},
		outputItem = {item = "Scrap Blade", amount = 1},
		station = "Workbench",
	},
	{
		id = "fire_arrow",
		name = "Fire Arrow",
		category = "Weapons",
		requiredItems = {
			{item = "Arrow", amount = 1},
			{item = "Cloth Strip", amount = 1},
			{item = "Oil", amount = 1},
		},
		outputItem = {item = "Fire Arrow", amount = 1},
		station = "Campfire",
	},
	{
		id = "poison_arrow",
		name = "Poison Arrow",
		category = "Weapons",
		requiredItems = {
			{item = "Arrow", amount = 1},
			{item = "Poison Herb", amount = 1},
		},
		outputItem = {item = "Poison Arrow", amount = 1},
		station = "Workbench",
	},

	-- Gear & Armor
	{
		id = "cloth_wraps",
		name = "Cloth Wraps",
		category = "Armor",
		requiredItems = {
			{item = "Cloth Strip", amount = 3},
		},
		outputItem = {item = "Cloth Wraps", amount = 1},
		station = "None",
	},
	{
		id = "leather_vest",
		name = "Leather Vest",
		category = "Armor",
		requiredItems = {
			{item = "Leather", amount = 2},
			{item = "Cloth", amount = 1},
			{item = "Needle & Thread", amount = 1, tool = true},
		},
		outputItem = {item = "Leather Vest", amount = 1},
		station = "Workbench",
	},
	{
		id = "scrap_metal_pads",
		name = "Scrap Metal Pads",
		category = "Armor",
		requiredItems = {
			{item = "Scrap Metal", amount = 2},
			{item = "Duct Tape", amount = 1},
			{item = "Cloth", amount = 1},
		},
		outputItem = {item = "Scrap Metal Pads", amount = 1},
		station = "Workbench",
	},
	{
		id = "riot_helmet",
		name = "Riot Helmet",
		category = "Armor",
		requiredItems = {
			{item = "Scrap Metal", amount = 2},
			{item = "Padding", amount = 1},
			{item = "Rope", amount = 1},
		},
		outputItem = {item = "Riot Helmet", amount = 1},
		station = "Workbench",
	},
	{
		id = "tactical_backpack",
		name = "Tactical Backpack",
		category = "Armor",
		requiredItems = {
			{item = "Cloth", amount = 2},
			{item = "Leather", amount = 1},
			{item = "Rope", amount = 1},
			{item = "Buckle", amount = 1},
		},
		outputItem = {item = "Tactical Backpack", amount = 1},
		station = "Sewing Station",
	},
	{
		id = "tool_belt",
		name = "Tool Belt",
		category = "Armor",
		requiredItems = {
			{item = "Leather", amount = 1},
			{item = "Buckle", amount = 1},
			{item = "Rope", amount = 1},
		},
		outputItem = {item = "Tool Belt", amount = 1},
		station = "Sewing Station",
	},
	{
		id = "gas_mask",
		name = "Gas Mask",
		category = "Armor",
		requiredItems = {
			{item = "Plastic", amount = 2},
			{item = "Filter", amount = 1},
			{item = "Rubber Tubes", amount = 1},
		},
		outputItem = {item = "Gas Mask", amount = 1},
		station = "Electronics Table",
	},
	{
		id = "hazmat_gloves",
		name = "Hazmat Gloves",
		category = "Armor",
		requiredItems = {
			{item = "Rubber", amount = 2},
			{item = "Duct Tape", amount = 1},
		},
		outputItem = {item = "Hazmat Gloves", amount = 1},
		station = "Workbench",
	},
	{
		id = "military_vest",
		name = "Military Vest",
		category = "Armor",
		requiredItems = {
			{item = "Cloth", amount = 2},
			{item = "Scrap Metal", amount = 1},
			{item = "Straps", amount = 1},
		},
		outputItem = {item = "Military Vest", amount = 1},
		station = "Workbench",
	},
	{
		id = "scrap_shield",
		name = "Scrap Shield",
		category = "Armor",
		requiredItems = {
			{item = "Scrap Metal", amount = 3},
			{item = "Wood Plank", amount = 1},
			{item = "Rope", amount = 1},
		},
		outputItem = {item = "Scrap Shield", amount = 1},
		station = "Workbench",
	},

	-- Cooking & Food
	{
		id = "cooked_meat",
		name = "Cooked Meat",
		category = "Cooking",
		requiredItems = {
			{item = "Raw Meat", amount = 1},
		},
		outputItem = {item = "Cooked Meat", amount = 1},
		station = "Campfire",
	},
	{
		id = "grilled_fish",
		name = "Grilled Fish",
		category = "Cooking",
		requiredItems = {
			{item = "Raw Fish", amount = 1},
		},
		outputItem = {item = "Grilled Fish", amount = 1},
		station = "Campfire",
	},
	{
		id = "stew_pot",
		name = "Stew Pot",
		category = "Cooking",
		requiredItems = {
			{item = "Cooked Meat", amount = 1},
			{item = "Water", amount = 1},
			{item = "Veggie", amount = 1},
		},
		outputItem = {item = "Stew Pot", amount = 1},
		station = "Cooking Pot + Campfire",
	},
	{
		id = "salted_meat",
		name = "Salted Meat",
		category = "Cooking",
		requiredItems = {
			{item = "Raw Meat", amount = 1},
			{item = "Salt", amount = 1},
		},
		outputItem = {item = "Salted Meat", amount = 1},
		station = "Drying Rack",
	},
	{
		id = "water_bottle",
		name = "Water Bottle",
		category = "Cooking",
		requiredItems = {
			{item = "Clean Water", amount = 1},
			{item = "Empty Bottle", amount = 1},
		},
		outputItem = {item = "Water Bottle", amount = 1},
		station = "Water Collector",
	},
	{
		id = "water_jug",
		name = "Water Jug",
		category = "Cooking",
		requiredItems = {
			{item = "Clean Water", amount = 4},
			{item = "Jug", amount = 1},
		},
		outputItem = {item = "Water Jug", amount = 1},
		station = "Water Collector",
	},
	{
		id = "charcoal",
		name = "Charcoal",
		category = "Cooking",
		requiredItems = {
			{item = "Burned Wood", amount = 2},
		},
		outputItem = {item = "Charcoal", amount = 1},
		station = "Campfire",
	},
	{
		id = "purified_water",
		name = "Purified Water",
		category = "Cooking",
		requiredItems = {
			{item = "Dirty Water", amount = 1},
		},
		outputItem = {item = "Purified Water", amount = 1},
		station = "Water Purifier",
	},

	-- Structures & Building
	{
		id = "wooden_wall",
		name = "Wooden Wall",
		category = "Structures",
		requiredItems = {
			{item = "Plank", amount = 3},
			{item = "Nails", amount = 2},
			{item = "Hammer", amount = 1, tool = true},
		},
		outputItem = {item = "Wooden Wall", amount = 1},
		station = "Workbench",
	},
	{
		id = "wooden_door",
		name = "Wooden Door",
		category = "Structures",
		requiredItems = {
			{item = "Plank", amount = 4},
			{item = "Hinges", amount = 2},
			{item = "Nails", amount = 4},
		},
		outputItem = {item = "Wooden Door", amount = 1},
		station = "Workbench",
	},
	{
		id = "metal_door",
		name = "Metal Door",
		category = "Structures",
		requiredItems = {
			{item = "Scrap Metal", amount = 3},
			{item = "Hinges", amount = 2},
			{item = "Welding Tool", amount = 1, tool = true},
		},
		outputItem = {item = "Metal Door", amount = 1},
		station = "Welding Station",
	},
	{
		id = "spiked_barricade",
		name = "Spiked Barricade",
		category = "Structures",
		requiredItems = {
			{item = "Wood Plank", amount = 2},
			{item = "Nails", amount = 5},
			{item = "Rope", amount = 1},
		},
		outputItem = {item = "Spiked Barricade", amount = 1},
		station = "Workbench",
	},
	{
		id = "storage_crate",
		name = "Storage Crate",
		category = "Structures",
		requiredItems = {
			{item = "Wood Plank", amount = 3},
			{item = "Nails", amount = 2},
		},
		outputItem = {item = "Storage Crate", amount = 1},
		station = "Workbench",
	},
	{
		id = "watchtower",
		name = "Watchtower",
		category = "Structures",
		requiredItems = {
			{item = "Plank", amount = 8},
			{item = "Nails", amount = 6},
			{item = "Rope", amount = 2},
		},
		outputItem = {item = "Watchtower", amount = 1},
		station = "Construction Station",
	},
	{
		id = "fence_section",
		name = "Fence Section",
		category = "Structures",
		requiredItems = {
			{item = "Stick", amount = 3},
			{item = "Rope", amount = 1},
		},
		outputItem = {item = "Fence Section", amount = 1},
		station = "None",
	},
	{
		id = "hatch_trapdoor",
		name = "Hatch/Trapdoor",
		category = "Structures",
		requiredItems = {
			{item = "Plank", amount = 2},
			{item = "Hinges", amount = 2},
		},
		outputItem = {item = "Trapdoor", amount = 1},
		station = "Workbench",
	},
	{
		id = "metal_sheet_wall",
		name = "Metal Sheet Wall",
		category = "Structures",
		requiredItems = {
			{item = "Scrap Metal", amount = 4},
			{item = "Welding Rods", amount = 2},
		},
		outputItem = {item = "Metal Sheet Wall", amount = 1},
		station = "Welding Station",
	},
	{
		id = "campfire_pit",
		name = "Campfire Pit",
		category = "Structures",
		requiredItems = {
			{item = "Rocks", amount = 5},
			{item = "Stick", amount = 2},
			{item = "Matches", amount = 1},
		},
		outputItem = {item = "Campfire Pit", amount = 1},
		station = "None",
	},
	{
		id = "window_boards",
		name = "Window Boards",
		category = "Structures",
		requiredItems = {
			{item = "Plank", amount = 2},
			{item = "Nails", amount = 4},
		},
		outputItem = {item = "Window Boards", amount = 1},
		station = "None",
	},

	-- Tools & Utilities
	{
		id = "hammer",
		name = "Hammer",
		category = "Tools",
		requiredItems = {
			{item = "Stick", amount = 1},
			{item = "Scrap Metal", amount = 1},
		},
		outputItem = {item = "Hammer", amount = 1},
		station = "Workbench",
	},
	{
		id = "saw",
		name = "Saw",
		category = "Tools",
		requiredItems = {
			{item = "Scrap Metal", amount = 1},
			{item = "Stick", amount = 1},
		},
		outputItem = {item = "Saw", amount = 1},
		station = "Workbench",
	},
	{
		id = "screwdriver",
		name = "Screwdriver",
		category = "Tools",
		requiredItems = {
			{item = "Scrap Metal", amount = 1},
			{item = "Plastic", amount = 1},
		},
		outputItem = {item = "Screwdriver", amount = 1},
		station = "Workbench",
	},
	{
		id = "flashlight",
		name = "Flashlight",
		category = "Tools",
		requiredItems = {
			{item = "Plastic", amount = 2},
			{item = "Battery", amount = 1},
			{item = "Wires", amount = 1},
		},
		outputItem = {item = "Flashlight", amount = 1},
		station = "Electronics Table",
	},
	{
		id = "lantern",
		name = "Lantern",
		category = "Tools",
		requiredItems = {
			{item = "Metal", amount = 1},
			{item = "Cloth", amount = 1},
			{item = "Fuel", amount = 1},
		},
		outputItem = {item = "Lantern", amount = 1},
		station = "Workbench",
	},
	{
		id = "generator",
		name = "Generator",
		category = "Tools",
		requiredItems = {
			{item = "Scrap Metal", amount = 3},
			{item = "Wire", amount = 2},
			{item = "Fuel", amount = 1},
		},
		outputItem = {item = "Generator", amount = 1},
		station = "Electronics Table",
	},
	{
		id = "radio",
		name = "Radio",
		category = "Tools",
		requiredItems = {
			{item = "Plastic", amount = 2},
			{item = "Wire", amount = 1},
			{item = "Battery", amount = 1},
		},
		outputItem = {item = "Radio", amount = 1},
		station = "Electronics Table",
	},
	{
		id = "water_purifier",
		name = "Water Purifier",
		category = "Tools",
		requiredItems = {
			{item = "Charcoal", amount = 1},
			{item = "Sand", amount = 1},
			{item = "Bottle", amount = 1},
		},
		outputItem = {item = "Water Purifier", amount = 1},
		station = "Workbench",
	},
	{
		id = "duct_tape",
		name = "Duct Tape",
		category = "Tools",
		requiredItems = {
			{item = "Resin", amount = 1},
			{item = "Cloth Strip", amount = 1},
		},
		outputItem = {item = "Duct Tape", amount = 1},
		station = "Chem Table",
	},
	{
		id = "rope",
		name = "Rope",
		category = "Tools",
		requiredItems = {
			{item = "Cloth Strip", amount = 3},
		},
		outputItem = {item = "Rope", amount = 1},
		station = "None",
	},
	{
		id = "rope_alt",
		name = "Rope (Vine)",
		category = "Tools",
		requiredItems = {
			{item = "Vine", amount = 2},
		},
		outputItem = {item = "Rope", amount = 1},
		station = "None",
	},

	-- Medical
	{
		id = "bandage",
		name = "Bandage",
		category = "Medical",
		requiredItems = {
			{item = "Cloth Strip", amount = 1},
		},
		outputItem = {item = "Bandage", amount = 1},
		station = "None",
	},
	{
		id = "clean_bandage",
		name = "Clean Bandage",
		category = "Medical",
		requiredItems = {
			{item = "Bandage", amount = 1},
			{item = "Water", amount = 1},
		},
		outputItem = {item = "Clean Bandage", amount = 1},
		station = "Campfire",
	},
	{
		id = "painkillers",
		name = "Painkillers",
		category = "Medical",
		requiredItems = {
			{item = "Herb", amount = 1},
			{item = "Alcohol", amount = 1},
		},
		outputItem = {item = "Painkillers", amount = 1},
		station = "Chem Station",
	},
	{
		id = "antibiotics",
		name = "Antibiotics",
		category = "Medical",
		requiredItems = {
			{item = "Herb", amount = 2},
			{item = "Clean Water", amount = 1},
		},
		outputItem = {item = "Antibiotics", amount = 1},
		station = "Chem Station",
	},
	{
		id = "herbal_salve",
		name = "Herbal Salve",
		category = "Medical",
		requiredItems = {
			{item = "Herb", amount = 2},
			{item = "Cloth", amount = 1},
			{item = "Water", amount = 1},
		},
		outputItem = {item = "Herbal Salve", amount = 1},
		station = "Workbench",
	},
	{
		id = "splint",
		name = "Splint",
		category = "Medical",
		requiredItems = {
			{item = "Stick", amount = 2},
			{item = "Bandage", amount = 1},
		},
		outputItem = {item = "Splint", amount = 1},
		station = "None",
	},
	{
		id = "suture_kit",
		name = "Suture Kit",
		category = "Medical",
		requiredItems = {
			{item = "Needle", amount = 1},
			{item = "Thread", amount = 1},
		},
		outputItem = {item = "Suture Kit", amount = 1},
		station = "Sewing Station",
	},
	{
		id = "infection_cure",
		name = "Infection Cure",
		category = "Medical",
		requiredItems = {
			{item = "Rare Herb", amount = 1},
			{item = "Alcohol", amount = 1},
		},
		outputItem = {item = "Infection Cure", amount = 1},
		station = "Chem Station",
	},
	{
		id = "adrenaline_shot",
		name = "Adrenaline Shot",
		category = "Medical",
		requiredItems = {
			{item = "Chem Ingredient", amount = 1},
			{item = "Syringe", amount = 1},
		},
		outputItem = {item = "Adrenaline Shot", amount = 1},
		station = "Chem Station",
	},

	-- Traps & Defense
	{
		id = "spike_trap",
		name = "Spike Trap",
		category = "Traps",
		requiredItems = {
			{item = "Stick", amount = 3},
			{item = "Nails", amount = 4},
		},
		outputItem = {item = "Spike Trap", amount = 1},
		station = "Workbench",
	},
	{
		id = "barbed_wire_fence",
		name = "Barbed Wire Fence",
		category = "Traps",
		requiredItems = {
			{item = "Wire", amount = 2},
			{item = "Nails", amount = 2},
			{item = "Wood", amount = 1},
		},
		outputItem = {item = "Barbed Wire Fence", amount = 1},
		station = "Workbench",
	},
	{
		id = "tripwire_bomb",
		name = "Tripwire Bomb",
		category = "Traps",
		requiredItems = {
			{item = "Wire", amount = 1},
			{item = "Explosive", amount = 1},
			{item = "Trigger Device", amount = 1},
		},
		outputItem = {item = "Tripwire Bomb", amount = 1},
		station = "Electronics Table",
	},
	{
		id = "noise_decoy",
		name = "Noise Decoy",
		category = "Traps",
		requiredItems = {
			{item = "Bottle", amount = 1},
			{item = "Rocks", amount = 2},
		},
		outputItem = {item = "Noise Decoy", amount = 1},
		station = "None",
	},
	{
		id = "flame_trap",
		name = "Flame Trap",
		category = "Traps",
		requiredItems = {
			{item = "Oil", amount = 1},
			{item = "Rag", amount = 1},
			{item = "Trigger Device", amount = 1},
		},
		outputItem = {item = "Flame Trap", amount = 1},
		station = "Workbench",
	},
	{
		id = "molotov_trap",
		name = "Molotov Trap",
		category = "Traps",
		requiredItems = {
			{item = "Bottle", amount = 1},
			{item = "Oil", amount = 1},
			{item = "Cloth Strip", amount = 1},
		},
		outputItem = {item = "Molotov Trap", amount = 1},
		station = "Campfire",
	},
	{
		id = "land_mine",
		name = "Land Mine",
		category = "Traps",
		requiredItems = {
			{item = "Explosives", amount = 2},
			{item = "Pressure Plate", amount = 1},
		},
		outputItem = {item = "Land Mine", amount = 1},
		station = "Electronics Table",
	},
	{
		id = "electrified_fence",
		name = "Electrified Fence",
		category = "Traps",
		requiredItems = {
			{item = "Wire", amount = 2},
			{item = "Generator", amount = 1},
			{item = "Scrap Metal", amount = 1},
		},
		outputItem = {item = "Electrified Fence", amount = 1},
		station = "Electronics Table",
	},

	-- Survival
	{
		id = "bedroll",
		name = "Bedroll",
		category = "Survival",
		requiredItems = {
			{item = "Cloth", amount = 2},
			{item = "Rope", amount = 1},
		},
		outputItem = {item = "Bedroll", amount = 1},
		station = "None",
	},
	{
		id = "campfire",
		name = "Campfire",
		category = "Survival",
		requiredItems = {
			{item = "Stick", amount = 3},
			{item = "Rock", amount = 4},
		},
		outputItem = {item = "Campfire", amount = 1},
		station = "None",
	},
	{
		id = "tent_kit",
		name = "Tent Kit",
		category = "Survival",
		requiredItems = {
			{item = "Cloth", amount = 3},
			{item = "Stick", amount = 2},
			{item = "Rope", amount = 2},
		},
		outputItem = {item = "Tent Kit", amount = 1},
		station = "Workbench",
	},
	{
		id = "rain_collector",
		name = "Rain Collector",
		category = "Survival",
		requiredItems = {
			{item = "Barrel", amount = 1},
			{item = "Cloth", amount = 1},
			{item = "Wood", amount = 2},
		},
		outputItem = {item = "Rain Collector", amount = 1},
		station = "Workbench",
	},
	{
		id = "fishing_rod",
		name = "Fishing Rod",
		category = "Survival",
		requiredItems = {
			{item = "Stick", amount = 1},
			{item = "Rope", amount = 1},
			{item = "Hook", amount = 1},
		},
		outputItem = {item = "Fishing Rod", amount = 1},
		station = "None",
	},
	{
		id = "tarp_shelter",
		name = "Tarp Shelter",
		category = "Survival",
		requiredItems = {
			{item = "Tarp", amount = 1},
			{item = "Rope", amount = 2},
			{item = "Stick", amount = 2},
		},
		outputItem = {item = "Tarp Shelter", amount = 1},
		station = "None",
	},
	{
		id = "signal_flare",
		name = "Signal Flare",
		category = "Survival",
		requiredItems = {
			{item = "Chemicals", amount = 1},
			{item = "Cloth", amount = 1},
			{item = "Plastic Tube", amount = 1},
		},
		outputItem = {item = "Signal Flare", amount = 1},
		station = "Chem Station",
	},
	{
		id = "compass",
		name = "Compass",
		category = "Survival",
		requiredItems = {
			{item = "Metal", amount = 1},
			{item = "Magnet", amount = 1},
			{item = "Plastic", amount = 1},
		},
		outputItem = {item = "Compass", amount = 1},
		station = "Electronics Table",
	},
	{
		id = "cooking_grill",
		name = "Cooking Grill",
		category = "Survival",
		requiredItems = {
			{item = "Metal Bars", amount = 2},
			{item = "Nails", amount = 2},
		},
		outputItem = {item = "Cooking Grill", amount = 1},
		station = "Workbench",
	},
	{
		id = "sewing_kit",
		name = "Sewing Kit",
		category = "Survival",
		requiredItems = {
			{item = "Needle", amount = 1},
			{item = "Thread", amount = 1},
			{item = "Case", amount = 1},
		},
		outputItem = {item = "Sewing Kit", amount = 1},
		station = "Sewing Station",
	},
}

function RecipeDatabase:GetByCategory(category)
	local result = {}
	for _, recipe in ipairs(self.AllRecipes) do
		if category == "All" or recipe.category == category then
			table.insert(result, recipe)
		end
	end
	return result
end

function RecipeDatabase:GetRecipe(id)
	for _, recipe in ipairs(self.AllRecipes) do
		if recipe.id == id then
			return recipe
		end
	end
end

return RecipeDatabase