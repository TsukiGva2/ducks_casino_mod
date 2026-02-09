SMODS.Atlas {
	key = "Ducks",
	path = "Ducks.png",
	px = 71,
	py = 95
}

SMODS.Back{
    name = "Dev deck",
    key = "fours",
    pos = {x = 1, y = 0},
    config = {give = 'rubberduck'},
    loc_txt = {
        name ="Dev deck",
        text={
            "Start with a",
            "{C:attention}Rubber duck{}",
            "and {C:attention}Detroit{}"
        },
    },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        play_sound('timpani')
                        SMODS.add_card({ set = 'Joker', key = 'j_duck_rubberduck' })
                        SMODS.add_card({ set = 'Joker', key = 'j_duck_detroit' })
                        return true
                    end
                }))
                delay(0.6)
                return true
            end
        }))
    end
}

SMODS.Joker{ --Detroit
    key = "detroit",
    config = {
        extra = {
            sub_dollars =  1,
            chips       = 30,
            mult        = 10
        }
    },
    loc_txt = {
        name = 'Detroit',
        text = {
            '{C:blue}+#1# {}chips, {C:red}+#2#{} Mult, {C:gold}-$#3#{} per card played',
            '"Can\'t have SHIT in Detroit, man!"'
        },
        unlock = {''}
    },
    pos = {
        x = 1,
        y = 0
    },
    display_size = {
        w = 71, 
        h = 95
    },
    cost = 3,
    rarity = 1,
    unlocked = true,
    discovered = false,
    atlas = 'Ducks',
    
    loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.extra.chips,
            card.ability.extra.mult,
            card.ability.extra.sub_dollars
        }}
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            return {
                func = function()
                    ease_dollars(-1 * card.ability.extra.sub_dollars)
                    return true
                end,
                extra = {
                    message = 'Robbed!',
                    colour = G.C.MONEY
                },
            }
        end

        if context.cardarea == G.jokers and context.joker_main  then
            return {
                chips = card.ability.extra.chips,
                extra = {
                    mult = card.ability.extra.mult
                }
            }
        end
    end
}

SMODS.Joker {
	key = 'rubberduck',
    blueprint_compat = false,
	loc_txt = {
		name = 'Rubber Duck',
		text = {
			"{X:mult,C:white} X#1# {} Mult",
            "turn all played cards",
            "into bonus cards"
		}
	},
	config = { extra = { Xmult = 0.4 } },
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_bonus
		return { vars = { card.ability.extra.Xmult } }
	end,
	rarity = 1,
	atlas = 'Ducks',
	pos = { x = 0, y = 0 },
	cost = 5,
	calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local enhanced = 0

            for _, scored_card in ipairs(context.scoring_hand) do
                if not next(SMODS.get_enhancements(scored_card)) and not scored_card.debuff then
                    enhanced = enhanced + 1
                    scored_card:set_ability('m_bonus', nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            return true
                        end
                    }))
                end
            end

            if enhanced > 0 then
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS
                }
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            return {
                xmult = card.ability.extra.Xmult,
            }
        end
	end
}

----------------------------------------------
------------MOD CODE END----------------------
