COLOR4B = {
    WHITE = cc.c4b(0xff, 0xff, 0xff, 0xff),				-- 白
	GREEN = cc.c4b(0x1e, 0xff, 0x00, 0xff),				-- 绿
	BRIGHT_GREEN = cc.c4b(0x00, 0xff, 0x00, 0xff),		-- 鲜绿
	BLUE = cc.c4b(0x36, 0xc4, 0xff, 0xff),				-- 蓝
	PURPLE = cc.c4b(0xa3, 0x35, 0xee, 0xff),				-- 紫
	PURPLE2 = cc.c4b(0xde, 0x00, 0xff, 0xff),				-- 紫
	ORANGE = cc.c4b(0xff, 0x7f, 0x00, 0xff),				-- 橙
	RED = cc.c4b(0xff, 0x28, 0x28, 0xff),					-- 红
	YELLOW = cc.c4b(0xff, 0xff, 0x00, 0xff),				-- 黄
	G_Y = cc.c4b(0xf4, 0xff, 0x00, 0xff),					-- 金黄
	GOLD = cc.c4b(0xff, 0xc8, 0x00, 0xff),				-- 金色
	DULL_GOLD = cc.c4b(0xc7, 0xb3, 0x77, 0xff),			-- 暗金
	BLACK = cc.c4b(0x00, 0x00, 0x00, 0xff),				-- 黑
	BROWN = cc.c4b(0x51, 0x2b, 0x1b, 0xff),				-- 棕色
	GRAY = cc.c4b(0xa6, 0xa6, 0xa6, 0xff),				-- 灰色
	GRAY_A = cc.c4b(0xa6, 0xa6, 0xa6, 10),				-- 灰色
	OLIVE = cc.c4b(0xed, 0xd9, 0xb2, 0xff),				-- 橄榄色
	PINK = cc.c4b(0xdb, 0x70, 0xdb, 0xff),				-- 粉色
	LIGHT_BROWN = cc.c4b(0x9c, 0x8b, 0x6f, 0xff),			-- 茶色
	G_W = cc.c4b(0xb0, 0xa6, 0x94, 0xff),					-- 灰白
	G_W2 = cc.c4b(0xf4, 0xe6, 0xcf, 0xff),				-- 灰白亮
	R_Y = cc.c4b(0xbe, 0x87, 0x40, 0xff),					-- 红黄
	DEEP_R_Y = cc.c4b(0xe3, 0x83, 0x49, 0xff),			-- 深红黄
	DEEP_ORANGE = cc.c4b(0xe2, 0xb9, 0x3d, 0xff),			-- 深桔色
	GREEN_D_S = cc.c4b(199, 238, 206, 0xff),			-- 绿豆沙
}

MONSTER_STATE = {
	INVALID = 0,
	RUNNING = 1,
	DEAD = 2,
	END_PATH = 3,
}

TOWER_STATE = {
	LIVING = 1,
	SELL = 2,
	UP_LEVEL = 3,
}

MENU_TYPE = {
	BUILD = 1,
	UPDATE = 2,
}

DIRECTION = {
	[1] = {1, 0},
	[2] = {1, 0},
	[3] = {0, 4},
	[4] = {0, -1},
}

X_ANCHOR = {
    [1] = {0.5, 0.4},
    [2] = {0.65, 0.5},
    [3] = {0.9, 0.6},
    [4] = {0.9, 0.5},
    [5] = {0.6, 0.5}, -- 可转动tower
}

HIT_ANIM = {
	[1] = 0,
	[2] = 1,
	[3] = 0,
	[4] = 18,
	[5] = 9,
}

TOWER_CFG = require("src/app/config/tower_cfg.lua")

SHOOT_BULLET = "shoot_bullet"
BUILD_TOWER = "build_tower"
SELL_TOWER = "sell_tower"
UP_LEVEL_TOWER = "up_level_tower"
UPDATE_GAME_STATE = "update_game_state"
RESTART = "restart"
MONSTER_END_PATH = "monster_end_path"

IS_START = false

function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

function PrintTable(tbl, level)
	if nil == tbl or "table" ~= type(tbl) then
		print("[PrintTable] arg is nil or not a table!!!")
		return
	end
	level = level or 1
	local indent_str = ""
	for i = 1, level do
		indent_str = indent_str.."  "
	end
	print(indent_str .. "{")
	for k,v in pairs(tbl) do
		local item_str = string.format("%s%s = %s", indent_str .. "  ", tostring(k), tostring(v))
		print(item_str)
		if type(v) == "table" then
			PrintTable(v, level + 1)
		end
	end
	print(indent_str .. "}")
end

function GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    
    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))

    return nRet;
end

function IsInRange(targetV, startV, endV)
	if targetV <= startV and targetV >= endV then 
		return true
	end
	if targetV >= startV and targetV <= endV then 
		return true
	end
	return false
end