local addonName, L = ...;

GTS_ProfessionInfo = {
	[0] =	{ name = L['No Profession'], 	icon = 'Interface\\Icons\\inv_gizmo_rocketlauncher', };
	[164] = { name = L['Blacksmithing'],	icon = 'Interface\\Icons\\trade_blacksmithing', },
	[165] = { name = L['Leatherworking'],	icon = 'Interface\\Icons\\inv_misc_armorkit_17' },
	[171] = { name = L['Alchemy'],			icon = 'Interface\\Icons\\trade_alchemy' },
	[182] = { name = L['Herbalism'],		icon = 'Interface\\Icons\\spell_nature_naturetouchgrow' },
	[186] = { name = L['Mining'],			icon = 'Interface\\Icons\\trade_mining' },
	[197] = { name = L['Tailoring'],		icon = 'Interface\\Icons\\trade_tailoring' },
	[202] = { name = L['Engineering'],		icon = 'Interface\\Icons\\trade_engineering' },
	[333] = { name = L['Enchanting'],		icon = 'Interface\\Icons\\trade_engraving' },
	[393] = { name = L['Skinning'],			icon = 'Interface\\Icons\\inv_misc_pelt_wolf_01' },
	[755] = { name = L['Jewelcrafting'],	icon = 'Interface\\Icons\\inv_misc_gem_01' },
	[773] = { name = L['Inscription'],		icon = 'Interface\\Icons\\inv_inscription_tradeskill01' },
};

GTS_Temp = {
	name = nil,
	skillID1 = nil,
	skillID2 = nil,
	skill1 = 0,
	skill2 = 0,
};

function GTS_OnEvent(self, event, ...)
	if ( event == 'ADDON_LOADED' ) then
		local addon = ...;
		
		-- We have loaded..
		if ( addon == 'GuildTradeSkills' ) then
			print("GuildTradeSkills Loaded... v"..GetAddOnMetadata("GuildTradeSkills", "Version"));
		
			-- Not much to do
			
		elseif ( addon == 'Blizzard_GuildUI') then
			
			-- Creat our icons
			GTS_CreatIcons();
			
			-- Update our information
			GuildRosterContainer:HookScript("OnUpdate", GTS_UpdateFrame);
		end
	end
end

function GTS_CreatIcons()
	CreateFrame("Button", "GTSButton1", GuildMemberDetailFrame);
	GTSButton1:SetPoint("BOTTOMLEFT", "GuildMemberDetailFrame", "TOPLEFT", 10, 5);
	GTSButton1:SetFrameStrata("MEDIUM");
	GTSButton1:SetSize(25,25);
	GTSButton1:SetFrameLevel(5);
	GTSButton1:RegisterForClicks("AnyDown");
	GTSButton1:SetScript("OnClick", GTS_Show1);
	GTSButton1:SetScript("OnEnter", GTS_OnEnter1);
	GTSButton1:SetScript("OnLeave", GTS_OnLeave);
	GTSButton1:CreateTexture("GTSIcon1");
	GTSIcon1:SetSize(25,25);
	GTSIcon1:SetTexture("Interface\\Icons\\inv_gizmo_rocketlauncher");
	GTSIcon1:SetPoint("TOPLEFT", 7, -5);
	
	CreateFrame("Button", "GTSButton2", GuildMemberDetailFrame);
	GTSButton2:SetPoint("LEFT", "GTSButton1", "RIGHT", 5,0);
	GTSButton2:SetFrameStrata("MEDIUM");
	GTSButton2:SetSize(25,25);
	GTSButton2:SetFrameLevel(5);
	GTSButton2:RegisterForClicks("AnyDown");
	GTSButton2:SetScript("OnClick", GTS_Show2);
	GTSButton2:SetScript("OnEnter", GTS_OnEnter2);
	GTSButton2:SetScript("OnLeave", GTS_OnLeave);
	GTSButton2:CreateTexture("GTSIcon2");
	GTSIcon2:SetSize(25,25);
	GTSIcon2:SetTexture("Interface\\Icons\\inv_gizmo_rocketlauncher");
	GTSIcon2:SetPoint("TOPLEFT", 7, -5);
end

function GTS_OpenAll()
	for id,info in pairs(GTS_ProfessionInfo) do
		ExpandGuildTradeSkillHeader(id);
	end
end

function GTS_CloseAll()
	for id,info in pairs(GTS_ProfessionInfo) do
		CollapseGuildTradeSkillHeader(id);
	end
end

-- To-Do, restore open/closed state
function GTS_Restore()
	GTS_CloseAll();
end

function GTS_UpdateFrame()
	local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(GetGuildRosterSelection());
	
	if ( name ) then
		
		-- Don't spam the server if its same as last time
		if ( GTS_Temp.name == name ) then return end
	
		local profs = GTS_SkillsByName(name);
			
		-- Reset everything
		GTS_ClearFrame();
		
		if ( profs ) then
		--	print(name, profs[1].name, profs[2].name);
			GTS_Temp.name = name;
			
			-- Primary
			if ( profs[1] ) then
				GTS_Temp.skillID1 = profs[1].skillID;
				GTS_Temp.skill1 = profs[1].skill;
				
				GTSIcon1:SetTexture(profs[1].icon);
				GTSButton1:Show();
			end
			
			-- Secondary
			if ( profs[2] ) then
				GTS_Temp.skillID2 = profs[2].skillID;
				GTS_Temp.skill2 = profs[2].skill;
				
				GTSIcon2:SetTexture(profs[2].icon);
				GTSButton2:Show();
			end
		end
	end
end

function GTS_ClearFrame()
	-- Clear the Temp
	GTS_Temp.skillID1 = 0;
	GTS_Temp.skillID2 = 0;
	GTS_Temp.skill1 = 0;
	GTS_Temp.skill2 = 0;
	
	-- Clear the icons
	GTSIcon1:SetTexture("Interface\\Icons\\inv_gizmo_rocketlauncher");
	GTSIcon2:SetTexture("Interface\\Icons\\inv_gizmo_rocketlauncher");
end

function GTS_Show1()
	if ( GTS_Temp.name ) and ( GTS_Temp.skillID1 ) then
		GetGuildMemberRecipes(GTS_Temp.name, GTS_Temp.skillID1);
	end
end

function GTS_Show2()
	if ( GTS_Temp.name ) and ( GTS_Temp.skillID2 ) then
		GetGuildMemberRecipes(GTS_Temp.name, GTS_Temp.skillID2);
	end
end


function GTS_SkillsByName(name)
	local skills = {};
	local found = false;
	GTS_OpenAll();
	
	for i=1,GetNumGuildTradeSkill() do
		local skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers,
            playerName, class, online, zone, skill, classFileName, isMobile = GetGuildTradeSkillInfo(i);
		if ( playerName == name ) then
			table.insert(skills, {
				['skillID'] = skillID,
				['skill'] = skill,
				['icon'] = GTS_ProfessionInfo[skillID]['icon'],
				['name'] = GTS_ProfessionInfo[skillID]['name'],
				['playerName'] = playerName,
			});
			found = true;
		end
	end
	
	GTS_Restore();
	
	if found then
		return skills;
	else
		return false;
	end
end

function GTS_OnEnter1(self)
	local skill = GTS_Temp.skill1;
	local name = GTS_ProfessionInfo[GTS_Temp.skillID1].name;
	
	GTS_ShowTooltip(self, skill, name);
end

function GTS_OnEnter2(self)
	local skill = GTS_Temp.skill2;
	local name = GTS_ProfessionInfo[GTS_Temp.skillID2].name;
	
	GTS_ShowTooltip(self, skill, name);
end

function GTS_ShowTooltip(self, skill, name)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint(GTS_GetAnchors(self));
	
	if ( type(skill) == 'number' ) and ( skill > 0 ) then
		GameTooltip:AddLine(skill..' |cFFFFFFFF'..name..'|r');
	else
		GameTooltip:AddLine('|cFFFFFFFF'..name..'|r');
	end
		
	GameTooltip:Show();
end

function GTS_OnLeave()
	GameTooltip:Hide()
end

function GTS_GetAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end



CreateFrame("Frame", "GTSFrame", UIParent);
GTSFrame:SetScript("OnEvent", GTS_OnEvent);
GTSFrame:RegisterEvent("ADDON_LOADED");