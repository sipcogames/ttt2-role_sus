local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[SUS.name] = "Sus"
L["info_popup_" .. SUS.name] = [[You are a Sus! You could be innocent or traitor, but you'll always be seen as a traitor.]]
L["info_popup_" .. SUS.name .. "_alone"] = [[You are a Sus! You could be innocent or traitor, but you'll always be seen as a traitor. You're Alone.]]
L["body_found_" .. SUS.abbr] = "They were Sus!"
L["search_role_" .. SUS.abbr] = "This person was Sus!"
L["target_" .. SUS.name] = "Sus"
L["ttt2_desc_" .. SUS.name] = [[As the Sus you have a 50% chance to be innocent or traitor. Play to win with your team, but keep in mind everyone sees you as a traitor.]]

-- OTHER ROLE LANGUAGE STRINGS
L["ttt2_teamchat_jammed_" .. SUS.name] = "You cannot use the team text chat. Something's Sus!"
L["ttt2_teamvoice_jammed_" .. SUS.name] = "You cannot use the team voice chat. Something's Sus!"

-- CONVAR STRINGS
L["ttt2_sus_knowstraitors"] = "Should Sus Know Traitors if a Traitor"
L["ttt2_sus_traitorchance"] = "Chance of Sus Being a Traitor"
