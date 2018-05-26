local MOD = {}


-- 設定

-- 上昇させるステータスをプレイヤーが指定するか？
-- true:指定する  false:ランダムで決まる
local FragPlayerChoice = false

-- 何体倒すごとにステータスを強化するか？
local SetKillCount = 100

-- 次回の強化に必要な討伐数を加算
local AddKillCount = 10
-- SetKillCountが100、AddKillCounterが10の場合
-- 100体目討伐でステータスアップ
-- 210体目(110)で２回目のアップ,330体目(120)で３回目
--  460体目(130)で,600,750,,と必要数が増える

local StrUpMes		= "筋力が上昇した"
local DexUpMes	= "器用が上昇した"
local IntUpMes		= "知力が上昇した"
local PerUpMes	= "感覚が上昇した"




-- 設定ここまで


if FragPlayerChoice ~= true then FragPlayerChoice = false end
if SetKillCount <= 0 then SetKillCount = 300 end





mods["StatsThroughKills"] = MOD

function MOD.on_new_player_created()
	Mod_KillStat_SetVar(SetKillCount, 0, 0, 0, 0, 0)
end

function MOD.on_minute_passed()
	Mod_KillStat_Main()
end



function Mod_KillStat_Main()
	local monster_types = game.get_monster_types()
	local i = 0
	local count = 0
	for _, monster_type in ipairs(monster_types) do
		i = i + 1
		local mtype = monster_type:obj()
		count = count + g:kill_count(mtype.id) -- 対象のキル数取得
	end
	
	local next_count, str_bonus, dex_bonus, int_bonus, per_bonus, pre_add = Mod_KillStat_GetVar()
	local up = 0
	while count >= next_count do
		up = up + 1
		pre_add = pre_add + AddKillCount
		next_count = next_count + SetKillCount + pre_add
	end
	
	if up > 0 then
		Mod_KillStat_PlayerDownRef(str_bonus, dex_bonus, int_bonus, per_bonus)
		for i=1, up do
			local stat = 0
			if FragPlayerChoice ~= true then -- ランダム
				stat = game.rng(0,3)
			else -- プレイヤー選択
				local menu = game.create_uimenu()
				menu.title = "["..i.."/"..up.."]上昇させるステータスを選択"
				menu:addentry("筋力")
				menu:addentry("器用")
				menu:addentry("知力")
				menu:addentry("感覚")
			
				menu:query(true)
				stat = menu.selected
			end
		
			local s = ""
			if stat == 0 then
				s = StrUpMes
				 str_bonus =  str_bonus + 1
			elseif stat == 1 then
				s = DexUpMes
				 dex_bonus =  dex_bonus + 1
			elseif stat == 2 then
				s = IntUpMes
				 int_bonus =  int_bonus + 1
			elseif stat == 3 then
				s = PerUpMes
				 per_bonus =  per_bonus + 1
			end
			game.add_msg(s)
		end
	
		-- ステータス上昇結果反映
		Mod_KillStat_PlayerUpRef(str_bonus, dex_bonus, int_bonus, per_bonus)
		-- Mod用に保存
		Mod_KillStat_SetVar(next_count, str_bonus, dex_bonus, int_bonus, per_bonus, pre_add)
	end
end

function Mod_KillStat_PlayerDownRef(str, dex, int, per)
	player.str_max = player.str_max - str
	player.dex_max = player.dex_max - dex
	player.int_max = player.int_max - int
	player.per_max = player.per_max - per
end

function Mod_KillStat_PlayerUpRef(str, dex, int, per)
	player.str_max = player.str_max + str
	player.dex_max = player.dex_max + dex
	player.int_max = player.int_max + int
	player.per_max = player.per_max + per
	player:recalc_hp()
end

function Mod_KillStat_SetVar(addcount, str, dex, int, per, up)
	player:set_value("NextKillCount", tostring(addcount))
	player:set_value("KillStr", tostring(str))
	player:set_value("KillDex", tostring(dex))
	player:set_value("KillInt", tostring(int))
	player:set_value("KillPer", tostring(per))
	player:set_value("KillPreUp", tostring(up))
end

function Mod_KillStat_GetVar()
	return tonumber(player:get_value("NextKillCount")) or SetKillCount,
		tonumber(player:get_value("KillStr")) or 0,
		tonumber(player:get_value("KillDex")) or 0,
		tonumber(player:get_value("KillInt")) or 0,
		tonumber(player:get_value("KillPer")) or 0,
		tonumber(player:get_value("KillPreUp")) or 0
end




