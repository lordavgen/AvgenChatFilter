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

local options = { 
    name = "Авген Чат Фильтр",
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
        enable4 = {
            name = "Торговец Даларана",
			desc = "Упрощает закупку ресурсами, у торговца в Даларане.",
			type = "toggle",
            get = "GetDalaranMerchantFix",
            set = "SetDalaranMerchantFix",
        },
        enable5 = {
            name = "Короткие имена ключей",
			desc = "пример: 'Ключ: Чаща Темного Сердца'\n'Ключ: ЧТС'.",
			type = "toggle",
            get = "GetShortKeyName",
            set = "SetShortKeyName",
        },
        enable6 = {
            name = "Шепот гильдии",
			desc = "Фиксирует шепот только по имени, без реалма.",
			type = "toggle",
            get = "GetGuildWispFix",
            set = "SetGuildWispFix",
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
 		self:SetText(tostring(itemcount))
		StaticPopup1Text:SetText("Сколько вы хотите купить?")
		
		local setitemcount = FIXkuzumap_Popup:GetNumber()
		local x,y = math.modf(setitemcount/itemcount)
		if x == 0 or y ~= 0 then
			x = x + 1
		end
		locbd.merch.ItemCount = itemcount
		locbd.merch.ItemName = StaticPopup1ItemFrameText:GetText()
		locbd.merch.CostBay = x
		FIXkuzumap_Popup.text_right:SetText(" = " .. tostring(x) .. " x |cff0070dd[Кровь Саргераса]|r")
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
		local x,y = math.modf(setitemcount/itemcount)
		if x == 0 or y ~= 0 then
			x = x + 1
		end
		locbd.merch.ItemCount = itemcount
		locbd.merch.ItemName = StaticPopup1ItemFrameText:GetText()
		locbd.merch.CostBay = x
		FIXkuzumap_Popup.text_right:SetText(" = " .. tostring(x) .. " x |cff0070dd|Hitem:124124::::::::110:65:512:::110:::|h[Кровь Саргераса]|h|r")
 		
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
									BuyMerchantItem(i,locbd.merch.ItemCount)
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
