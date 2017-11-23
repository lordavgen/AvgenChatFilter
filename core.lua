--
-- Аддон для World of warcraft
-- AvgenChatFilter
-- Автор: Авген
--
local addon = LibStub("AceAddon-3.0"):NewAddon("AvgenChatFilter","AceConsole-3.0","AceEvent-3.0")

--// Подготовка
local MyModData = {}
local defaultsBD = {
	profile = {
		settings = {
			KeyFix = true,
			shortkeyname = true,
			HideServerAnons = true,
			HideGoldSellersInWisp = true,
			FindTextInChat = true,
			DalaranMerchantFix = true,
			GuildWispFix = true,
			SellBood = false,
		},
	}
}
local locbd = {
	serveranons = {
		"Autobroadcast",
		"Анонс БГ",
		"В личном кабинете",
	},
	badWords = {
		"{круг}",
		"продам золото",
		"продажа золота",
		"Продажа золота",
		"Skype exit291988",
		"Продажа.золота",
		"продаже золота",
		"Продажа золoта",
		"wow_gold77"
	},
	findStrings = {
		"ИК",
		"Ик",
		"иК",
		"ппг",
		"ППГ",
		"ппгер",
		"пп гер",
	},
	sokr = {
		["Ключ: Утроба душ"] = "Ключ: УД",
		["Ключ: Казематы Стражей"] = "Ключ: КС",
		["Ключ: Око Азшары"] = "Ключ: Око",
		["Ключ: Логово Нелтариона"] = "Ключ: ЛН",
		["Ключ: Чертоги Доблести"] = "Ключ: ЧД",
		["Ключ: Чаща Темного Сердца"] = "Ключ: ЧТС",
		["Ключ: Крепость Черной Ладьи"] = "Ключ: КЧЛ",
	},
	CKLIM = {
		name = nil,
		txt1 = nil,
		txt2 = nil,
		newname = nil,
	},
	FTIM = {
		srtartS = nil,
	},
	merch = {
		CostBay = nil,
		ItemCount = nil,
		ItemName = nil,
	},
}
local tipscan = CreateFrame("GameTooltip", "TooltipScanKey",nil,"GameTooltipTemplate")
local receptscan = CreateFrame("GameTooltip", "TooltipReceptScan",nil,"GameTooltipTemplate")

local options = { 
    name = "Авген Чат Фильтр",
    handler = addon,
    type = "group",
    args = {
		tradedalaran = {
			name = "Торговец Даларана",
			handler = addon,
			type = "group",
			args = {
				enable1 = {
					name = "Включить",
					desc = "Упрощает закупку ресурсами, у торговца в Даларане.",
					type = "toggle",
					get = "GetDalaranMerchantFix",
					set = "SetDalaranMerchantFix",
				},
				enable2 = {
					name = "Продавать кровь",
					desc = "Меняет логику обмена.\nТеперь вы указываете сколько обменять крови, а не сколько купить предметов.",
					type = "toggle",
					get = "GetSellBood",
					set = "SetSellBood",
				},
			}
		},
		chatfunc = {
			name = "Функции чата",
			handler = addon,
			type = "group",
			args = {
				enable = {
					name = "Мифические ключи",
					desc = "Исправляет отображение мифических ключей.",
					type = "toggle",
					get = "GetKeyFix",
					set = "SetKeyFix",
				},
				enable5 = {
					name = "Короткие имена ключей",
					desc = "пример: 'Ключ: Чаща Темного Сердца'\n'Ключ: ЧТС'.",
					type = "toggle",
					get = "GetShortKeyName",
					set = "SetShortKeyName",
				},
				enable1 = {
					name = "Анонсы сервера",
					desc = "Скрывает анонсы сервера (Анонс бг,Autobroadcast).",
					type = "toggle",
					get = "GetHideServerAnons",
					set = "SetHideServerAnons",
				},
				enable2 = {
					name = "Торговцы золотом",
					desc = "Скрывает личные сообщения торговцев золотом.",
					type = "toggle",
					get = "GetHideGoldSellersInWisp",
					set = "SetHideGoldSellersInWisp",
				},
				enable3 = {
					name = "Подсвечивать слова",
					desc = "Подсвечивает слова ппг, ИК.\nИзменение слов в разработке.",
					type = "toggle",
					get = "GetFindTextInChat",
					set = "SetFindTextInChat",
				},
				enable6 = {
					name = "Шепот гильдии",
					desc = "Фиксирует шепот только по имени, без реалма.",
					type = "toggle",
					get = "GetGuildWispFix",
					set = "SetGuildWispFix",
				},
			}
		},
    },
}
--\\ Конец подготовки

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New("AvgenChatFilterDB",defaultsBD)
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("AvgenChatFilter", options)
	addon.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AvgenChatFilter", "Авген Чат Фильтр")
end

function addon:OnEnable()
	if self.db.profile.optionA then
		self.db.profile.playerName = UnitName("player")
	end
	
	addon:RegisterChatCommand("купить", "Commands")
	addon:RegisterChatCommand("tes", "Commands")
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", addon.AvgenChatFilter)
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL",addon.FindTextInMessage)
	
	hooksecurefunc("ChatEdit_InsertLink",addon.Ahook_ChatEdit_OnUpdate)
	hooksecurefunc("ChatEdit_UpdateHeader",addon.Ahook_ChatFrame_SendTell)
	
	addon:_merchantmod_ed()
end

function addon:OnDisable()
    -- Called when the addon is disabled
end

function addon.FindTextInMessage(_, _, message, ...)
	if addon.db.profile.settings.FindTextInChat then
		locbd.CKLIM.srtartS = nil
		for _, word in ipairs(locbd.findStrings) do
			locbd.CKLIM.srtartS = nil
			locbd.CKLIM.srtartS = message:find(word,1,true)
			if locbd.CKLIM.srtartS then
				PlaySound("AuctionWindowOpen")
				return false, message:gsub(word,string.format("|cffFF5400%s|r",tostring(word))), ...
			end
		end
	end
	return false
end

local function CorrectKeyNameLink(x)
	tipscan:SetOwner(UIParent, "CENTER")
	tipscan:SetHyperlink(x)
	tipscan:Show()
	locbd.CKLIM.name = nil
	locbd.CKLIM.txt1 = nil
	locbd.CKLIM.txt2 = nil
	locbd.CKLIM.name = _G['TooltipScanKeyTextLeft1']:GetText()
	locbd.CKLIM.txt1 = _G['TooltipScanKeyTextLeft2']:GetText()
	locbd.CKLIM.txt2 = _G['TooltipScanKeyTextLeft3']:GetText()
	tipscan:Hide()
	
	if locbd.CKLIM.name then
		if locbd.CKLIM.txt1 then
			locbd.CKLIM.newname = locbd.CKLIM.name
			if addon.db.profile.settings.shortkeyname then
				locbd.CKLIM.newname = locbd.sokr[locbd.CKLIM.name] or locbd.CKLIM.name
			end
			if locbd.CKLIM.txt1 == "Израсходован" then
				x = x:gsub('(%[.-%])', '['..locbd.CKLIM.newname..' '..locbd.CKLIM.txt2:match('%d+')..']')
				return x:gsub('(|c.-|H)', "|cff7E7E7E|H")
			else
				return x:gsub('(%[.-%])', '['..locbd.CKLIM.newname..' '..locbd.CKLIM.txt1:match('%d+')..']')
			end
		end
	end
	return x
end

function addon.Ahook_ChatEdit_OnUpdate(text)
	if addon.db.profile.settings.KeyFix then
		local editframe = ChatEdit_GetActiveWindow()
		if editframe then
			local text = editframe:GetText()
			if text then
				editframe:SetText(text:gsub('(|c........|Hitem:138019.*|h|r)', CorrectKeyNameLink))
			end
		end
	end
end

function addon.Ahook_ChatFrame_SendTell(text)
	if addon.db.profile.settings.GuildWispFix then
		local f = ChatEdit_GetActiveWindow()
		if f then
			if f:GetAttribute("chatType") == "WHISPER" then
				local name = (_G[f:GetName().."Header"]:GetText()):match('.- (.+)-')
				if name then
					ChatFrame_SendTell(name) 
				end
			end
		end
	end
end

function addon:_merchantmod_ed()

 	local _e_b = CreateFrame('EditBox', 'FIXkuzumap_Popup', StaticPopup1, "InputBoxTemplate")
 	_e_b:SetWidth(30)
 	_e_b:SetHeight(20)
 	_e_b:SetPoint('CENTER',-60,25)
 	_e_b:SetMaxLetters(3)
 	_e_b:SetNumeric(true)
 	_e_b:SetAutoFocus(false)
 	_e_b:SetCursorPosition(0)
 	
 	_e_b:SetScript("OnShow",function(self)
		local itemcount
		if StaticPopup1ItemFrameCount:IsVisible() then
			itemcount = tonumber(StaticPopup1ItemFrameCount:GetText()) or 1
		else
			itemcount = 1
		end
 		
		if addon.db.profile.settings.SellBood then
			StaticPopup1Text:SetText("Сколько |cff0070dd[Кровь Саргераса]|r обменять?")
			self:SetText(1)
			locbd.merch.ItemCount = itemcount
			locbd.merch.ItemName = StaticPopup1ItemFrameText:GetText()
			locbd.merch.CostBay = 1
			FIXkuzumap_Popup.text_right:SetText(" = " .. tostring(itemcount) .. " предметов.")
		else
			StaticPopup1Text:SetText("Сколько вы хотите купить?")
			self:SetText(tostring(itemcount))
			
			local setitemcount = FIXkuzumap_Popup:GetNumber()
			local x,y = math.modf(setitemcount/itemcount)
			if x == 0 or y ~= 0 then
				x = x + 1
			end
			locbd.merch.ItemCount = itemcount
			locbd.merch.ItemName = StaticPopup1ItemFrameText:GetText()
			locbd.merch.CostBay = x
			FIXkuzumap_Popup.text_right:SetText(" = " .. tostring(x) .. " x |cff0070dd[Кровь Саргераса]|r")
		end
		
		
		FIXkuzumap_Popup:SetFocus()
 	end)
 	
 	_e_b:SetScript("OnChar",function(self, key)
 		
		local itemcount
		if StaticPopup1ItemFrameCount:IsVisible() then
			itemcount = tonumber(StaticPopup1ItemFrameCount:GetText()) or 1
		else
			itemcount = 1
		end
		local setitemcount = FIXkuzumap_Popup:GetNumber()
		if addon.db.profile.settings.SellBood then
			locbd.merch.ItemCount = itemcount
			locbd.merch.ItemName = StaticPopup1ItemFrameText:GetText()
			locbd.merch.CostBay = setitemcount
			FIXkuzumap_Popup.text_right:SetText(" = " .. tostring(itemcount*setitemcount) .. " предметов.")
		else
			local x,y = math.modf(setitemcount/itemcount)
			if x == 0 or y ~= 0 then
				x = x + 1
			end
			locbd.merch.ItemCount = itemcount
			locbd.merch.ItemName = StaticPopup1ItemFrameText:GetText()
			locbd.merch.CostBay = x
			FIXkuzumap_Popup.text_right:SetText(" = " .. tostring(x) .. " x |cff0070dd[Кровь Саргераса]|r")
		end
 		
 	end)
 	
 	_e_b:SetScript("OnKeyDown",function(self, key)
 		if key == 'ENTER' then
 			StaticPopup1Button1:Click()
 		end
 	end)
 	
 	_e_b.text_right = _e_b:CreateFontString()
 	_e_b.text_right:SetPoint("LEFT", _e_b,"LEFT", 10, 0)
 	_e_b.text_right:SetSize(200, 20)
 	_e_b.text_right:SetFont("Fonts\\ARIALN.TTF", 14)
 	_e_b:Hide()
	
	StaticPopup1:HookScript("OnShow", function(self)
		if addon.db.profile.settings.DalaranMerchantFix then
			local sttext = StaticPopup1Text:GetText()
			if sttext:match("Hitem:124124") then
				FIXkuzumap_Popup:Show()
			end
		end
	end)

	StaticPopup1:HookScript("OnHide", function(self)
		if addon.db.profile.settings.DalaranMerchantFix then
			FIXkuzumap_Popup:Hide()
		end
	end)

	StaticPopup1Button1:HookScript("OnClick", function(self)
		if addon.db.profile.settings.DalaranMerchantFix then
			
			if locbd.merch.CostBay then
				
				if locbd.merch.ItemCount and locbd.merch.ItemName then
					if locbd.merch.CostBay > 1 then
						for i=1,100 do 
							if locbd.merch.ItemName == GetMerchantItemInfo(i) then 
								for g=1, locbd.merch.CostBay-1 do 
									BuyMerchantItem(i)
								end
								locbd.merch.CostBay = nil
								locbd.merch.ItemName = nil
								locbd.merch.ItemCount = nil
								break
							end
						end
					end
				end
			end
		end
	end)
end

function addon.AvgenChatFilter(frame, event, message, ...)
    if event == "CHAT_MSG_SYSTEM" then
		if addon.db.profile.settings.HideServerAnons then
			for _, word in ipairs(locbd.serveranons) do
				if message:find(word,1,true) then
					return true
				end
			end
		end
	elseif event == "CHAT_MSG_WHISPER" then
		if addon.db.profile.settings.HideGoldSellersInWisp then
			for _, word in ipairs(locbd.badWords) do
				if message:find(word,1,true) then
					return true
				end
			end
		end
	end
	if addon.db.profile.settings.KeyFix then
		if message:match("Hitem:138019") then
			return false, message:gsub('(|c........|Hitem:138019.*|h|r)', CorrectKeyNameLink), ...
		end
	end
	return false
end

function addon.asplit(str , razd)
	local tab = {}
	for i in string.gmatch(str, "([^"..razd.."]+)") do
	   table.insert(tab, i)
	end
	return tab
end

function addon:Commands(arg)
	local link = arg:match('(|c........|Henchant:.*|h|r)')
	local mult = arg:match('|r%s(%d+)') or 1
	
	local CountBloodInBags = addon:GetCountItemInBags("Кровь Саргераса") 
	local tradename = 'Илнея Кровавый Шип'
	local Treagents = addon:GetReagents(link)
	
	if Treagents and MerchantNameText and MerchantNameText:IsVisible() then
		if tradename == MerchantNameText:GetText() then
			local Tquantity = {}
			for i=1, GetMerchantNumItems() do
				local name, _, _, quantity = GetMerchantItemInfo(i)
				
				for _, reg in ipairs(Treagents) do
					if reg.name == name then 
						Tquantity[name] = quantity or 0
					end
				end
			end
			
			local Nmult = addon:NormalizeMultiple(Treagents,Tquantity,mult,CountBloodInBags)
			
			local a,b = 0,0
			for _, reg in ipairs(Treagents) do
				b = 0
				if Tquantity[reg.name] then
					if tonumber(Tquantity[reg.name]) > 0 then
						b = ((tonumber(reg.count*Nmult)) /tonumber(Tquantity[reg.name]) )
						b,y = math.modf(b)
						if b == 0 or y ~= 0 then
							b = b + 1
						end
					end
				end
				addon:BuyItem(reg.name,b)
				print(string.format('\'%s\'x%d(%d) = %d',tostring(reg.name),tostring(reg.count),tostring(Tquantity[reg.name]),tostring(b)))
				a = a + b
			end
			print('|cff0C71F5Всего надо|r '.. a .. ' |cff0C71F5Крови саргераса.|r')
		else
			print(string.format("|cff0C71F5%s|r: %s",tostring('Даларанский торговец'),tostring("Нужен торговец с именем \'"..tradename..'\'.')))
		end
	else
		print(string.format("|cff0C71F5%s|r: %s",tostring('Даларанский торговец'),tostring("Реагентов в рецепте не найдено или окно торговца не открыто.")))
	end
end

function addon:GetReagents(link)
	if link:match("Henchant:") then
		receptscan:SetOwner(UIParent, "ANCHOR_NONE")
		receptscan:SetHyperlink(link)
		receptscan:Show()
		
		local regi = _G['TooltipReceptScanTextLeft2']:GetText():match('.*:(.*)') or nil
		receptscan:Hide()
		local tab = {}
		if regi then
			for reg in string.gmatch(regi,"([^,]+)") do
				
				local a = string.find(reg, "%n")
				if a then
					reg = string.sub(reg, a+1,string.len(reg))
				end
				reg = reg:match('%s*(.*)')
				
				namenocolor = reg:match('|c........(.*)|r') or reg
				name = namenocolor:match('(.*)%s+%(') or namenocolor
				num = reg:match('%((%d+)%)') or 1
				
				table.insert(tab,{name = name, count = num})
				
			end
			return tab
		end
	end
	return nil
end

function addon:GetCountItemInBags(itemname)
	local IC = 0
	for b=0,4 do
		for s=1,GetContainerNumSlots(b) do
			_, count, _, _, _, _, link = GetContainerItemInfo(b,s)
			if link then
				if itemname == select(1, GetItemInfo(link)) then
					IC = IC + count
				end
			end
		end
	end
	return IC
end

function addon:NormalizeMultiple(Treagents,Tquantity,mult,CountBloodInBags)
	local b = 0
	local a = 0
	local mult = mult
	local fix = 0
	while true do
		-- print(string.format("|cffFF5400%s|r: %s",tostring('mult'),tostring(mult)))
		fix =fix + 1
		a = 0
		for _, reg in ipairs(Treagents) do
			b = 0
			x = 0
			y = 0
			if Tquantity[reg.name] then
				if tonumber(Tquantity[reg.name]) > 0 then
					
					b = ((tonumber(reg.count)*mult) /tonumber(Tquantity[reg.name]))
					x,y = math.modf(b)
					if x == 0 or y ~= 0 then
						x = x + 1
					end
				end
			end
			-- print(string.format("|cffFF5400%s|r: %s",tostring('x'),tostring(x)))
			a = a + x
			-- print(string.format("|cffFF5400%s|r: %s",tostring('a'),tostring(a)))
		end
		
		if fix > 200 then return nil end
		if a < CountBloodInBags then break else mult = mult - 1 end
	end
	return mult
end

function addon:BuyItem(itemname,countBuy)
	for i=1,GetMerchantNumItems() do
		if itemname == GetMerchantItemInfo(i) then 
			for g=1, countBuy do 
				BuyMerchantItem(i)
			end
			break
		end
	end
end

function addon:F_Blank()
	
end

-- Найстройки
function addon:GetKeyFix(info)
    return addon.db.profile.settings.KeyFix
end

function addon:SetKeyFix(info, newValue)
    addon.db.profile.settings.KeyFix = newValue
end

function addon:GetHideServerAnons(info)
    return addon.db.profile.settings.HideServerAnons
end

function addon:SetHideServerAnons(info, newValue)
    addon.db.profile.settings.HideServerAnons = newValue
end

function addon:GetHideGoldSellersInWisp(info)
    return addon.db.profile.settings.HideGoldSellersInWisp
end

function addon:SetHideGoldSellersInWisp(info, newValue)
    addon.db.profile.settings.HideGoldSellersInWisp = newValue
end

function addon:GetFindTextInChat(info)
    return addon.db.profile.settings.FindTextInChat
end

function addon:SetFindTextInChat(info, newValue)
    addon.db.profile.settings.FindTextInChat = newValue
end

function addon:GetDalaranMerchantFix(info)
    return addon.db.profile.settings.DalaranMerchantFix
end

function addon:SetDalaranMerchantFix(info, newValue)
    addon.db.profile.settings.DalaranMerchantFix = newValue
end

function addon:GetShortKeyName(info)
    return addon.db.profile.settings.shortkeyname
end

function addon:SetShortKeyName(info, newValue)
    addon.db.profile.settings.shortkeyname = newValue
end

function addon:GetGuildWispFix(info)
    return addon.db.profile.settings.GuildWispFix
end

function addon:SetGuildWispFix(info, newValue)
	addon.db.profile.settings.GuildWispFix = newValue
end

function addon:GetSellBood(info)
    return addon.db.profile.settings.SellBood
end

function addon:SetSellBood(info, newValue)
	addon.db.profile.settings.SellBood = newValue
end
