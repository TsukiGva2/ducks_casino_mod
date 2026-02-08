--Creates an atlas for cards to use
SMODS.Atlas {
	-- Key for code to find it with
	key = "Ducks",
	-- The name of the file, for the code to pull the atlas from
	path = "Ducks.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
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
                        return true
                    end
                }))
                delay(0.6)
                return true
            end
        }))
    end
}

SMODS.Joker {
	-- How the code refers to the joker.
	key = 'rubberduck',
    blueprint_compat = false,
	-- loc_text is the actual name and description that show in-game for the card.
	loc_txt = {
		name = 'Rubber Duck',
		text = {
			--[[
			The #1# is a variable that's stored in config, and is put into loc_vars.
			The {C:} is a color modifier, and uses the color "mult" for the "+#1# " part, and then the empty {} is to reset all formatting, so that Mult remains uncolored.
				There's {X:}, which sets the background, usually used for XMult.
				There's {s:}, which is scale, and multiplies the text size by the value, like 0.8
				There's one more, {V:1}, but is more advanced, and is used in Castle and Ancient Jokers. It allows for a variable to dynamically change the color. You can find an example in the Castle joker if needed.
				Multiple variables can be used in one space, as long as you separate them with a comma. {C:attention, X:chips, s:1.3} would be the yellow attention color, with a blue chips-colored background,, and 1.3 times the scale of other text.
				You can find the vanilla joker descriptions and names as well as several other things in the localization files.
				]]
			"{X:mult,C:white} X#1# {} Mult",
            "turn all played cards",
            "into bonus cards"
		}
	},
	--[[
		Config sets all the variables for your card, you want to put all numbers here.
		This is really useful for scaling numbers, but should be done with static numbers -
		If you want to change the static value, you'd only change this number, instead
		of going through all your code to change each instance individually.
		]]
	config = { extra = { Xmult = 0.4 } },
	-- loc_vars gives your loc_text variables to work with, in the format of #n#, n being the variable in order.
	-- #1# is the first variable in vars, #2# the second, #3# the third, and so on.
	-- It's also where you'd add to the info_queue, which is where things like the negative tooltip are.
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_bonus
		return { vars = { card.ability.extra.Xmult } }
	end,
	-- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
	rarity = 1,
	-- Which atlas key to pull from.
	atlas = 'Ducks',
	-- This card's position on the atlas, starting at {x=0,y=0} for the very top left.
	pos = { x = 0, y = 0 },
	-- Cost of card in shop.
	cost = 5,
	-- The functioning part of the joker, looks at context to decide what step of scoring the game is on, and then gives a 'return' value if something activates.
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

        if context.joker_main then
            return {
                xmult = card.ability.extra.Xmult,
                -- message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } }
            }
        end
	end
}

----------------------------------------------
------------MOD CODE END----------------------
