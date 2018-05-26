local MOD = {}
mods["defense_mode_kai"] = MOD

local CONFIG_PATH = "./data/mods/defense_mode_kai/config.lua"

dofile(CONFIG_PATH)

local first_raid = get_first_raid()
local start_season = get_start_season()
local fixed_spawn = get_fixed_spawn()
local raid_day = get_raid_day()
local season_day = get_season_day()
local freq = get_freq()
local amount = get_amount()
local dist_spawn = get_dist_spawn()
local allow_smallraid = get_allow_smallraid()
local allow_riseamount = get_allow_riseamount()
local allow_special = get_allow_special()
local raid_start = get_raid_start()
local allow_td_mode = get_allow_td_mode()
local td_mode_leng = get_td_mode_leng()
local td_mode_itvl = get_td_mode_itvl()
local td_capped_spawn = get_td_capped_spawn()

local msg_flag = 0
local abs_flag = 0
local abs_point = nil

function MOD.on_new_player_created()
	set_starting_turn()
end

function MOD.on_day_passed()
	msg_flag = 0
end

function MOD.on_minute_passed()
	local base_date = get_date_by_turn(get_starting_turn())
	local now_turn = game.get_calendar_turn():get_turn()
	local now_date = get_date_by_turn( now_turn )		--"現在ターンから現在時間を取得"
	local total_days = calc_passed_day(base_date, now_date) + 1 - first_raid
														--"経過時間を取得"
	local wave = math.floor(total_days / raid_day) + 1	--"wave数の計算"
	local wave_type = 0									--"襲撃の種類：0.小規模 1.大規模"
	local raid_end = raid_start							--"襲撃終了時刻"
	local interval = td_mode_itvl						--"襲撃の間隔"
	local pass_time = 0									--"経過時刻判定用"
	local now_time = 0									--"判定用現在時刻"

	if total_days >= 0 then								--"襲撃発生日を超えている"
		if total_days % raid_day == 0 then				--"大規模襲撃日である"
			if now_date["minute"] == 0 and				--"襲撃開始時刻前の毎時00分にメッセージ出力判定を行う"
			   now_date["hour"] < raid_start then
				if wave % 13 == 0 and					--"特殊襲撃で特殊襲撃が許可されていればメッセージを変える"
				   allow_special ~= 0 then
					game.add_msg("生きた心地がしない・・今すぐ逃げ出したい！")
				else
					game.add_msg("何かが押し寄せてくる音がする・・・")
				end
			end
			wave_type = 1								--"wave_typeを大規模襲撃に設定"
		else											--"大規模襲撃日ではない"
			if allow_smallraid == 1 then				--"小規模襲撃が許可されている"
				wave_type = 0							--"wave_typeを小規模襲撃に設定"
			else
				wave_type = -1							--"wave_typeをどれでもないに設定"
			end
		end

--"開始・終了時刻の設定"
		if allow_td_mode == 1 and						--"TDモードが有効で大規模襲撃の場合"
		   wave_type == 1 then
			if raid_start + td_mode_leng > 23 then		--"終了時刻が23時を越える場合"
				raid_start = 23 - td_mode_leng
				raid_end = 23
			else										--"越えない場合"
				raid_end = raid_start + td_mode_leng
			end
		elseif allow_td_mode == 0 and					--"TDモードが無効で大規模襲撃の場合"
			   wave_type == 1 then
			raid_end = raid_start
			interval = 60
		elseif wave_type == 0 then						--"小規模襲撃の場合"
			raid_end = raid_start
			interval = 60
		end

--"判定用現在時刻の設定"
		now_time = now_date["hour"] * 100 + now_date["minute"]

		if raid_start * 100 <= now_time and				--"現在時間が開始時刻から終了時刻の間でwave_typeが大規模か小規模の場合に処理を行う"
		   raid_end * 100   >= now_time and
		   wave_type ~= -1 then

			pass_time = ( now_date["hour"] - raid_start ) * 60 + now_date["minute"]
														--"開始時刻から何分経過したかを設定"

			if abs_flag == 0 then
				abs_point = map:getabs(player:pos())	--"プレイヤー位置に対する絶対座標の取得、一度のみ行う"
				abs_flag = 1							--"制御用フラグの設定"
			end

			if pass_time % interval == 0 then			--"襲撃間隔の時間(分)に到達した場合に処理を行う"
				if player:posz() == 0 then				--"地表に居る"
					if now_time >= raid_start * 100 and
					   msg_flag == 0 then				--"襲撃開始時刻にのみ襲撃発生メッセージを出力する"
						game.add_msg("**襲撃だ!!**")
						if wave_type == 1 then			--"大規模の場合襲撃レベルを表示"
							game.add_msg("  襲撃レベル: "..tostring(wave))
						end
						msg_flag = 1
					end
					spawn_Main(wave,wave_type,abs_point)
				else
					game.add_msg("どうやら集団はあなたに気付かなかったようだ・・・")
				end
			end
		else
			abs_flag = 0
		end
	end

	if (total_days + 1) >= 0 and
	   (total_days + 1) % raid_day == 0 then			--"襲撃日前日の場合、通知を行う"
		if now_date["minute"] == 0 then
			if ( wave + 1 ) % 13 == 0 and
			   allow_special == 1 then
				game.add_msg("とてつもなく嫌な予感がする・・")
			else
				game.add_msg("どこかから腐臭がする・・だんだん臭いは強くなってきている")
			end
		end
	end
end

function spawn_Main(wave,wave_type,abs_point)

	local distance = 29
	local dist_freq = math.random(1,5)

	if dist_spawn > 0 then
		dist_freq = dist_freq + math.random(1,dist_spawn)
	elseif dist_spawn < 0 then
		dist_freq = dist_freq - math.random(1,math.abs(dist_spawn))
		if distance <= (math.abs(dist_freq)+4) then		--"生成位置が逆転する可能性を排除、最低でも5セルは離すように"
			dist_freq = -25
		end
	end

--"スポーン方向の設定"
	local spawn_pos = math.random(1,4)

	if fixed_spawn == 1 then							--"スポーン方向が固定されている場合上書きで方向を決定"
		spawn_pos = 1
	elseif fixed_spawn == 2 then
		spawn_pos = 2
	elseif fixed_spawn == 3 then
		spawn_pos = 3
	elseif fixed_spawn == 4 then
		spawn_pos = 4
	elseif fixed_spawn == 5 then
		if game.one_in(2) then
			spawn_pos = 1
		else
			spawn_pos = 3
		end
	elseif fixed_spawn == 6 then
		if game.one_in(2) then
			spawn_pos = 2
		else
			spawn_pos = 4
		end
	end

	if spawn_pos == 1 then								--"スポーン箇所:西"
		distance = ( distance + dist_freq ) * -1
		game.add_msg("西に集団が出現")
	elseif spawn_pos == 2 then							--"スポーン箇所:南"
		distance = distance + dist_freq
		game.add_msg("南に集団が出現")
	elseif spawn_pos == 3 then							--"スポーン箇所:東"
		distance = distance + dist_freq
		game.add_msg("東に集団が出現")
	elseif spawn_pos == 4 then							--"スポーン箇所:北"
		distance = ( distance + dist_freq ) * -1
		game.add_msg("北に集団が出現")
	end

	spawn_Mon(distance,spawn_pos,wave,wave_type,abs_point)

end

function spawn_Mon(add_pos,spawn_pos,wave,wave_type,abs_point)

	local spawn_cnt = 0									--"スポーンカウント"
	local point = map:getlocal(abs_point)				--"絶対座標->サブ座標に変換"
	local tbl_idx = 0									--"スポーンするMobのテーブル参照値"
	local pos_cnt = 0									--"座標決定用カウンタ"
	local i = 0											--"ループカウンタ"
	local delta_size = 0								--"出現数による生成位置補正値"

--"各変数初期判定"
	freq = math.max(1, freq)							--"freq:1以上の数値である事"
	amount = math.max(1, amount)						--"amount:1以上の数値である事"
	wave = math.max(1,wave)								--"小規模襲撃が有効の場合で初大襲撃が発生する前の場合wave=0でエラーが発生する為1に補正する"

--"各変数初期設定"
  --"生成回数を襲撃規模により設定する"
	if wave_type == 1 then								--"大規模襲撃の場合の生成回数設定"
		spawn_cnt = 17
		for j = 1, amount do
			spawn_cnt = spawn_cnt + math.random(1,4)
			spawn_cnt = spawn_cnt + math.random(1,5)
			spawn_cnt = spawn_cnt + math.random(1,6)
			spawn_cnt = spawn_cnt + math.random(1,7)
		end
	else												--"小規模襲撃の場合の生成回数設定"
		spawn_cnt = 2
		for k = 1, amount do
			spawn_cnt = spawn_cnt + math.random(1,4)
		end
	end
	
  --"allow_riseamountの設定により生成回数を増加させる:増加量2d(wave)"
	if allow_riseamount == 1 then
		spawn_cnt = spawn_cnt + math.random(1,wave) + math.random(1,wave)
	end

  --"タワーディフェンスモードが有効で大襲撃の場合生成数を半減させる"
	if allow_td_mode == 1 and
	   td_capped_spawn == 0 and
	   wave_type == 1 then
		spawn_cnt = math.floor( spawn_cnt / 2 )
	end

  --"特殊襲撃が許可されていて大襲撃で特定のwave数の場合生成回数を抑制する"
	if allow_special == 1 and
	   wave_type == 1 and
	   wave % 13 == 0 then
		spawn_cnt = math.floor( spawn_cnt * 2 / 3 )
	end

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
		point.y = point.y + add_pos
		point.x = point.x + math.floor((delta_size * 3 / 4 ) + 1)
	elseif spawn_pos % 2 == 1 then						--"東西方向"
		point.y = point.y + math.floor((delta_size * 3 / 4 ) + 1)
		point.x = point.x + add_pos
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
				
		if wave_type == 0 then							--"小規模襲撃の場合は特殊襲撃にしない"
			tbl_idx = math.min(tbl_idx, 40)
		elseif wave_type == 1 then						--"大規模襲撃の場合判定を行う"
			if allow_special == 1 and					--"特殊襲撃が許可されていて"
			   wave % 42 == 0 then						--"Wave数が13の倍数の1+3の倍数(は？)の場合、つまり42の倍数の場合インデックス値を43に固定する"
				tbl_idx = 43
			elseif allow_special == 1 and				--"特殊襲撃が許可されていて"
					wave % 13 == 0 then					--"Waveが13の倍数である場合質を底上げし上限を開放、13の倍数でヤベーヤツって向こうの人好きそうだし？"
				tbl_idx = math.min(tbl_idx + 5, 42)
			else										--"それ以外の場合で"
				tbl_idx = math.min(tbl_idx, 40)			--"インデックス値がテーブル最大値を越えないように"
			end
		end

		if g:is_empty(point) then						--"指定座標の生成可否判定"
			--生成するモンスターのIDを取得
			local m_id = get_mon_id(wave, freq, wave_type, allow_special)
			
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

function get_mon_id(wave, freq, wave_type, allow_special)
	local mon_tbl_norm = { "mon_zombie",
						   "mon_zombie_shady",
						   "mon_zombie_fat",
						   "mon_zombie_rot",
						   "mon_zombie_tough",
						   "mon_zombie_cop",
						   "mon_zombie_fireman",
						   "mon_zombie_hazmat",
						   "mon_beekeeper",
						   "mon_zombie_runner",
						   "mon_zombie_acidic",
						   "mon_zombie_technician",
						   "mon_zombie_hunter",
						   "mon_zombie_gasbag",
						   "mon_zombie_grabber",
						   "mon_zombie_shrieker",
						   "mon_zombie_survivor",
						   "mon_zombie_spitter",
						   "mon_zombie_swimmer",
						   "mon_zombie_dog",
						   "mon_zombie_electric",
						   "mon_zombie_scientist",
						   "mon_zolf",
						   "mon_zougar",
						   "mon_zombear",
						   "mon_zoose",
						   "mon_zombie_screecher",
						   "mon_zombie_biter",
						   "mon_zombie_grappler",
						   "mon_zombie_hollow",
						   "mon_zombie_soldier",
						   "mon_zombie_brute",
						   "mon_zombie_brute_grappler",
						   "mon_zombie_brute_ninja",
						   "mon_zombie_bio_op",
						   "mon_zombie_corrosive",
						   "mon_zombie_brute_shocker",
						   "mon_zombie_predator",
						   "mon_zombie_armored",
						   "mon_zombie_hulk" }

	local mon_tbl_hasbio = { "mon_zombie_bio_op",
							 "mon_zombie_brute_shocker",
							 "mon_zombie_electric",
							 "mon_zombie_scientist",
							 "mon_zombie_technician" }

	local mon_tbl_nether = { "mon_kreck",
							 "mon_mi_go",
							 "mon_mi_go",
							 "mon_gozu",
							 "mon_kreck",
							 "mon_mi_go",
							 "mon_mi_go",
							 "mon_mi_go",
							 "mon_gozu",
							 "mon_kreck",
							 "mon_mi_go",
							 "mon_flaming_eye",
							 "mon_shoggoth",
							 "mon_flying_polyp" }

	--特殊襲撃時は問答無用でNETHERモンスターを出現させる
	if allow_special == 1 and
	   wave_type == 1 and
	   wave % 13 == 0 then
		if game.one_in(666) then						--"1/666の確率でヤベーヤツ"
			return mon_tbl_nether[#mon_tbl_nether]
		end
		if game.one_in(3) then							--"1/3の確率でショゴス・フレーミングアイを含む"
			return mon_tbl_nether[math.random(1,( #mon_tbl_nether - 1 ))]
		end												--"それ以外ならヤベーの3種を除いてランダム"
		return mon_tbl_nether[math.random(1,( #mon_tbl_nether - 3 ))]
	end

	--規定wave以上且つ約3%でCBM所持モンスターを出現させる
	if wave > 10 and game.one_in(33) then
		return mon_tbl_hasbio[math.random(1,#mon_tbl_hasbio)]
	end

	--インデックス上限を1～wave+1～freqに設定(-1はfreq初期値が1に起因)
	local index_high = math.random(1, wave) + math.random(1, freq) - 1
	
	--インデックス上限の最小値を3に設定
	index_high = math.max(3, index_high)
	
	--上限を通常テーブルの最大インデックスに
	index_high = math.min(#mon_tbl_norm, index_high)
	
	--インデックス下限を設定、最小1,最大でindex_high-8に設定
	local index_low = math.max(1,(index_high-8))
	
	--インデックス範囲内のランダムなモンスターを選択
	return mon_tbl_norm[math.random(index_low, index_high)]
end

function get_date_by_turn(turn)
	local remain_turn = turn
	local minute_length = 10
	local hour_length = minute_length * 60
	local day_length = hour_length * 24
	local season_length = day_length * season_day
	local year_length = season_length * 4

	local date = {}
	date["year"] = math.floor(remain_turn / year_length)
	remain_turn = remain_turn % year_length
	date["season"] = math.floor(remain_turn / season_length)
	remain_turn = remain_turn % season_length
	date["day"] = math.floor(remain_turn / day_length )
	remain_turn = remain_turn % day_length
	date["hour"] = math.floor(remain_turn / hour_length)
	remain_turn = remain_turn % hour_length
	date["minute"] = math.floor(remain_turn / minute_length)
	remain_turn = remain_turn % minute_length
	date["second"] = math.floor(remain_turn * 6)
	
	return date
end

function get_turn_by_date(date)
	local calced_turn = 0
	local minute_length = 10
	local hour_length = minute_length * 60
	local day_length = hour_length * 24
	local season_length = day_length * season_day
	local year_length = season_length * 4
	
	calced_turn = calced_turn + date["year"] * year_length
	calced_turn = calced_turn + date["season"] * season_length
	calced_turn = calced_turn + date["day"] * day_length
	calced_turn = calced_turn + date["hour"] * hour_length
	calced_turn = calced_turn + date["minute"] * minute_length
	calced_turn = calced_turn + date["second"] / 6
	
	return math.floor(calced_turn)
end

function calc_passed_day(base, now)
	local pass_day = 0
	local season_length = season_day
	local year_length = season_length * 4

	local base_turn = get_turn_by_date(base)
	local now_turn = get_turn_by_date(now)
	local pass_date = get_date_by_turn(now_turn - base_turn)

--"基準日時から現在日時の経過日数を算出する"
	pass_day = pass_day + (pass_date["year"] * year_length)
	pass_day = pass_day + (pass_date["season"] * season_length)
	pass_day = pass_day + pass_date["day"]
	
	return pass_day
end

function get_starting_turn()
	return tonumber(player:get_value("DMK_STARTING_TURN")) or set_starting_turn()
end

function set_starting_turn()
--"基準日を0年[開始季節]1日目(0日)0時0分0秒に設定：使用目的が日数なので時分秒に関してはゼロ設定"
	local target_date = {}
	target_date["year"] = 0
	target_date["season"] = start_season - 1
	target_date["day"] = 0
	target_date["hour"] = 0
	target_date["minute"] = 0
	target_date["second"] = 0
--"基準日をターンに変換"
	local starting_turn = get_turn_by_date(target_date)
	
	player:set_value("DMK_STARTING_TURN", tostring(starting_turn))
	
	return tonumber(player:get_value("DMK_STARTING_TURN"))
end
