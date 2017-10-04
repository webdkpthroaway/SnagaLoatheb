SnagaLoa_Names = {};
local SnagaLoa_NamesSave = {};
local SnagaLoa_RaidIds = {};
local SnagaLoa_TempList = {};
local posintables = nil;
local currentclass = nil;
local windowheight = nil;
local runningtime = 0;
local currentmaster = "";
local counter = 0;
generated = 0;
frameshown = 0;
master = 0;


function SnagaLoa_OnLoad()
   this:RegisterEvent("VARIABLES_LOADED")
   this:RegisterEvent("CHAT_MSG_ADDON");
end

function SnagaLoa_OnEvent()

	if ( event == "VARIABLES_LOADED" ) then
		if ( frameshown == 1 ) then
		 SnagaLoaFrame:Show();
		elseif ( frameshown == 0 ) then
		 SnagaLoaFrame:Hide();
		end
		SLASH_SnagaLoa1 = "/loatheb";
		SlashCmdList["SnagaLoa"] = SnagaLoa_SlashHandler;
		DEFAULT_CHAT_FRAME:AddMessage( "Loatheb-Addon Loaded. Type '/loatheb help' for more info." );
		current1:SetText("List by:");
		current1:SetTextColor(0.93,0.77,0,1);
		current1:Show();
		current2:SetText("");
		current2:SetTextColor(0.93,0.77,0,1);
		current2:Show();
		pending1:SetText("list pending..");
		pending1:Hide();
		SnagaLoa_HideMasterFrames();
		if ( master == 1 ) then
			SendAddonMessage("loamnew", UnitName("player"), "RAID");
			currentmaster = UnitName("player");
			Edit:Show();
			Broadcast:Show();
			Reload:Hide();
			current2:SetText(currentmaster);
			current2:SetTextColor(SnagaLoa_SetMasterColorM());
			firstgen = 0;
			SnagaLoa_EditStart();
			generated = 0;
		else 
			master = 0;
			SnagaLoa_ClearAllLists();
			SnagaLoa_Names = {};
			SnagaLoa_RaidIds = {};
			SnagaLoa_Request();
		end
	elseif ( event == "CHAT_MSG_ADDON" ) then
		local a1 = arg1;
		local a2 = arg2;
		local a3 = arg3;
		local a4 = arg4;
		if ( a1 == "loamnew" ) then
			if ( a4 ~= UnitName("player") ) then
				currentmaster = a4;
				current2:SetText(currentmaster);
				current2:SetTextColor(SnagaLoa_SetMasterColorCL());
				generated = 0;
			end
		elseif ( a1 == "loamoff" ) then
			if ( a4 ~= UnitName("player") ) then
				currentmaster = "";
				current2:SetText(currentmaster);
				SnagaLoa_ClearAllLists();
				SnagaLoa_Names = {};
				SnagaLoa_RaidIds = {};
				SnagaLoa_SetWindowHeight();
				generated = 0;
			end
		elseif ( a1 == "loacreq" ) then
			if ( master == 1 ) then
				if ( generated == 1 ) then
					SnagaLoa_BroadCast();
				end
			end
		elseif ( a1 == "loalistoff" ) then
			if ( master == 0 ) then
				SnagaLoa_ClearAllLists();
				pending1:Show();
				SnagaLoa_Names = {};
				SnagaLoa_RaidIds = {};
				SnagaLoa_SetWindowHeight("pending");
				generated = 0;
			end
		elseif ( a1 == "loaliston" ) then
			if ( master == 0 ) then
				pending1:Hide();
			end
		elseif ( a1 == "loabroad" ) then
			if ( master == 0 ) then
				if ( currentmaster == "" ) then
					currentmaster = a4;
					current2:SetText(currentmaster);
					current2:SetTextColor(SnagaLoa_SetMasterColorCL());
				end
				SnagaLoa_ClientList(a2);
			end
		end
	end
end

function SnagaLoa_ClientList(arg)
	local namestring = arg;
	SnagaLoa_Names = {};
	SnagaLoa_RaidIds = {};
--	DEFAULT_CHAT_FRAME:AddMessage(namestring);
	for word in string.gfind(namestring, "%a+") do 
		table.insert(SnagaLoa_Names, word);
	end
	for a,b in ipairs(SnagaLoa_Names) do
--	DEFAULT_CHAT_FRAME:AddMessage(a..": "..b);
	end
--	DEFAULT_CHAT_FRAME:AddMessage("Name-List size: "..table.getn(SnagaLoa_Names));
	for p,q in ipairs(SnagaLoa_Names) do
		for i=1, GetNumRaidMembers() do
			local unitid = "raid"..i;
			local name, realm = UnitName(unitid);
			if ( name == q ) then
				table.insert(SnagaLoa_RaidIds, unitid);
			end
		end
	end
	for g,h in ipairs(SnagaLoa_RaidIds) do
--	DEFAULT_CHAT_FRAME:AddMessage(g..": "..h);
	end	
--	DEFAULT_CHAT_FRAME:AddMessage("RaidID-List size: "..table.getn(SnagaLoa_RaidIds));
	SnagaLoa_DoText();
	SnagaLoa_SetWindowHeight();
	generated = 1;
end

function SnagaLoa_RenewIds()
	SnagaLoa_RaidIds = {};
	for p,q in ipairs(SnagaLoa_Names) do
		local namepureq = string.gsub(q, "!!%s", "");
		if ( SnagaLoa_IsInRaid(namepureq) ) then
			for i=1, GetNumRaidMembers(), 1 do
				local unitid = "raid"..i;
				local name, realm = UnitName(unitid);
				if ( name == namepureq ) then
					table.insert(SnagaLoa_RaidIds, unitid);
				end
			end
			if ( string.find(SnagaLoa_Names[p], "!!") ) then
				SnagaLoa_Names[p] = string.gsub(SnagaLoa_Names[p], "!!%s", "");
			end
		else
			if ( not string.find(SnagaLoa_Names[p], "!!") ) then
				SnagaLoa_Names[p] = string.format("%s %s", "!!", SnagaLoa_Names[p]);
			end
			
			table.insert(SnagaLoa_RaidIds, "raid1");
		end	
	end	
	SnagaLoa_DoText();
end

function SnagaLoa_BroadCast()
	local bcstring = "";
	for f,g in ipairs(SnagaLoa_Names) do
		if ( bcstring == "" ) then
			bcstring = string.format("%s", g);
		else
			bcstring = string.format("%s %s", bcstring, g);
		end
	end
	SendAddonMessage("loabroad", bcstring, "RAID");
end


function SnagaLoa_Add(currentname)
	for i=1, GetNumRaidMembers(), 1 do
		local unitid = "raid"..i;
		local name, realm = UnitName(unitid);
		if ( name == currentname ) then
			table.insert(SnagaLoa_RaidIds, unitid);
		end
	end
	table.insert(SnagaLoa_Names, currentname);
	SnagaLoa_DoText();
	SnagaLoa_SetWindowHeight();
	SnagaLoa_SetWindowWidth();
end


function SnagaLoa_Reload(argument)
          if ( argument == "LeftButton" ) then
		SnagaLoa_Request();
          end
end
	
function SnagaLoa_SaveButton()
	SnagaLoa_HideMasterFrames();
	SnagaLoa_BCon();
	SnagaLoa_BroadCast();
	generated = 1;
	if ( firstgen == 1 ) then
		firstgen = 0;
	end
	SnagaLoa_DoText();
	SnagaLoa_SetWindowHeight();
	SnagaLoa_SetWindowWidth();
end

function SnagaLoa_NewButton()
	if ( firstgen == 1 ) then
		SnagaLoa_GenerateFirstBox();
	else
		SnagaLoa_GenerateBox("new");
	end
end
	
function SnagaLoa_BCon()
	SendAddonMessage("loaliston", UnitName("player"), "RAID");
end

function SnagaLoa_BCoff()
	SendAddonMessage("loalistoff", UnitName("player"), "RAID");
end


function SnagaLoa_ToggleMasterMode()
	if ( master == 0 ) then
		SendAddonMessage("loamnew", UnitName("player"), "RAID");
		master = 1;
		currentmaster = UnitName("player");
		Edit:Show();
		Broadcast:Show();
		Reload:Hide();
		current2:SetText(currentmaster);
		current2:SetTextColor(SnagaLoa_SetMasterColorM());
		SnagaLoa_GenerateFirstBox();
		SnagaLoa_BCoff();
		generated = 0;
	elseif ( master == 1 ) then
		SendAddonMessage("loamoff", UnitName("player"), "RAID");
		master = 0;
		currentmaster = "";
		SnagaLoa_HideMasterFrames();
		current2:SetText(currentmaster);
		Edit:Hide();
		Broadcast:Hide();
		Reload:Show();
		SnagaLoa_ClearAllLists();
		SnagaLoa_Names = {};
		SnagaLoa_RaidIds = {};
		SnagaLoa_SetWindowHeight();
	end
end


	

function SnagaLoa_GenerateFirstList()
		local unitid;
		SnagaLoa_TempList = {};
                local insertatpos = 1;
                currentclass = "Priest";
		for i=1, GetNumRaidMembers(), 1 do
        	unitid = "raid"..i;
        	local name, realm = UnitName(unitid);
                        if ( UnitClass(unitid) == currentclass ) then
			      tinsert(SnagaLoa_TempList, insertatpos, name);
                              insertatpos = insertatpos+1;
			end
		end
		currentclass = "Druid";
		for i=1, GetNumRaidMembers(), 1 do
        	unitid = "raid"..i;
        	local name, realm = UnitName(unitid);
                        if ( UnitClass(unitid) == currentclass ) then
			      tinsert(SnagaLoa_TempList, insertatpos, name);
                              insertatpos = insertatpos+1;
			end
		end		
		currentclass = "Paladin";
		for i=1, GetNumRaidMembers(), 1 do
        	unitid = "raid"..i;
        	local name, realm = UnitName(unitid);
                        if ( UnitClass(unitid) == currentclass ) then
			      tinsert(SnagaLoa_TempList, insertatpos, name);
                              insertatpos = insertatpos+1;
			end
		end
		currentclass = "Shaman";
		for i=1, GetNumRaidMembers(), 1 do
        	unitid = "raid"..i;
        	local name, realm = UnitName(unitid);
			if ( UnitClass(unitid) == currentclass ) then
			      tinsert(SnagaLoa_TempList, insertatpos, name);
                              insertatpos = insertatpos+1;
			end
		end
end
	
function SnagaLoa_Request()
	SendAddonMessage("loacreq", UnitName("player"), "RAID");
end

function SnagaLoa_EditStart()
	SnagaLoa_GenerateBox("edit");
	SnagaLoa_BCoff();
	SnagaLoa_ClearAllLists();
	current2:SetText(UnitName("player"));
	
end


------- PRETTY DONE STUFF -------------------
function SnagaLoa_SetMasterColorM()
	local theclass = UnitClass("player");
			if ( theclass == "Priest" ) then
				return 1,1,1,1;
			elseif ( theclass == "Druid" ) then
				return 1,0.59,0.14,1;
			elseif ( theclass == "Paladin" ) then
				return 1,0.62,0.78,1;
			elseif ( theclass == "Hunter" ) then
				return 0.55,0.71,0.42,1;	
			elseif ( theclass == "Mage" ) then
				return 0.41,0.8,0.94,1;
			elseif ( theclass == "Warlock" ) then
				return 0.48,0.43,0.66,1;
			elseif ( theclass == "Rogue" ) then
				return 1,0.96,0.41,1;
			elseif ( theclass == "Warrior" ) then
				return 0.78,0.61,0.43,1;
			elseif ( theclass == "Shaman" ) then
				return 1,0.62,0.78,1;
			end	
end

function SnagaLoa_SetMasterColorCL()
	for i=1, GetNumRaidMembers() do
		local unitid = "raid"..i;
		local name, realm = UnitName(unitid);
		if ( name == currentmaster ) then
			local theclass = UnitClass(unitid);
			if ( theclass == "Priest" ) then
				return 1,1,1,1;
			elseif ( theclass == "Druid" ) then
				return 1,0.59,0.14,1;
			elseif ( theclass == "Paladin" ) then
				return 1,0.62,0.78,1;
			elseif ( theclass == "Hunter" ) then
				return 0.55,0.71,0.42,1;	
			elseif ( theclass == "Mage" ) then
				return 0.41,0.8,0.94,1;
			elseif ( theclass == "Warlock" ) then
				return 0.48,0.43,0.66,1;
			elseif ( theclass == "Rogue" ) then
				return 1,0.96,0.41,1;
			elseif ( theclass == "Warrior" ) then
				return 0.78,0.61,0.43,1;
			elseif ( theclass == "Shaman" ) then
				return 1,0.62,0.78,1;
			end
		end
	end
end		

function SnagaLoa_SlashHandler(msg)
	
	local command = string.lower(msg);

        if ( command == "on" ) then
             if ( frameshown == 1 ) then
               DEFAULT_CHAT_FRAME:AddMessage("Addon already enabled.");
             else
              if ( GetNumRaidMembers() == 0 ) then
                DEFAULT_CHAT_FRAME:AddMessage("Addon enabled. Will only work in raids.");
                SnagaLoaFrame:Show();
                frameshown = 1;
              else
                SnagaLoaFrame:Show();
                frameshown = 1;
                DEFAULT_CHAT_FRAME:AddMessage("Addon enabled.");
              end
             end
	elseif ( command == "off" ) then
	     if ( frameshown == 0 ) then
	        DEFAULT_CHAT_FRAME:AddMessage("Addon already disabled.");
	     else
		SnagaLoaFrame:Hide();
		frameshown = 0;
		DEFAULT_CHAT_FRAME:AddMessage("Addon disabled.");
             end
	elseif ( command == "help" ) then
	        SnagaLoa_ShowHelp();
	elseif ( command == "master" ) then
		if ( frameshown == 1 ) then
			SnagaLoa_ToggleMasterMode();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Enable the Addon first!");
		end
--	elseif ( command == "lol" ) then
--		for a,b in ipairs(SnagaLoa_Names) do
--		DEFAULT_CHAT_FRAME:AddMessage(a..": "..b);
--		end
--		for c,d in ipairs(SnagaLoa_RaidIds) do
--		DEFAULT_CHAT_FRAME:AddMessage(c..": "..d);
--		end
--		DEFAULT_CHAT_FRAME:AddMessage(table.getn(SnagaLoa_RaidIds));
        else
		DEFAULT_CHAT_FRAME:AddMessage("Try '/loatheb help' for info.");
	end
end


function SnagaLoa_ManualDisable()
--		master = 0;
		frameshown = 0;
--		SnagaLoa_TempList = {};
--		SnagaLoa_Names = {};
--		SnagaLoa_RaidIds = {};
--		SnagaLoa_ClearAllLists();
--		SnagaLoa_SetWindowHeight();
--		SnagaLoa_HideMasterFrames();
                SnagaLoaFrame:Hide();


end


function SnagaLoa_ClearAllLists()
          SnagaLoaText1:SetText("");
          SnagaLoaText2:SetText("");
          SnagaLoaText3:SetText("");
          SnagaLoaText4:SetText("");
          SnagaLoaText5:SetText("");
          SnagaLoaText6:SetText("");
          SnagaLoaText7:SetText("");
          SnagaLoaText8:SetText("");
          SnagaLoaText9:SetText("");
          SnagaLoaText10:SetText("");
          SnagaLoaText11:SetText("");
          SnagaLoaText12:SetText("");
          SnagaLoaText13:SetText("");
          SnagaLoaText14:SetText("");
          SnagaLoaText15:SetText("");
end 

function SnagaLoa_ShowMasterFrames()
	MFX:Show();
	MF1:Show();
	MF2:Show();
	MF3:Show();
	MF4:Show();
	MF5:Show();
	MF6:Show();
	MF7:Show();
	MF8:Show();
	MF9:Show();
	MF10:Show();
	MF11:Show();
	MF12:Show();
	MF13:Show();
	MF14:Show();
	MF15:Show();
end

function SnagaLoa_HideMasterFrames()
	MFX:Hide();
	MF1:Hide();
	MF2:Hide();
	MF3:Hide();
	MF4:Hide();
	MF5:Hide();
	MF6:Hide();
	MF7:Hide();
	MF8:Hide();
	MF9:Hide();
	MF10:Hide();
	MF11:Hide();
	MF12:Hide();
	MF13:Hide();
	MF14:Hide();
	MF15:Hide();
end

function SnagaLoa_ShowHelp()
         DEFAULT_CHAT_FRAME:AddMessage("Commands: '/loatheb on' and '/loatheb off'.");
         DEFAULT_CHAT_FRAME:AddMessage("To move the window, hold SHIFT down before dragging.");
         DEFAULT_CHAT_FRAME:AddMessage("Healers with the Debuff show in the list as red. Dead Players show as gray.");
	 DEFAULT_CHAT_FRAME:AddMessage("To generate the list for the rest of the raid, use '/loatheb master'. If you go offline or leave the raid, use the command again to sign off.");
	 DEFAULT_CHAT_FRAME:AddMessage("Dont go mastermode if someone else already is. Not tested yet.");
end

function SnagaLoa_SetWindowHeight(arg)
--TODO
           local numberofppl = table.getn(SnagaLoa_Names);
           if ( numberofppl == 0 ) then
           	if ( arg ~= "pending" ) then
           	 windowheight = 46;
           	else
           	 windowheight = 69;
           	end
           else
            windowheight = 59+(10*(numberofppl));
           end
           SnagaLoaFrame:SetHeight(windowheight);
end

function SnagaLoa_SetWindowWidth()
		SnagaLoaFrame:SetWidth(108);
end

function SnagaLoa_OnUpdate(elapsed)
     runningtime = runningtime + elapsed; 	
     if ( runningtime > 0.2 ) then
       SnagaLoa_UpdateIds();
       SnagaLoa_UpdateStatus();
       runningtime = 0;
     end

end

function SnagaLoa_UpdateIds()
	if ( not UnitAffectingCombat("player") ) then
		if ( counter == 5 ) then
			if ( generated == 1 ) then
				SnagaLoa_RenewIds();
				counter = 0;
			end
		else
			counter = counter + 1;
		end
	end
end


function SnagaLoa_CheckDebuff(IDToCheck)
                for a=1,16 do
                local t = UnitDebuff(IDToCheck,a);
                if(t == nil) then 
                    break;
                end    
                if ( t == "Interface\\Icons\\Spell_Shadow_AuraOfDarkness" ) then
                    return true;
                end
            end
end



function SnagaLoa_GenerateFirstBox()
	SnagaLoa_GenerateFirstList();
	SnagaLoa_ClearAllLists();
		MFX:Show();
	if ( SnagaLoa_TempList[1] ) then
		MF1:Show();
		M1:SetText(SnagaLoa_TempList[1]);
		M1:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[1]));
	else
		M1:SetText("");
		MF1:Hide();
	end
	if ( SnagaLoa_TempList[2] ) then
		MF2:Show();
		M2:SetText(SnagaLoa_TempList[2]);
		M2:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[2]));
	else
		M2:SetText("");
		MF2:Hide();
	end	
	if ( SnagaLoa_TempList[3] ) then
		MF3:Show();
		M3:SetText(SnagaLoa_TempList[3]);
		M3:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[3]));
	else
		M3:SetText("");
		MF3:Hide();
	end
	if ( SnagaLoa_TempList[4] ) then
		MF4:Show();
		M4:SetText(SnagaLoa_TempList[4]);
		M4:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[4]));
	else
		M4:SetText("");
		MF4:Hide();
	end
	if ( SnagaLoa_TempList[5] ) then
		MF5:Show();
		M5:SetText(SnagaLoa_TempList[5]);
		M5:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[5]));
	else
		M5:SetText("");
		MF5:Hide();
	end
	if ( SnagaLoa_TempList[6] ) then
		MF6:Show();
		M6:SetText(SnagaLoa_TempList[6]);
		M6:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[6]));
	else
		M6:SetText("");
		MF6:Hide();
	end
	if ( SnagaLoa_TempList[7] ) then
		MF7:Show();
		M7:SetText(SnagaLoa_TempList[7]);
		M7:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[7]));
	else
		M7:SetText("");
		MF7:Hide();
	end
	if ( SnagaLoa_TempList[8] ) then
		MF8:Show();
		M8:SetText(SnagaLoa_TempList[8]);
		M8:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[8]));
	else
		M8:SetText("");
		MF8:Hide();
	end
	if ( SnagaLoa_TempList[9] ) then
		MF9:Show();
		M9:SetText(SnagaLoa_TempList[9]);
		M9:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[9]));
	else
		M9:SetText("");
		MF9:Hide();
	end
	if ( SnagaLoa_TempList[10] ) then
		MF10:Show();
		M10:SetText(SnagaLoa_TempList[10]);
		M10:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[10]));
	else
		M10:SetText("");
		MF10:Hide();
	end
	if ( SnagaLoa_TempList[11] ) then
		MF11:Show();
		M11:SetText(SnagaLoa_TempList[11]);
		M11:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[11]));
	else
		M11:SetText("");
		MF11:Hide();
	end
	if ( SnagaLoa_TempList[12] ) then
		MF12:Show();
		M12:SetText(SnagaLoa_TempList[12]);
		M12:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[12]));
	else
		M12:SetText("");
		MF12:Hide();
	end
	if ( SnagaLoa_TempList[13] ) then
		MF13:Show();
		M13:SetText(SnagaLoa_TempList[13]);
		M13:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[13]));
	else
		M13:SetText("");
		MF13:Hide();
	end
	if ( SnagaLoa_TempList[14] ) then
		MF14:Show();
		M14:SetText(SnagaLoa_TempList[14]);
		M14:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[14]));
	else
		M14:SetText("");
		MF14:Hide();
	end
	if ( SnagaLoa_TempList[15] ) then
		MF15:Show();
		M15:SetText(SnagaLoa_TempList[15]);
		M15:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_TempList[15]));
	else
		M15:SetText("");
		MF15:Hide();
	end	
	local amount = table.getn(SnagaLoa_TempList);
	if ( amount == 0 ) then
		MFX:SetHeight(30)
	else
		local newheight = 32+(amount*18);
		MFX:SetHeight(min(302, newheight));
	end
end

function SnagaLoa_IsInRaid(thename)
		local unitids;
		for i=1, GetNumRaidMembers(), 1 do
			unitids = "raid"..i;
			local name, realm = UnitName(unitids);
			if ( name == thename ) then
				return true;
			end
		end
		return false;
end

function SnagaLoa_IsInList(thename)
		for c,d in ipairs(SnagaLoa_NamesSave) do
			if ( d == thename ) then
				return true;
			end
		end
		return false;
end

function SnagaLoa_RedoSaveList()
		local pos = 1;
		while ( pos <= table.getn(SnagaLoa_NamesSave) ) do
			if ( not SnagaLoa_IsInRaid(SnagaLoa_NamesSave[pos]) ) then
				table.remove(SnagaLoa_NamesSave, pos);
			else 
				pos = pos+1;
			end
		end
		local unitid;
                currentclass = "Priest";
		for i=1, GetNumRaidMembers(), 1 do
			unitid = "raid"..i;
			local name, realm = UnitName(unitid);
			if ( UnitClass(unitid) == currentclass ) then
				if ( not SnagaLoa_IsInList(name) ) then
					table.insert(SnagaLoa_NamesSave, pos, name);
					pos = pos+1;
				end
			end
		end
                currentclass = "Druid";
		for i=1, GetNumRaidMembers(), 1 do
			unitid = "raid"..i;
			local name, realm = UnitName(unitid);
			if ( UnitClass(unitid) == currentclass ) then
				if ( not SnagaLoa_IsInList(name) ) then
					table.insert(SnagaLoa_NamesSave, pos, name);
					pos = pos+1;
				end
			end
		end	
		currentclass = "Paladin";
		for i=1, GetNumRaidMembers(), 1 do
			unitid = "raid"..i;
			local name, realm = UnitName(unitid);
			if ( UnitClass(unitid) == currentclass ) then
				if ( not SnagaLoa_IsInList(name) ) then
					table.insert(SnagaLoa_NamesSave, pos, name);
					pos = pos+1;
				end
			end
		end
		currentclass = "Shaman";
		for i=1, GetNumRaidMembers(), 1 do
			unitid = "raid"..i;
			local name, realm = UnitName(unitid);
			if ( UnitClass(unitid) == currentclass ) then
				if ( not SnagaLoa_IsInList(name) ) then
					table.insert(SnagaLoa_NamesSave, pos, name);
					pos = pos+1;
				end
			end
		end
end

function SnagaLoa_GenerateBox(typeok)
	if ( typeok == "edit") then
		SnagaLoa_NamesSave = SnagaLoa_Names;
	end
	SnagaLoa_Names = {};
	SnagaLoa_RaidIds = {};
	SnagaLoa_ClearAllLists();
	SnagaLoa_SetWindowHeight();
	SnagaLoa_RedoSaveList();
		MFX:Show();
	if ( SnagaLoa_NamesSave[1] ) then
		MF1:Show();
		M1:SetText(SnagaLoa_NamesSave[1]);
		M1:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[1]));
	else
		M1:SetText("");
		MF1:Hide();
	end
	if ( SnagaLoa_NamesSave[2] ) then
		MF2:Show();
		M2:SetText(SnagaLoa_NamesSave[2]);
		M2:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[2]));
	else
		M2:SetText("");
		MF2:Hide();
	end	
	if ( SnagaLoa_NamesSave[3] ) then
		MF3:Show();
		M3:SetText(SnagaLoa_NamesSave[3]);
		M3:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[3]));
	else
		M3:SetText("");
		MF3:Hide();
	end
	if ( SnagaLoa_NamesSave[4] ) then
		MF4:Show();
		M4:SetText(SnagaLoa_NamesSave[4]);
		M4:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[4]));
	else
		M4:SetText("");
		MF4:Hide();
	end
	if ( SnagaLoa_NamesSave[5] ) then
		MF5:Show();
		M5:SetText(SnagaLoa_NamesSave[5]);
		M5:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[5]));
	else
		M5:SetText("");
		MF5:Hide();
	end
	if ( SnagaLoa_NamesSave[6] ) then
		MF6:Show();
		M6:SetText(SnagaLoa_NamesSave[6]);
		M6:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[6]));
	else
		M6:SetText("");
		MF6:Hide();
	end
	if ( SnagaLoa_NamesSave[7] ) then
		MF7:Show();
		M7:SetText(SnagaLoa_NamesSave[7]);
		M7:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[7]));
	else
		M7:SetText("");
		MF7:Hide();
	end
	if ( SnagaLoa_NamesSave[8] ) then
		MF8:Show();
		M8:SetText(SnagaLoa_NamesSave[8]);
		M8:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[8]));
	else
		M8:SetText("");
		MF8:Hide();
	end
	if ( SnagaLoa_NamesSave[9] ) then
		MF9:Show();
		M9:SetText(SnagaLoa_NamesSave[9]);
		M9:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[9]));
	else
		M9:SetText("");
		MF9:Hide();
	end
	if ( SnagaLoa_NamesSave[10] ) then
		MF10:Show();
		M10:SetText(SnagaLoa_NamesSave[10]);
		M10:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[10]));
	else
		M10:SetText("");
		MF10:Hide();
	end
	if ( SnagaLoa_NamesSave[11] ) then
		MF11:Show();
		M11:SetText(SnagaLoa_NamesSave[11]);
		M11:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[11]));
	else
		M11:SetText("");
		MF11:Hide();
	end
	if ( SnagaLoa_NamesSave[12] ) then
		MF12:Show();
		M12:SetText(SnagaLoa_NamesSave[12]);
		M12:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[12]));
	else
		M12:SetText("");
		MF12:Hide();
	end
	if ( SnagaLoa_NamesSave[13] ) then
		MF13:Show();
		M13:SetText(SnagaLoa_NamesSave[13]);
		M13:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[13]));
	else
		M13:SetText("");
		MF13:Hide();
	end
	if ( SnagaLoa_NamesSave[14] ) then
		MF14:Show();
		M14:SetText(SnagaLoa_NamesSave[14]);
		M14:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[14]));
	else
		M14:SetText("");
		MF14:Hide();
	end
	if ( SnagaLoa_NamesSave[15] ) then
		MF15:Show();
		M15:SetText(SnagaLoa_NamesSave[15]);
		M15:SetTextColor(SnagaLoa_DecodeColor(SnagaLoa_NamesSave[15]));
	else
		M15:SetText("");
		MF15:Hide();
	end	
	local amount = table.getn(SnagaLoa_NamesSave);
	if ( amount == 0 ) then
		MFX:SetHeight(30);
	else
		local newheight = 32+(amount*18);
		MFX:SetHeight(newheight);
	end
end

function SnagaLoa_UpdateStatus()
	if ( SnagaLoa_Names[1] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[1]) ) then
			SnagaLoaText1:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[1]) ) then
			SnagaLoaText1:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[1]) == "Priest" ) then
				SnagaLoaText1:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[1]) == "Druid" ) then
				SnagaLoaText1:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText1:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[2] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[2]) ) then
			SnagaLoaText2:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[2]) ) then
			SnagaLoaText2:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[2]) == "Priest" ) then
				SnagaLoaText2:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[2]) == "Druid" ) then
				SnagaLoaText2:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText2:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[3] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[3]) ) then
			SnagaLoaText3:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[3]) ) then
			SnagaLoaText3:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[3]) == "Priest" ) then
				SnagaLoaText3:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[3]) == "Druid" ) then
				SnagaLoaText3:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText3:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[4] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[4]) ) then
			SnagaLoaText4:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[4]) ) then
			SnagaLoaText4:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[4]) == "Priest" ) then
				SnagaLoaText4:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[4]) == "Druid" ) then
				SnagaLoaText4:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText4:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[5] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[5]) ) then
			SnagaLoaText5:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[5]) ) then
			SnagaLoaText5:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[5]) == "Priest" ) then
				SnagaLoaText5:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[5]) == "Druid" ) then
				SnagaLoaText5:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText5:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[6] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[6]) ) then
			SnagaLoaText6:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[6]) ) then
			SnagaLoaText6:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[6]) == "Priest" ) then
				SnagaLoaText6:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[6]) == "Druid" ) then
				SnagaLoaText6:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText6:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[7] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[7]) ) then
			SnagaLoaText7:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[7]) ) then
			SnagaLoaText7:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[7]) == "Priest" ) then
				SnagaLoaText7:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[7]) == "Druid" ) then
				SnagaLoaText7:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText7:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[8] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[8]) ) then
			SnagaLoaText8:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[8]) ) then
			SnagaLoaText8:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[8]) == "Priest" ) then
				SnagaLoaText8:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[8]) == "Druid" ) then
				SnagaLoaText8:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText8:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[9] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[9]) ) then
			SnagaLoaText9:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[9]) ) then
			SnagaLoaText9:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[9]) == "Priest" ) then
				SnagaLoaText9:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[9]) == "Druid" ) then
				SnagaLoaText9:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText9:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[10] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[10]) ) then
			SnagaLoaText10:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[10]) ) then
			SnagaLoaText10:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[10]) == "Priest" ) then
				SnagaLoaText10:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[10]) == "Druid" ) then
				SnagaLoaText10:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText10:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[11] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[11]) ) then
			SnagaLoaText11:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[11]) ) then
			SnagaLoaText11:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[11]) == "Priest" ) then
				SnagaLoaText11:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[11]) == "Druid" ) then
				SnagaLoaText11:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText11:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[12] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[12]) ) then
			SnagaLoaText12:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[12]) ) then
			SnagaLoaText12:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[12]) == "Priest" ) then
				SnagaLoaText12:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[12]) == "Druid" ) then
				SnagaLoaText12:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText12:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[13] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[13]) ) then
			SnagaLoaText13:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[13]) ) then
			SnagaLoaText13:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[13]) == "Priest" ) then
				SnagaLoaText13:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[13]) == "Druid" ) then
				SnagaLoaText13:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText13:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[14] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[14]) ) then
			SnagaLoaText14:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[14]) ) then
			SnagaLoaText14:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[14]) == "Priest" ) then
				SnagaLoaText14:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[14]) == "Druid" ) then
				SnagaLoaText14:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText14:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
	if ( SnagaLoa_Names[15] ) then
		if ( UnitIsDeadOrGhost(SnagaLoa_RaidIds[15]) ) then
			SnagaLoaText15:SetTextColor(0.4,0.4,0.4,1);
		elseif ( SnagaLoa_CheckDebuff(SnagaLoa_RaidIds[15]) ) then
			SnagaLoaText15:SetTextColor(0.7,0,0,1);
		else 
			if ( UnitClass(SnagaLoa_RaidIds[15]) == "Priest" ) then
				SnagaLoaText15:SetTextColor(1,1,1,1);
			elseif ( UnitClass(SnagaLoa_RaidIds[15]) == "Druid" ) then
				SnagaLoaText15:SetTextColor(1,0.59,0.14,1);
			else 
				SnagaLoaText15:SetTextColor(1,0.62,0.78,1);
			end
		end	
	end
end	

function SnagaLoa_DoText()
	if ( SnagaLoa_Names[1] ) then
	SnagaLoaText1:SetText(SnagaLoa_Names[1]);
		if ( UnitClass(SnagaLoa_RaidIds[1]) == "Priest" ) then
			SnagaLoaText1:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[1]) == "Druid" ) then
			SnagaLoaText1:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText1:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText1:SetText("");
	end
	if ( SnagaLoa_Names[2] ) then
	SnagaLoaText2:SetText(SnagaLoa_Names[2]);
		if ( UnitClass(SnagaLoa_RaidIds[2]) == "Priest" ) then
			SnagaLoaText2:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[2]) == "Druid" ) then
			SnagaLoaText2:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText2:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText2:SetText("");
	end
	if ( SnagaLoa_Names[3] ) then
	SnagaLoaText3:SetText(SnagaLoa_Names[3]);
		if ( UnitClass(SnagaLoa_RaidIds[3]) == "Priest" ) then
			SnagaLoaText3:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[3]) == "Druid" ) then
			SnagaLoaText3:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText3:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText3:SetText("");
	end	
	if ( SnagaLoa_Names[4] ) then
	SnagaLoaText4:SetText(SnagaLoa_Names[4]);
		if ( UnitClass(SnagaLoa_RaidIds[4]) == "Priest" ) then
			SnagaLoaText4:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[4]) == "Druid" ) then
			SnagaLoaText4:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText4:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText4:SetText("");
	end
	if ( SnagaLoa_Names[5] ) then
	SnagaLoaText5:SetText(SnagaLoa_Names[5]);
		if ( UnitClass(SnagaLoa_RaidIds[5]) == "Priest" ) then
			SnagaLoaText5:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[5]) == "Druid" ) then
			SnagaLoaText5:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText5:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText5:SetText("");
	end
	if ( SnagaLoa_Names[6] ) then
	SnagaLoaText6:SetText(SnagaLoa_Names[6]);
		if ( UnitClass(SnagaLoa_RaidIds[6]) == "Priest" ) then
			SnagaLoaText6:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[6]) == "Druid" ) then
			SnagaLoaText6:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText6:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText6:SetText("");
	end
	if ( SnagaLoa_Names[7] ) then
	SnagaLoaText7:SetText(SnagaLoa_Names[7]);
		if ( UnitClass(SnagaLoa_RaidIds[7]) == "Priest" ) then
			SnagaLoaText7:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[7]) == "Druid" ) then
			SnagaLoaText7:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText7:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText7:SetText("");
	end
	if ( SnagaLoa_Names[8] ) then
	SnagaLoaText8:SetText(SnagaLoa_Names[8]);
		if ( UnitClass(SnagaLoa_RaidIds[8]) == "Priest" ) then
			SnagaLoaText8:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[8]) == "Druid" ) then
			SnagaLoaText8:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText8:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText8:SetText("");
	end
	if ( SnagaLoa_Names[9] ) then
	SnagaLoaText9:SetText(SnagaLoa_Names[9]);
		if ( UnitClass(SnagaLoa_RaidIds[9]) == "Priest" ) then
			SnagaLoaText9:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[9]) == "Druid" ) then
			SnagaLoaText9:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText9:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText9:SetText("");
	end
	if ( SnagaLoa_Names[10] ) then
	SnagaLoaText10:SetText(SnagaLoa_Names[10]);
		if ( UnitClass(SnagaLoa_RaidIds[10]) == "Priest" ) then
			SnagaLoaText10:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[10]) == "Druid" ) then
			SnagaLoaText10:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText10:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText10:SetText("");
	end
	if ( SnagaLoa_Names[11] ) then
	SnagaLoaText11:SetText(SnagaLoa_Names[11]);
		if ( UnitClass(SnagaLoa_RaidIds[11]) == "Priest" ) then
			SnagaLoaText11:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[11]) == "Druid" ) then
			SnagaLoaText11:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText11:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText11:SetText("");
	end
	if ( SnagaLoa_Names[12] ) then
	SnagaLoaText12:SetText(SnagaLoa_Names[12]);
		if ( UnitClass(SnagaLoa_RaidIds[12]) == "Priest" ) then
			SnagaLoaText12:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[12]) == "Druid" ) then
			SnagaLoaText12:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText12:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText12:SetText("");
	end	
	if ( SnagaLoa_Names[13] ) then
	SnagaLoaText13:SetText(SnagaLoa_Names[13]);
		if ( UnitClass(SnagaLoa_RaidIds[13]) == "Priest" ) then
			SnagaLoaText13:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[13]) == "Druid" ) then
			SnagaLoaText13:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText13:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText13:SetText("");
	end
	if ( SnagaLoa_Names[14] ) then
	SnagaLoaText14:SetText(SnagaLoa_Names[14]);
		if ( UnitClass(SnagaLoa_RaidIds[14]) == "Priest" ) then
			SnagaLoaText14:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[14]) == "Druid" ) then
			SnagaLoaText14:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText14:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText14:SetText("");
	end
	if ( SnagaLoa_Names[15] ) then
	SnagaLoaText15:SetText(SnagaLoa_Names[15]);
		if ( UnitClass(SnagaLoa_RaidIds[15]) == "Priest" ) then
			SnagaLoaText15:SetTextColor(1,1,1,1);
		elseif ( UnitClass(SnagaLoa_RaidIds[15]) == "Druid" ) then
			SnagaLoaText15:SetTextColor(1,0.59,0.14,1);
		else 
			SnagaLoaText15:SetTextColor(1,0.62,0.78,1);
		end
	else SnagaLoaText15:SetText("");
	end	
end

function SnagaLoa_DecodeColor(ar)
	for i=1, GetNumRaidMembers() do
		local unitid = "raid"..i;
		local name, realm = UnitName(unitid);
		if ( name == ar ) then
			local theclass = UnitClass(unitid);
			if ( theclass == "Priest" ) then
				return 1,1,1,1;
			elseif ( theclass == "Druid" ) then
				return 1,0.59,0.14,1;
			elseif ( theclass == "Paladin" ) then
				return 1,0.62,0.78,1;
			elseif ( theclass == "Shaman" ) then
				return 1,0.62,0.78,1;
			else
				return 1,0,0,1;
			end	
		end
	end
end