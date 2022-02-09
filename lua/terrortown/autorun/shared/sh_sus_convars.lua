--ConVar syncing
CreateConVar("ttt2_sus_knowstraitors", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_sus_traitorchance", "50", {FCVAR_ARCHIVE, FCVAR_NOTFIY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicSusCVars", function(tbl)
	tbl[ROLE_SUS] = tbl[ROLE_SUS] or {}

	table.insert(tbl[ROLE_SUS], {
    	cvar = "ttt2_sus_knowstraitors",
    	checkbox = true,
    	desc = "ttt2_sus_knowstraitors (Def. 0)"
    })

	table.insert(tbl[ROLE_SUS], {
		cvar = "ttt2_sus_traitorchance",
		slider = true,
		min = 0,
		max = 100,
		decimal = 0,
		desc = "ttt2_sus_traitorchance [0..100] (Def: 50)"
	})

end)
