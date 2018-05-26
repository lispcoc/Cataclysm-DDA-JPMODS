function take_Chem(type)
    local count = get_num_value("SDC_COUNT")
    if count == 0 then
        do_GainStat(type)
    else
        if check_Success(type, count) then
            do_GainStat(type)
        else
            do_SideEffect(type, count)
        end
    end
    player:recalc_hp()
    count = count + 1
    set_num_value("SDC_COUNT", count)
end

function do_GainStat(type)
    local gain = 0
    if type == "STR" then
        player.str_max = player.str_max + 1
        gain = get_num_value("SDC_STR_GAIN") + 1
        set_num_value("SDC_STR_GAIN", gain)
        game.add_msg("力が漲ってきた気がする。")
    elseif type == "DEX" then
        player.dex_max = player.dex_max + 1
        gain = get_num_value("SDC_DEX_GAIN") + 1
        set_num_value("SDC_DEX_GAIN", gain)
        game.add_msg("動きが機敏になった気がする。")
    elseif type == "INT" then
        player.int_max = player.int_max + 1
        gain = get_num_value("SDC_INT_GAIN") + 1
        set_num_value("SDC_INT_GAIN", gain)
        game.add_msg("頭が良くなった気がする。")
    elseif type == "PER" then
        player.per_max = player.per_max + 1
        gain = get_num_value("SDC_PER_GAIN") + 1
        set_num_value("SDC_PER_GAIN", gain)
        game.add_msg("感覚が研ぎ澄まされた気がする。")
    else
        return false
    end
end

function check_charge(item)
    if item.charges == 0 then
        player:i_rem(item)
    end
end

function check_Success(type, count)
    local base = 100
    local reb = get_num_value("SDC_REB")
    local stats_type = 0
    local fail_base = 0
    local is_alpha = 0
    
    if count <= 7 then
        fail_base = 25
    elseif count <= 15 then
        fail_base = 50
    else
        fail_base = 75
    end
    
    if type == "STR" then
        stats_type = player.str_max
    elseif type == "DEX" then
        stats_type = player.dex_max
    elseif type == "INT" then
        stats_type = player.int_max
    elseif type == "PER" then
        stats_type = player.per_max
    end
    
    if stats_type < 18 then
        stats_type = 17
    end
    
    is_alpha = is_PlayerAlpha()
    
    if is_alpha == 1 then
        base = 50 + count - reb
    else
        base = base + ( ( count - reb ) * 2 ) + ( ( stats_type - 17 ) * 10 )
    end
    
    if math.random(1, base) <= ( 100 - fail_base ) then
        return true
    else
        return false
    end
end

function do_SideEffect(type, count)
    local is_alpha = is_PlayerAlpha()
    
    if count <= 7 then
        if is_alpha == 1 then
            player:mod_pain(math.random(1,10))
            game.add_msg("少し痛みを感じた。")
        else
            player:mod_pain(math.random(100,200))
            game.add_msg("全身に激痛が走った！")
        end
    elseif count <= 15 then
        if type == "STR" then
            if is_alpha == 1 and
               not game.one_in(8) then
                game.add_msg("一瞬筋肉が萎縮したような気がしたが気のせいだったようだ。")
                return
            end
        elseif type == "DEX" then
            if is_alpha == 1 and
               not game.one_in(8) then
                game.add_msg("足取りが重くなった気がしたが気のせいだったようだ。")
                return
            end
        elseif type == "INT" then
            if is_alpha == 1 and
               not game.one_in(8) then
                game.add_msg("思考が揺らいだ気がするが気のせいだったようだ。")
                return
            end
        elseif type == "PER" then
            if is_alpha == 1 and
               not game.one_in(8) then
                game.add_msg("感覚が衰えた気がしたが気のせいだったようだ。")
                return
            end
        end
        reduce_Stats(type, 1)
    else
        if game.one_in(2) then
            if type == "STR" then
                if is_alpha == 1 and
                   not game.one_in(3) then
                    game.add_msg("一瞬筋肉が萎縮したような気がしたが気のせいだったようだ。")
                    return
                end
            elseif type == "DEX" then
                if is_alpha == 1 and
                   not game.one_in(3) then
                    game.add_msg("足取りが重くなった気がしたが気のせいだったようだ。")
                    return
                end
            elseif type == "INT" then
                if is_alpha == 1 and
                   not game.one_in(3) then
                    game.add_msg("思考が揺らいだ気がするが気のせいだったようだ。")
                    return
                end
            elseif type == "PER" then
                if is_alpha == 1 and
                   not game.one_in(3) then
                    game.add_msg("感覚が衰えた気がしたが気のせいだったようだ。")
                    return
                end
            end
            reduce_Stats(type, 2)
        else
            if is_alpha == 1 and
               not game.one_in(3) then
                game.add_msg("体全体が衰弱している気がしたが気のせいだったようだ。")
                return
            end
            game.add_msg("体全体のあらゆる機能が衰弱している！")
            reduce_Stats("ALL", 1)
        end
    end
end

function reduce_Stats(type, amount)
    local is_alpha = is_PlayerAlpha()
    local p_str = player.str_max
    local p_dex = player.dex_max
    local p_int = player.int_max
    local p_per = player.per_max
    local gain = 0
    local l_limit = 0
    
    if is_alpha == 1 then
        l_limit = 8
    else
        l_limit = 4
    end
    
    if type == "STR" then
        if p_str <= l_limit then
            game.add_msg("筋肉が衰弱した気がしたが気のせいだったようだ。")
            return
        else
            gain = get_num_value("SDC_STR_GAIN") - amount
        
            p_str = p_str - amount
        
            if p_str < l_limit then
                gain = gain + ( l_limit - p_str )
                p_str = l_limit
            end
        end
        player.str_max = p_str
        set_num_value("SDC_STR_GAIN", gain)
        game.add_msg("筋肉が衰弱している！")
    elseif type == "DEX" then
        if p_dex <= l_limit then
            game.add_msg("手足が重くなった気がしたが気のせいだったようだ。")
            return
        else
            gain = get_num_value("SDC_DEX_GAIN") - amount

            p_dex = p_dex - amount
        
            if p_dex < l_limit then
                gain = gain + ( l_limit - p_dex )
                p_dex = l_limit
            end
        end
        player.dex_max = p_dex
        set_num_value("SDC_DEX_GAIN", gain)
        game.add_msg("手足が鉛にでもなったかのようだ！")
    elseif type == "INT" then
        if p_int <= l_limit then
            game.add_msg("一瞬思考が揺らいだ気がしたが気のせいだったようだ。")
            return
        else
            gain = get_num_value("SDC_INT_GAIN") - amount

            p_int = p_int - amount
        
            if p_int < l_limit then
                gain = gain + ( l_limit - p_int )
                p_int = l_limit
            end
        end
        player.int_max = p_int
        set_num_value("SDC_INT_GAIN", gain)
        game.add_msg("思考が纏まらない・・・あれ？")
    elseif type == "PER" then
        if p_per <= l_limit then
            game.add_msg("感覚が鈍った気がしたが気のせいだったようだ。")
            return
        else
            gain = get_num_value("SDC_PER_GAIN") - amount

            p_per = p_per - amount

            if p_per < l_limit then
                gain = gain + ( l_limit - p_per )
                p_per = l_limit
            end
        end
        player.per_max = p_per
        set_num_value("SDC_PER_GAIN", gain)
        game.add_msg("あらゆる感覚が鈍化している！")
    elseif type == "ALL" then
        reduce_Stats("STR", amount)
        reduce_Stats("DEX", amount)
        reduce_Stats("INT", amount)
        reduce_Stats("PER", amount)
    end
end

function is_PlayerAlpha()
    if player:has_trait(trait_id("THRESH_ALPHA")) then
        return 1
    else
        return 0
    end
end

function get_num_value(name)
	return tonumber(player:get_value(name)) or 0
end

function set_num_value(name, value)
	player:set_value(name, tostring(value))
end

function iuse_sdc_str(item, active)
    take_Chem("STR")
    item.charges = item.charges - 1
    check_charge(item)
end

function iuse_sdc_dex(item, active)
    take_Chem("DEX")
    item.charges = item.charges - 1
    check_charge(item)
end

function iuse_sdc_int(item, active)
    take_Chem("INT")
    item.charges = item.charges - 1
    check_charge(item)
end

function iuse_sdc_per(item, active)
    take_Chem("PER")
    item.charges = item.charges - 1
    check_charge(item)
end

function iuse_sdc_reset(item, active)
    local count = get_num_value("SDC_COUNT")
    
    if count > 0 then
        player.str_max = player.str_max - get_num_value("SDC_STR_GAIN")
        player.dex_max = player.dex_max - get_num_value("SDC_DEX_GAIN")
        player.int_max = player.int_max - get_num_value("SDC_INT_GAIN")
        player.per_max = player.per_max - get_num_value("SDC_PER_GAIN")
        set_num_value("SDC_COUNT", 0)
        set_num_value("SDC_REB", 0)
        set_num_value("SDC_STR_GAIN", 0)
        set_num_value("SDC_DEX_GAIN", 0)
        set_num_value("SDC_INT_GAIN", 0)
        set_num_value("SDC_PER_GAIN", 0)
        player:recalc_hp()
        game.add_msg("肉体が以前の強度に戻った気がする。")
        item.charges = item.charges - 1
        check_charge(item)
    else
        game.add_msg("使う必要はなさそうだ。")
    end
end

function iuse_sdc_reb(item, active)
    local count = get_num_value("SDC_COUNT")
    local reb = get_num_value("SDC_REB")
    if reb == count then
        game.add_msg("使う必要はなさそうだ。")
        return
    else
        if game.one_in(3) then
           game.add_msg("効いた気がしない。")
        else
            reb = reb + 1
            if reb > count then
                reb = count
            end
            game.add_msg("薬は効いたようだ。")
        end
    end

    set_num_value("SDC_REB", reb)
    item.charges = item.charges - 1
    check_charge(item)
end

game.register_iuse("IUSE_SDC_STR", iuse_sdc_str)
game.register_iuse("IUSE_SDC_DEX", iuse_sdc_dex)
game.register_iuse("IUSE_SDC_INT", iuse_sdc_int)
game.register_iuse("IUSE_SDC_PER", iuse_sdc_per)
game.register_iuse("IUSE_SDC_RESET", iuse_sdc_reset)
game.register_iuse("IUSE_SDC_REB", iuse_sdc_reb)
