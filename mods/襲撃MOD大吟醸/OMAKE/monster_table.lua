----------------------------------------------------------------------------------------------------
-- 編集時の注意点
--   「"」のペアリング、「,」の入れ忘れや過剰にご注意
--
--   テーブルの「並び」は意味があり、先頭に近いIDほど序盤に出易く、後ろに行くほど後半に出易いです
--   簡単に言えば先頭に近いほど「弱い」モンスターであり、終端に近いほど「強い」モンスターと言えます。
--
--   他MODによる追加モンスター等はこのテーブルに追加「できません」
--   追加した場合、最悪ゲームが異常終了しセーブデータ破損等に繋がる恐れがあります。
----------------------------------------------------------------------------------------------------

local mon_tbl_normal = { "mon_zombie",
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

local mon_tbl_special = { "mon_zombie_soldier",
						  "mon_zombie_bio_op",
						  "mon_zombie_armored",
						  "mon_zombie_failed_weapon",
						  "mon_zombie_bio_infantry",
						  "mon_zombie_bio_knight",
						  "mon_zombie_bio_scout",
						  "mon_zombie_bio_tool" }

----------------------------------------------------------------------------------------------------
--  此処より下は編集しないで下さい。
----------------------------------------------------------------------------------------------------

function get_normal_tbl()
	return mon_tbl_normal
end

function get_hasbio_tbl()
	return mon_tbl_hasbio
end

function get_special_tbl()
	return mon_tbl_special
end

function get_mon_id(waves, allow_special, quality_freq)
	--特殊襲撃時は問答無用でspecialなモンスターを出現させる
	if allow_special == 1 and
	   waves % 13 == 0 then
		return mon_tbl_special[math.random(1,#mon_tbl_special)]
	end

	--規定wave以上且つ約3%でCBM所持モンスターを出現させる
	if waves > 10 and game.one_in(33) then
		return mon_tbl_hasbio[math.random(1,#mon_tbl_hasbio)]
	end

	--インデックス上限を1～wavesに設定
	local index_high = math.random(1, waves)
	
	--インデックス上限をquality_freqに従い補正する：quality_freq(%)
	index_high = math.ceil( index_high * quality_freq / 100 )
	
	--インデックス上限の最小値を3に設定
	index_high = math.max(3, index_high)
	
	--上限を通常テーブルの最大インデックスに
	index_high = math.min(#mon_tbl_normal, index_high)
	
	--インデックス下限を設定、最小1,最大でindex_high-7に設定
	local index_low = math.max(1,(index_high-7))
	
	--インデックス範囲内のランダムなモンスターを選択
	return mon_tbl_normal[math.random(index_low, index_high)]
end