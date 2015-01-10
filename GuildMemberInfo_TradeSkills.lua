local addonName, L = ...;

local ProfessionInfo = {
	[0] =	{ name = L['No Profession'], 	book = false,	icon = 'Interface\\Icons\\inv_gizmo_rocketlauncher', };
	[164] = { name = L['Blacksmithing'],	book = true,	icon = 'Interface\\Icons\\trade_blacksmithing', },
	[165] = { name = L['Leatherworking'],	book = true,	icon = 'Interface\\Icons\\inv_misc_armorkit_17' },
	[171] = { name = L['Alchemy'],			book = true,	icon = 'Interface\\Icons\\trade_alchemy' },
	[182] = { name = L['Herbalism'],		book = false,	icon = 'Interface\\Icons\\spell_nature_naturetouchgrow' },
	[186] = { name = L['Mining'],			book = true,	icon = 'Interface\\Icons\\trade_mining' },
	[197] = { name = L['Tailoring'],		book = true,	icon = 'Interface\\Icons\\trade_tailoring' },
	[202] = { name = L['Engineering'],		book = true,	icon = 'Interface\\Icons\\trade_engineering' },
	[333] = { name = L['Enchanting'],		book = true,	icon = 'Interface\\Icons\\trade_engraving' },
	[393] = { name = L['Skinning'],			book = false,	icon = 'Interface\\Icons\\inv_misc_pelt_wolf_01' },
	[755] = { name = L['Jewelcrafting'],	book = true,	icon = 'Interface\\Icons\\inv_misc_gem_01' },
	[773] = { name = L['Inscription'],		book = true,	icon = 'Interface\\Icons\\inv_inscription_tradeskill01' },
};

local Temp = {
	name = nil,
	skillID1 = nil,
	skillID2 = nil,
	skill1 = 0,
	skill2 = 0,
};

GMI:Register("GMITradeSkills", {
	lines = {
			Skills = {
				default = 'none',
				callback = function(...) return GMIts_UpdateIcons(...); end,
				height = 35,
				onload = function(...) GMIts_CreatIcons(...) end,
				text = false,
			},
		},
	});

function GMIts_CreatIcons(label, text)
	CreateFrame("Button", "GMItsButton1", GMIFrame);
	GMItsButton1:SetPoint("LEFT", label, "RIGHT", 5, 5);
	GMItsButton1:SetFrameStrata("MEDIUM");
	GMItsButton1:SetSize(25,25);
	GMItsButton1:SetFrameLevel(5);
	GMItsButton1:RegisterForClicks("AnyDown");
	GMItsButton1:SetScript("OnClick", GMIts_Show1);
	GMItsButton1:SetScript("OnEnter", GMIts_OnEnter1);
	GMItsButton1:SetScript("OnLeave", GMIts_OnLeave);
	GMItsButton1:CreateTexture("GMItsIcon1");
	GMItsIcon1:SetSize(25,25);
	GMItsIcon1:SetTexture("Interface\\Icons\\inv_gizmo_rocketlauncher");
	GMItsIcon1:SetPoint("CENTER");

	CreateFrame("Button", "GMItsButton2", GMIFrame);
	GMItsButton2:SetPoint("LEFT", "GMItsButton1", "RIGHT", 5, 0);
	GMItsButton2:SetFrameStrata("MEDIUM");
	GMItsButton2:SetSize(25,25);
	GMItsButton2:SetFrameLevel(5);
	GMItsButton2:RegisterForClicks("AnyDown");
	GMItsButton2:SetScript("OnClick", GMIts_Show2);
	GMItsButton2:SetScript("OnEnter", GMIts_OnEnter2);
	GMItsButton2:SetScript("OnLeave", GMIts_OnLeave);
	GMItsButton2:CreateTexture("GMItsIcon2");
	GMItsIcon2:SetSize(25,25);
	GMItsIcon2:SetTexture("Interface\\Icons\\inv_gizmo_rocketlauncher");
	GMItsIcon2:SetPoint("CENTER");
end

function GMIts_UpdateIcons(name)
	local profs = GMIts_SkillsByName(name);
	
	-- Reset everything
	GMIts_ClearFrame();
	
	if profs then
		Temp.name = name;
		
		if ( profs[1] ) then
			Temp.skillID1 = profs[1].skillID;
			Temp.skill1 = profs[1].skill;
			
			GMItsIcon1:SetTexture(profs[1].icon);
			GMItsButton1:Show();
		end
		
		if ( profs[2] ) then
			Temp.skillID2 = profs[2].skillID;
			Temp.skill2 = profs[2].skill;
			
			GMItsIcon2:SetTexture(profs[2].icon);
			GMItsButton2:Show();
		end
	end
	
	return false;
end

function GMIts_Show1()
	if ( Temp.name ) and ( Temp.skillID1 ) then
		GetGuildMemberRecipes(Temp.name, Temp.skillID1);
	end
end

function GMIts_Show2()
	if ( Temp.name ) and ( Temp.skillID2 ) then
		GetGuildMemberRecipes(Temp.name, Temp.skillID2);
	end
end

function GMIts_OnEnter1(self)
	if Temp.skillID1 then
		skill = Temp.skill1;
		name = ProfessionInfo[Temp.skillID1].name;
	else
		skill = 0;
		name = ProfessionInfo[0].name;
	end
	
	GMIts_ShowTooltip(self, skill, name);
end

function GMIts_OnEnter2(self)
	if Temp.skillID2 then
		skill = Temp.skill2;
		name = ProfessionInfo[Temp.skillID2].name;
	else
		skill = 0;
		name = ProfessionInfo[0].name;
	end
	
	GMIts_ShowTooltip(self, skill, name);
end

function GMIts_OnLeave()
	GameTooltip:Hide()
end

function GMIts_SkillsByName(name)
	local skills = {};
	local found = false;
	
	-- Open all the options for scanning
	GMIts_OpenAll();
	
	for i=1,GetNumGuildTradeSkill() do
        local skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerName, playerNameWithRealm, class, online, zone, skill, classFileName, isMobile = GetGuildTradeSkillInfo(i);
			
		if playerNameWithRealm == name then
			table.insert(skills, {
				['skillID'] = skillID,
				['skill'] = skill,
				['icon'] = ProfessionInfo[skillID]['icon'],
				['name'] = ProfessionInfo[skillID]['name'],
				['playerName'] = playerName,
			});
			found = true;
		end
	end
	
	-- Restore to the previous state
	GMIts_Restore();
	
	if found then
		return skills;
	else
		return false;
	end
end

-------------------------------------------------
---------- Local Functions ----------------------
-------------------------------------------------

function GMIts_OpenAll()
	for id,info in pairs(ProfessionInfo) do
		ExpandGuildTradeSkillHeader(id);
	end
end

function GMIts_CloseAll()
	for id,info in pairs(ProfessionInfo) do
		CollapseGuildTradeSkillHeader(id);
	end
end

-- To-Do, restore open/closed state
function GMIts_Restore()
	GMIts_CloseAll();
end

function GMIts_ClearFrame()
	-- Clear the Temp
	Temp.skillID1 = 0;
	Temp.skillID2 = 0;
	Temp.skill1 = 0;
	Temp.skill2 = 0;
	
	-- Clear the icons
	GMItsIcon1:SetTexture("Interface\\Icons\\inv_gizmo_rocketlauncher");
	GMItsIcon2:SetTexture("Interface\\Icons\\inv_gizmo_rocketlauncher");
end

function GMIts_ShowTooltip(self, skill, name)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint(GMIts_GetAnchors(self));
	
	if ( type(skill) == 'number' ) and ( skill > 0 ) then
		GameTooltip:AddLine(skill..' |cFFFFFFFF'..name..'|r');
	else
		GameTooltip:AddLine('|cFFFFFFFF'..name..'|r');
	end
		
	GameTooltip:Show();
end

function GMIts_GetAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end
