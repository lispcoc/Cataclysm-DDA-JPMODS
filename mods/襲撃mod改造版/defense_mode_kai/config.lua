------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   設定用数値 設定内容の詳細については同梱の「設定項目詳細.txt」を参照して下さい																							--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--世界生成時の設定に関係する設定
	local start_season = 1								--"ゲーム開始時の季節：デフォルト設定1"
	local season_day = 14								--"1季節の長さ(世界生成時の設定)：デフォルト設定14"

--襲撃の発生に関係する設定
	local first_raid = 7								--"最初の大襲撃が発生する日：1にすると初日から発生する：デフォルト設定7"
	local raid_day = 7									--"大襲撃の間隔：1にすると毎日発生する、世界生成の1季節の長さを上限にするといいかも：デフォルト設定7"
	local raid_start = 17								--"襲撃が発生する時間の設定：デフォルト設定17"

--襲撃時のモンスター生成に関係する設定
	local fixed_spawn = 0								--"襲撃方向を固定するかランダムにするかの設定：デフォルト設定0"
	local freq = 1										--"全体的な生成されるモンスターの質の設定：デフォルト設定1"
	local amount = 1									--"全体的な生成されるモンスターの量の設定：デフォルト設定1"
	local dist_spawn = 0								--"襲撃モンスターの生成される位置の設定：デフォルト設定0"
	local allow_riseamount = 0							--"生成されるモンスターの量を襲撃毎に増加させていく：デフォルト設定0"
	local allow_special = 0								--"特定の襲撃回数に達した場合に特殊な襲撃を発生させるかの設定：デフォルト設定0"

--小規模襲撃に関係する設定
	local allow_smallraid = 0							--"小規模襲撃の発生有無：デフォルト設定0"

--タワーディフェンスモードに関係する設定
	local allow_td_mode = 0								--"タワーディフェンスモードの設定：デフォルト設定0"
	local td_mode_leng = 1								--"タワーディフェンスモードの継続時間の設定：デフォルト設定1"
	local td_mode_itvl = 10								--"タワーディフェンスモードの生成間隔の設定：デフォルト設定10"
	local td_capped_spawn = 0							--"タワーディフェンスモード時に生成数を抑制するかの設定：デフォルト設定0"
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   設定用数値 ここまで																																					--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
























































function get_first_raid()
	return first_raid
end

function get_start_season()
	return start_season
end

function get_fixed_spawn()
	return fixed_spawn
end

function get_raid_day()
	return raid_day
end

function get_season_day()
	return season_day
end

function get_freq()
	return freq
end

function get_amount()
	return amount
end

function get_dist_spawn()
	return dist_spawn
end

function get_allow_smallraid()
	return allow_smallraid
end

function get_allow_riseamount()
	return allow_riseamount
end

function get_allow_special()
	return allow_special
end

function get_raid_start()
	return raid_start
end

function get_allow_td_mode()
	return allow_td_mode
end

function get_td_mode_leng()
	return td_mode_leng
end

function get_td_mode_itvl()
	return td_mode_itvl
end

function get_td_capped_spawn()
	return td_capped_spawn
end
