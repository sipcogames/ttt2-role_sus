if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_sus.vmt")
end

function ROLE:PreInitialize()

	self.color = Color(255, 127, 80, 255)

	self.abbr = "sus"
	self.score.killsMultiplier = 2
	self.score.teamKillsMultiplier = -6
	self.defaultTeam = TEAM_INNOCENT
	self.unknownTeam = true
	self.isOmniscientRole = true

	self.defaultEquipment = nil

	self.conVarData = {
		pct = 0.15,
		maximum = 1,
		minPlayers = 7,
		credits = 1,
		togglable = true,
		shopFallback = SHOP_FALLBACK_TRAITOR,
		traitorButton = 1 -- can use traitor buttons
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_INNOCENT)
end

function ROLE:GiveRoleLoadout(ply, is_rc)
	if is_rc then
		-- Randomize If Actually a Traitor
		if (math.random(1,100) > GetConVar("ttt2_sus_traitorchance"):GetInt() or GetConVar("ttt2_sus_traitorchance"):GetInt() == 0) then

			self.defaultTeam = TEAM_INNOCENT
			self.unknownTeam = true
		else

			self.defaultTeam = TEAM_TRAITOR

			-- Can they know their team?
			if (GetConVar("ttt2_sus_knowstraitors"):GetBool()) then

				self.unknownTeam = false

			else

				self.unknownTeam = true

			end

		end
	end
end

if SERVER then

	-- TODO combine next two hooks
	hook.Add("TTT2SpecialRoleSyncing", "TTT2RoleSusMod", function(ply, tbl)
		if ply and ply:GetTeam() ~= TEAM_TRAITOR or ply:GetSubRoleData().unknownTeam or GetRoundState() == ROUND_POST then return end

		local susSelected = false

		for sus in pairs(tbl) do
			if sus:IsTerror() and sus:Alive() and sus:GetSubRole() == ROLE_SUS then
				tbl[sus] = {ROLE_TRAITOR, TEAM_TRAITOR}

				susSelected = true
			end
		end

		if not susSelected then return end

		for traitor in pairs(tbl) do
			if traitor == ply then continue end

			if traitor:IsTerror() and traitor:Alive() and traitor:GetBaseRole() == ROLE_TRAITOR then
				tbl[traitor] = {ROLE_TRAITOR, TEAM_TRAITOR}
			end
		end
	end)

	-- we need this hook to secure that dead spies/traitors doesn't get revealed if someone calls SendFullStateUpdate()
	hook.Add("TTT2SpecialRoleSyncing", "TTT2RoleDeadSusMod", function(ply, tbl)
		if GetRoundState() == ROUND_POST then return end

		--check if traitors are dead and reveal
		local traitor_alive = false

		for tr in pairs(tbl) do
			if tr:IsTerror() and tr:Alive() and (tr:GetBaseRole() == ROLE_TRAITOR or tr:GetSubRole() == ROLE_SUS) then
				traitor_alive = true

				break
			end
		end

		if not traitor_alive then return end

		local susSelected = false

		for sus in pairs(tbl) do
			if not sus:Alive() and sus:GetSubRole() == ROLE_SUS then
				tbl[sus] = {ROLE_TRAITOR, TEAM_TRAITOR}

				susSelected = true
			end
		end

		if not susSelected then return end

		for traitor in pairs(tbl) do
			if traitor == ply then continue end

			if not traitor:Alive() and traitor:GetBaseRole() == ROLE_TRAITOR then
				tbl[traitor] = {ROLE_TRAITOR, TEAM_TRAITOR}
			end
		end
	end)

	hook.Add("TTT2OverrideDisabledSync", "TTT2ModifyTraitorRoles4Sus", function(ply, target)
		if GetRoundState() == ROUND_POST then return end

		local plys = player.GetAll()
		local susSelected = false

		for i = 1, #plys do
			if plys[i]:GetSubRole() == ROLE_SUS then
				susSelected = true

				break
			end
		end

		if not susSelected then return end

		if ply:GetTeam() == TEAM_TRAITOR and target:GetBaseRole() == ROLE_TRAITOR then
			return true
		end
	end)

	hook.Add("TTTCOverrideTeamSync", "TTTCModifyTeamSync4Sus", function(ply, tbl)
		if ply:GetSubRole() ~= ROLE_SUS or GetRoundState() ~= ROUND_ACTIVE then return end

		local plys = player.GetAll()

		for i = 1, #plys do
			local v = plys[i]
			if v:GetTeam() ~= TEAM_TRAITOR or v:GetSubRoleData().unknownTeam then continue end

			table.insert(tbl, v)
		end
	end)

	-- Set to Appear on Radar as a Traitor
	hook.Add("TTT2ModifyRadarRole", "TTT2ModifyRadarRole4Sus", function(ply, target)
		if ply:GetTeam() == TEAM_TRAITOR and target:GetSubRole() == ROLE_SUS then
			return ROLE_TRAITOR, TEAM_TRAITOR
		end
	end)

	-- Tell Traitors your a Traitor
	hook.Add("TTT2TellTraitors", "TTT2SusModifyStartingTraitors", function(traitornames)
		if traitornames then
			for _, sus in ipairs(player.GetAll()) do
				if sus:IsTerror() and sus:Alive() and sus:GetSubRole() == ROLE_SUS then
					traitornames[#traitornames + 1] = sus:Nick()
				end
			end
		end
	end)

	--Block Traitor Chat if set
	hook.Add("TTT2AvoidTeamChat", "TTT2SusJamTraitorChat", function(sender, tm, msg)
		if tm == TEAM_TRAITOR then
			for _, sus in ipairs(player.GetAll()) do
				if sus:IsTerror() and sus:Alive() and sus:GetSubRole() == ROLE_SUS then
					LANG.Msg(sender, "ttt2_teamchat_jammed_" .. SUS.name, nil, MSG_CHAT_WARN)

					return false
				end
			end
		end
	end)

	-- Block Traitor Voice if Set
	hook.Add("TTT2CanUseVoiceChat", "TTT2SusJamTraitorVoice", function(speaker, isTeamVoice)

		-- only jam traitor team voice
		if not isTeamVoice or not IsValid(speaker) or speaker:GetTeam() ~= TEAM_TRAITOR then return end

		-- ToDo prevent team voice overlay from showing on the speaking players screen
		for _, sus in ipairs(player.GetAll()) do
			if sus:IsTerror() and sus:Alive() and sus:GetSubRole() == ROLE_SUS then
				LANG.Msg(speaker, "ttt2_teamvoice_jammed_" .. SUS.name , nil, MSG_CHAT_WARN)

				return false
			end
		end
	end)

	-- Corpse Always Shows Traitor
	hook.Add("TTTCanSearchCorpse", "TTT2SpyChangeCorpseToTraitor", function(ply, corpse)
		local plys = player.GetAll()
		local susSelected = false

		for i = 1, #plys do
			if plys[i]:GetSubRole() == ROLE_SUS then
				susSelected = true

				break
			end
		end

		if not susSelected then return end

		if corpse and (corpse.was_role == ROLE_SUS) and not corpse.reverted_sus then
			corpse.was_role = ROLE_TRAITOR
			corpse.was_team = TEAM_TRAITOR
			corpse.role_color = TRAITOR.color
			corpse.is_sus_corpse = true
		end
	end)

	-- Always confirm Sus as a Traitor
	hook.Add("TTT2ConfirmPlayer", "TTT2SusChangeRoleToTraitor", function(confirmed, finder, corpse)
		--if not ttt2_spy_confirm_as_traitor:GetBool() then return end

		if IsValid(confirmed) and corpse and corpse.is_sus_corpse then
			confirmed:ConfirmPlayer(true)
			SendRoleListMessage(ROLE_TRAITOR, TEAM_TRAITOR, {confirmed:EntIndex()})
			events.Trigger(EVENT_BODYFOUND, finder, corpse)

			return false
		end
	end)

	-- Disallow Hitman Target
	hook.Add("TTT2CanBeHitmanTarget", "TTT2SusNoHitmanTarget", function(hitman, ply)
		if ply:GetSubRole() == ROLE_SUS then
			return false
		end
	end)
end

if CLIENT then
  function ROLE:AddToSettingsMenu(parent)
    local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

    form:MakeCheckBox({
      serverConvar = "ttt2_sus_knowstraitors",
      label = "ttt2_sus_knowstraitors"
    })

    form:MakeSlider({
      serverConvar = "ttt2_sus_traitorchance",
      label = "ttt2_sus_traitorchance",
      min = 0,
      max = 100,
      decimal = 0
    })

  end
end
