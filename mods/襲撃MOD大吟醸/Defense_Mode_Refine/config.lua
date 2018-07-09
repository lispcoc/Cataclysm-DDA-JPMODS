------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   設定用数値 設定内容の詳細については同梱の「設定項目詳細.txt」を参照して下さい                                                                                          --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--世界生成時の設定に関係する設定
	local starting_time = 8                             --"ゲーム開始時間の設定：デフォルト設定8"

--襲撃の発生に関係する設定
	local first_raid_day = 7                            --"最初の襲撃が発生する日：1にすると初日から発生する：デフォルト設定7"
	local raid_day_itvl = 7                             --"襲撃の間隔：1にすると毎日発生する、世界生成の1季節の長さを上限にするといいかも：デフォルト設定7"
	local raid_start_time = 17                          --"襲撃開始時間の設定：デフォルト設定17"
	local raid_cnt_time = 0                             --"1回の襲撃が継続する時間(分)の設定：デフォルト設定0"
	local raid_spawn_itvl = 5                           --"襲撃時のモンスター生成間隔の設定：デフォルト設定5"

--襲撃時のモンスター生成に関係する設定
	local fixed_spawn = 0                               --"襲撃方向を固定するかランダムにするかの設定：デフォルト設定0"
	local quality_freq = 100                            --"全体的な生成されるモンスターの質の設定：デフォルト設定100"
	local amount_freq = 100                             --"全体的な生成されるモンスターの量の設定：デフォルト設定100"
	local allow_riseamount = 0                          --"生成されるモンスターの量を襲撃毎に増加させていく：デフォルト設定0"
	local allow_special = 0                             --"特定の襲撃回数に達した場合に特殊な襲撃を発生させるかの設定：デフォルト設定0"
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   設定用数値 ここまで 之より下は触らないで下さい                                                                                                                         --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 各種設定項目に対するゲッターロボ
function get_starting_time()
	return starting_time
end

function get_first_raid_day()
	return first_raid_day
end

function get_raid_day_itvl()
	return raid_day_itvl
end

function get_raid_start_time()
	return raid_start_time
end

function get_raid_cnt_time()
	return raid_cnt_time
end

function get_raid_spawn_itvl()
	return raid_spawn_itvl
end

function get_fixed_spawn()
	return fixed_spawn
end

function get_quality_freq()
	return quality_freq
end

function get_amount_freq()
	return amount_freq
end

function get_allow_riseamount()
	return allow_riseamount
end

function get_allow_special()
	return allow_special
end
