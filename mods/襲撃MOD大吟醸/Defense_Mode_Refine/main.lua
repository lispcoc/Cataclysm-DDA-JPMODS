local MOD = {}
mods["defense_mode_refine"] = MOD

local CONFIG_PATH = "./data/mods/defense_mode_refine/config.lua"
local TABLE_PATH = "./data/mods/defense_mode_refine/monster_table.lua"

dofile(CONFIG_PATH)
dofile(TABLE_PATH)

local starting_time = get_starting_time()
local first_raid_day = get_first_raid_day()
local raid_day_itvl = get_raid_day_itvl()
local raid_start_time = get_raid_start_time()
local raid_cnt_time = get_raid_cnt_time()
local raid_spawn_itvl = get_raid_spawn_itvl()
local fixed_spawn = get_fixed_spawn()
local quality_freq = get_quality_freq()
local amount_freq = get_amount_freq()
local allow_riseamount = get_allow_riseamount()
local allow_special = get_allow_special()

local abs_point = nil
local abs_point_flg = false

local DAY_DURATION = 14400

function MOD.on_new_player_created()
	local daycon = 0

	--初回襲撃日の設定により、付与するデイコンのターン長を決定
	if first_raid_day == 1 then
		daycon = ( ( 24 - starting_time ) * 60 * 10 ) + ( ( raid_day_itvl - 1 ) * 24 * 60 * 10 )
		--初回襲撃用にWavesを格納
		player:set_value("DMR_Waves", tostring(1))
	else
		daycon = ( ( 24 - starting_time ) * 60 * 10 ) + ( ( first_raid_day - 2 ) * 24 * 60 * 10 )
	end

	local daycon_dur = game.get_time_duration( daycon )

	player:add_effect(efftype_id("DMR_day_controller"), daycon_dur)

	--初回襲撃日が1=初日から襲撃有りの場合各種コントローラの設定と付与を行う
	if first_raid_day == 1 and raid_start_time >= starting_time then
		local stacon = ( raid_start_time - starting_time ) * 60 * 10

		if stacon ~= 0 then
			local stacon_dur = game.get_time_duration( stacon )
			player:add_effect(efftype_id("DMR_start_controller"), stacon_dur)
		end
		
		local encon = ( ( raid_start_time - starting_time ) * 60 * 10 ) + ( raid_cnt_time * 10 ) + 1

		local encon_dur = game.get_time_duration( encon )
		player:add_effect(efftype_id("DMR_end_controller"), encon_dur)
	end
end

function MOD.on_day_passed()
	--プレイヤーにデイコンエフェクトが有効な状態であるか否かのフラグ変数
	local daycon_flg = player:has_effect(efftype_id("DMR_day_controller"))

	--デイコンが有効＝本日は襲撃無し な場合は即座に処理を終了、それ以外の場合は襲撃に備えた処理を行う
	if daycon_flg then
--		game.add_msg("Still ACTIVE day_controller, do nothing and continue.")
		return
	else
		game.add_msg("今日は忙しい一日になりそうだ・・・")

		-- 襲撃回数の取得・インクリメント・格納を行う
		local waves = tonumber(player:get_value("DMR_Waves")) or 0
		waves = waves + 1
		player:set_value("DMR_Waves", tostring(waves))

		apply_day_effect()
		apply_start_effect()
		apply_end_effect()
	end
end

function MOD.on_minute_passed()
	--判定用に各エフェクトの付与状態を取得
	local stacon_flg = player:has_effect(efftype_id("DMR_start_controller"))
	local encon_flg  = player:has_effect(efftype_id("DMR_end_controller"))
	local spacon_flg = player:has_effect(efftype_id("DMR_spawn_controller"))

	--スタコンが有効の間は生成処理を行わないので即座に処理終了
	if stacon_flg then
--		game.add_msg("NOT reach raid start time. so do nothing and continue game.")
		return
	end

	--スタコン無効且つエンコン有効の場合に生成処理を行うか判定する
	if ( not stacon_flg ) and encon_flg then
--		game.add_msg("reach raid start time. and do something?")
		--スパコンが有効な場合、生成のインターバルが終わっていないので処理終了
		if spacon_flg then
--			game.add_msg("but now are NOT spawn timing. so do nothing and sontinue game.")
			return
		end
--		game.add_msg("reach spawn and some execution line. so execute NEEDS.")

		--プレイヤーが地上に居ればモンスター生成処理を実行し、生成処理の実行有無に関わらず生成インターバル判定用エフェクトの付与を行う
		if player:pos().z == 0 then
			raid_main()
		end
		apply_spawn_effect()
	end
	
	--スタコン無効且つエンコン無効且つスパコン有効の場合=襲撃時間終了後のタイミングで位置情報のリセットを行う
	if ( not stacon_flg ) and ( not encon_flg ) and spacon_flg then
		abs_point = nil
		abs_point_flg = false
	end
end

function raid_main()
	--abs_point_flg==falseの場合=位置情報未設定の場合、位置情報を設定する
	if ( not abs_point_flg ) then
		abs_point = map:getabs(player:pos())
		abs_point_flg = true
	end
	
--	game.add_msg("Waves: "..player:get_value("DMR_Waves"))
	
	local spawn_distance = get_spawn_distance()
	local spawn_dest     = get_spawn_destination()
	
	spawn_Mon(spawn_distance, spawn_dest)
end

function get_spawn_distance()
	local distance = 29
	local distant_randomizer = math.random(0,5)

	if game.one_in(2) then
		distance = distance + distant_randomizer
	else
		distance = distance - distant_randomizer
	end
	
	return distance
end

function get_spawn_destination()
--"スポーン方向の設定"
	local spawn_dest = math.random(1,4)

	--"スポーン方向が固定されている場合上書きで方向を決定"
	if fixed_spawn == 1 then
		spawn_dest = 1
	elseif fixed_spawn == 2 then
		spawn_dest = 2
	elseif fixed_spawn == 3 then
		spawn_dest = 3
	elseif fixed_spawn == 4 then
		spawn_dest = 4
	elseif fixed_spawn == 5 then
		if game.one_in(2) then
			spawn_dest = 1
		else
			spawn_dest = 3
		end
	elseif fixed_spawn == 6 then
		if game.one_in(2) then
			spawn_dest = 2
		else
			spawn_dest = 4
		end
	end

	return spawn_dest
end

function spawn_Mon(distance, spawn_pos)

	local spawn_cnt = 0									--"スポーンカウント"
	local point = map:getlocal(abs_point)				--"絶対座標->サブ座標に変換"
	local tbl_idx = 0									--"スポーンするMobのテーブル参照値"
	local pos_cnt = 0									--"座標決定用カウンタ"
	local i = 0											--"ループカウンタ"
	local delta_size = 0								--"出現数による生成位置補正値"
	local waves = tonumber(player:get_value("DMR_Waves")) or 1

	--"スポーン箇所が西、又は北の場合生成距離を正負反転する"
	if spawn_pos == 1 or spawn_pos == 4 then
		distance = distance * -1
	end

--"各変数初期設定"
  --"基準生成回数を設定する"
  -- 平均30 最小21 最大39
	spawn_cnt = 17 + math.random(1,4) + math.random(1,5) + math.random(1,6) + math.random(1,7)
	
  --"allow_riseamountの設定により生成回数を増加させる:増加量2d(waves)"
	if allow_riseamount == 1 then
		spawn_cnt = spawn_cnt + math.random(1,waves) + math.random(1,waves)
	end

  --"特殊襲撃が許可されていて特定のwaves数の場合生成回数を抑制する"
	if allow_special == 1 and
	   waves % 13 == 0 then
		spawn_cnt = math.floor( spawn_cnt * 2 / 3 )
	end

  --"amount_freqに従い生成数に補正を掛ける：amount_freq(%)"
	spawn_cnt = math.ceil( spawn_cnt * amount_freq / 100 )

  --"生成回数を最大で250に制限する：これをしないと無制限に生成数が増え続ける可能性がある"
	spawn_cnt = math.min(spawn_cnt, 250)

--"生成回数による位置補正値の設定：5列程度までに抑える"
	if spawn_cnt < 21 then								--"小規模"
		delta_size = 5
	elseif spawn_cnt >= 21 and							--"大規模：21-35"
		   spawn_cnt < 36 then
		delta_size = 7
	elseif spawn_cnt >= 36 and							--"大規模：36-45"
		   spawn_cnt < 46 then
		delta_size = 9
	elseif spawn_cnt >= 46 and							--"大規模：46-55"
		   spawn_cnt < 56 then
		delta_size = 11
	elseif spawn_cnt >= 56 and							--"大規模：56-65"
		   spawn_cnt < 66 then
		delta_size = 13
	elseif spawn_cnt >= 66 and							--"大規模：66-75"
		   spawn_cnt < 76 then
		delta_size = 15
	elseif spawn_cnt >= 76 and							--"大規模：76-85"
		   spawn_cnt < 86 then
		delta_size = 17
	elseif spawn_cnt >= 86 and							--"大規模：86-95"
		   spawn_cnt < 96 then
		delta_size = 19
	elseif spawn_cnt >= 96 then						   --"大規模：96-"
		delta_size = 25
	end

--"スポーン位置に合わせて初期設定"
	if spawn_pos % 2 == 0 then							--"南北方向"
		point.y = point.y + distance
		point.x = point.x + math.floor((delta_size * 3 / 4 ) + 1)
	elseif spawn_pos % 2 == 1 then						--"東西方向"
		point.y = point.y + math.floor((delta_size * 3 / 4 ) + 1)
		point.x = point.x + distance
	end

	while ( i < spawn_cnt ) do							--"spawn_cnt回生成判定を行う"

		if pos_cnt % delta_size == 0 then				--"生成座標調整"
			if spawn_pos == 1 then						--"スポーン箇所:西"
				point.y = point.y - math.floor((delta_size * 3 / 2 ) + 1)
				point.x = point.x - 1
			elseif spawn_pos == 2 then					--"スポーン箇所:南"
				point.y = point.y + 1
				point.x = point.x - math.floor((delta_size * 3 / 2 ) + 1)
			elseif spawn_pos == 3 then					--"スポーン箇所:東"
				point.y = point.y - math.floor((delta_size * 3 / 2 ) + 1)
				point.x = point.x + 1
			elseif spawn_pos == 4 then					--"スポーン箇所:北"
				point.y = point.y - 1
				point.x = point.x - math.floor((delta_size * 3 / 2 ) + 1)
			end
		end

		if g:is_empty(point) then						--"指定座標の生成可否判定"
			--生成するモンスターのIDを取得
			local m_id = get_mon_id(waves, allow_special, quality_freq)
			
			local mon = game.create_monster(mtype_id(m_id), point)
														--"モンスター生成"

			if mon ~= nil then							--"モンスター生成の成否判定"
				mon:set_dest(map:getlocal(abs_point))	--"生成されたモンスターの目標地点を"最初の"プレイヤー位置に設定"
			else
				game.add_msg("生成NG")					--"指定されたモンスターは存在しねぇかそんな座標はねぇ！"
			end
		else											--"指定座標に生成が出来ないのでループカウンタを1戻す"
			i = i - 1
		end
--"生成座標の調整"
		if spawn_pos % 2 == 0 then						--"南北方向"
			point.x = point.x + math.random(1,2)
		elseif spawn_pos % 2 == 1 then					--"東西方向"
			point.y = point.y + math.random(1,2)
		end
--"変数の終端処理"
		tbl_idx = 0
		pos_cnt = pos_cnt + 1
		i = i + 1
	end
end

function apply_day_effect()
	local daycon_dur = game.get_time_duration( raid_day_itvl * DAY_DURATION )

	player:add_effect(efftype_id("DMR_day_controller"), daycon_dur)
end

function apply_start_effect()
	local stacon_dur = game.get_time_duration( raid_start_time * 60 * 10 )
	
	player:add_effect(efftype_id("DMR_start_controller"), stacon_dur)
end

function apply_end_effect()
	local encon_dur = game.get_time_duration( ( raid_start_time * 60 * 10 ) + ( raid_cnt_time * 10 ) + 1 )

	player:add_effect(efftype_id("DMR_end_controller"), encon_dur)
end

function apply_spawn_effect()
	local spacon_dur = game.get_time_duration( raid_spawn_itvl * 10 )

	player:add_effect(efftype_id("DMR_spawn_controller"), spacon_dur)
end
