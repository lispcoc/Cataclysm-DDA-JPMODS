local MOD = {}
mods["defense_mode"] = MOD
function MOD.on_minute_passed()

    local raid_day = 15                                  --"襲撃スパン"
    local season_day = raid_day * 4                      --"1年の日数"
    local calendar = game:get_calendar_turn()            --"カレンダーの取得"
    local sunset  = calendar:sunset()                    --"日の入り時刻の取得"
    local total_days = (calendar:years() * season_day) + calendar:day_of_year()
    wave = total_days / raid_day                         --"wave数の計算"
    level = 1                                            --"スポーン指数"
        
    if total_days % raid_day == 0 then                   --"襲撃日の場合、処理を行う"
            
        if calendar:minutes() == 0 then
            game.add_msg("何やら怪しい物音がする・・・")
        end
            
        if sunset:hours() == calendar:hours() and
           sunset:minutes() == calendar:minutes() then   --"日の入り時刻の場合、処理を行う"
           
            if player:posz() == 0 then                   --"地上にいる場合のみ襲撃を行う"
    
                game.add_msg("ゾンビ達の襲撃だ!!"..tostring(total_days / raid_day).."wave")
                spawn_Main()
            else
                game.add_msg("どうやら集団はあなたに気付かなかったようだ・・・")
            end
    
        end
    else
        if (calendar:days() + 1) % raid_day == 0 then     --"襲撃日前日の場合、通知を行う"
            if calendar:minutes() == 0 then
                game.add_msg("どこかから腐臭がする・・だんだん臭いは強くなってきている")
            end
        end
    end
end

function spawn_Main()

    local south_pos = 30                      --"南のスポーン位置"
    local north_pos = -30                     --"北のスポーン位置"
    local east_pos = 30                       --"東のスポーン位置"
    local west_pos = -30                      --"西のスポーン位置"
    
    local spawn_pos = math.random(1,4)        --"スポーン箇所の割り出し"

    if spawn_pos == 1 then                    --"スポーン箇所:西"
      game.add_msg("西に集団が出現")
        spawn_Mon(west_pos,spawn_pos)
    elseif spawn_pos == 2 then                --"スポーン箇所:南"
      game.add_msg("南に集団が出現")
      spawn_Mon(south_pos,spawn_pos)
    elseif spawn_pos == 3 then                --"スポーン箇所:東"
      game.add_msg("東に集団が出現")
        spawn_Mon(east_pos,spawn_pos)
    elseif spawn_pos == 4 then                --"スポーン箇所:北"
      game.add_msg("北に集団が出現")
        spawn_Mon(north_pos,spawn_pos)
    end

end

function spawn_Mon(add_pos,spawn_pos)

--"通常スポーンのテーブル"
    local mon_tbl = {"mon_zombie",
                     "mon_zombie_dog",
                     "mon_zombie_fat", 
                     "mon_zombie_tough"
                    }
                  
--"レアスポーンのテーブル"
    local mon_tbl_sp = {"mon_zombie_acidic", 
                        "mon_zombie_soldier"
                       }
                     
    local mon_tbl_spawn = {}                     --"スポーンテーブルの格納先"
    local mon_tbl_cnt = 0                        --"スポーンテーブルカウント"
  
    if math.random(1,100) < 95 then              --"レアスポーン判定(5%)"
      --"通常スポーン"
        mon_tbl_cnt = math.random(1,#mon_tbl)    --"テーブル要素数取得"
        mon_tbl_spawn = mon_tbl
    else
        --"レアスポーン"
        mon_tbl_cnt = math.random(1,#mon_tbl_sp) --"テーブル要素数取得"
        mon_tbl_spawn = mon_tbl_sp
    end
  
    local point = player:pos()                         --"プレイヤーの位置取得"
    if spawn_pos % 2 ~= 0 then
        point.x = point.x + add_pos
    elseif spawn_pos % 2 == 0 then
        point.y = point.y + add_pos
    end

    for x = 0, level + wave do                       --"wave数分ループ"

        if spawn_pos % 2 == 0 then
            point.x = point.x - 1
         
        else
            point.x = point.x + 1
         
        end
        
        for y = 0, level + wave do                   --"スポーン処理開始"
            if spawn_pos % 2 == 0 then
         
                point.y = point.y - 1
            elseif spawn_pos % 2 == 1 then        

                point.y = point.y + 1
            end       
  
            mon = game.create_monster(mtype_id(mon_tbl_spawn[mon_tbl_cnt]), point) 
        end                                           --"スポーン処理終了"
        if spawn_pos % 2 == 0 then
            point.y = player:posy() + add_pos
        else
            point.y = player:posy()
        end
    end
    if spawn_pos % 2 ~= 0 then
        point.x = player:posx() + add_pos
    else
        point.x = player:posx()
    end
    if not(mon) then
        game.add_msg("")
    end
end