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
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", addon.AvgenChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", addon.AvgenChatFilter)
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL",addon.FindTextInMessage)
	
	hooksecurefunc("ChatEdit_InsertLink",addon.Ahook_ChatEdit_OnUpdate)
	
	addon:_merchantmod_ed()
end

function addon:OnDisable()
    -- Called when the addon is disabled
end

function addon.FindTextInMessage(_, _, message, ...)
	if addon.db.profile.settings.FindTextInChat then
		local srtartS, endS = nil, nil
		for _, word in ipairs(locbd.findStrings) do
			srtartS, endS = nil, nil
			srtartS, endS = message:find(word,1,true)
			if srtartS then
				local newmessage = message:gsub(word,string.format("|cffFF5400%s|r",tostring(word)))
				PlaySound("AuctionWindowOpen")
				return false, newmessage, ...
			end
		end
	end
	return false
end

local function CorrectKeyLinkInMessage(message)
    if message:match("Hitem:138019") then
	
		local link = message:match("|c........|Hitem:138019.*|h|r")
		tipscan:SetOwner(UIParent, "ANCHOR_NONE")
		tipscan:SetHyperlink(link)
		tipscan:Show()
		local name = _G['TooltipScanKeyTextLeft1']:GetText()
		local txt1 = _G['TooltipScanKeyTextLeft2']:GetText()
		local txt2 = _G['TooltipScanKeyTextLeft3']:GetText()
		tipscan:Hide()
		
		if name then
			if txt1 then
				local newname = name
				if addon.db.profile.settings.shortkeyname then
					newname = locbd.sokr[name] or name
				end
				if txt1 == "Израсходован" then
					newmessage = message:gsub(link:match("%[(.+)%]"), newname..' '..txt2:match('%d+'))
					return newmessage:gsub(link:match("|c(.*)|H"), "ff7E7E7E")
				else
					return message:gsub(link:match("%[(.+)%]"), newname ..' '..txt1:match('%d+'))
				end
			end
		else
			return message
		end
    end
	return message
end

function addon.Ahook_ChatEdit_OnUpdate(text)
	if addon.db.profile.settings.KeyFix then
		local editframe = ChatEdit_GetActiveWindow()
		if editframe then
			local text = editframe:GetText()
			if text then
				editframe:SetText(CorrectKeyLinkInMessage(text))
			end
		end
	end
end

function addon:_merchantmod_ed()

 	local itemcount

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
			itemcount = tonumber(StaticPopup1ItemFrameCount:GetText())
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
		FIXkuzumap_Popup.text_right:SetText(" = " .. tostring(x) .. " x |cff0070dd|Hitem:124124::::::::110:65:512:::110:::|h[Кровь Саргераса]|h|r")
		FIXkuzumap_Popup:SetFocus()
 	end)
 	
 	_e_b:SetScript("OnChar",function(self, key)
 		
		local itemcount = tonumber(StaticPopup1ItemFrameCount:GetText()) or 1
		local setitemcount = FIXkuzumap_Popup:GetNumber()
		local x,y = math.modf(setitemcount/itemcount)
		if x == 0 or y ~= 0 then
			x = x + 1
		end
		FIXkuzumap_Popup.text_right:SetText(" = " .. tostring(x) .. " x |cff0070dd|Hitem:124124::::::::110:65:512:::110:::|h[Кровь Саргераса]|h|r")
 		
 	end)
 	
 	_e_b:SetScript("OnKeyDown",function(self, key)
 		
		-- local itemcount = tonumber(StaticPopup1ItemFrameCount:GetText()) or 1
		-- local setitemcount = FIXkuzumap_Popup:GetNumber()
		-- local x,y = math.modf(setitemcount/itemcount)
		-- if x == 0 or y ~= 0 then
			-- x = x + 1
		-- end
		-- FIXkuzumap_Popup.text_right:SetText(" = " .. tostring(x) .. " x |cff0070dd|Hitem:124124::::::::110:65:512:::110:::|h[Кровь Саргераса]|h|r")
 		if key == 'ENTER' then
 			StaticPopup1Button1:Click()
 		end
 		
 	end)
 	
 	-- _e_b.text_left = _e_b:CreateFontString()
 	-- _e_b.text_left:SetPoint("CENTER", _e_b, -65, 0)
 	-- _e_b.text_left:SetSize(150, 20)
 	-- _e_b.text_left:SetFont("Fonts\\ARIALN.TTF", 13)
 	-- _e_b.text_left:SetText('Сколько обменять: ')
 	
 	_e_b.text_right = _e_b:CreateFontString()
 	_e_b.text_right:SetPoint("LEFT", _e_b,"LEFT", 10, 0)
 	_e_b.text_right:SetSize(200, 20)
 	_e_b.text_right:SetFont("Fonts\\ARIALN.TTF", 14)
 	
 	_e_b:Hide()
	
	StaticPopup1:HookScript("OnShow", function(self)
		if addon.db.profile.settings.DalaranMerchantFix then
			local sttext = StaticPopup1Text:GetText()
			if sttext:match("Hitem:124124") then
				-- local itemcount = tonumber(StaticPopup1ItemFrameCount:GetText())
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
			local itemcount = tonumber(StaticPopup1ItemFrameCount:GetText()) or 1
			local setitemcount = FIXkuzumap_Popup:GetNumber()
			local itemname = StaticPopup1ItemFrameText:GetText()
			
			if itemcount and itemname and setitemcount then
				if setitemcount > itemcount then
					local x,y = math.modf(setitemcount/itemcount)
					if y == 0 and x ~= 0 then
						x = x - 1
					end
					for i=1,100 do 
						if itemname == GetMerchantItemInfo(i) then 
							for g=1, x do 
								BuyMerchantItem(i,itemcount)
							end
							break
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
			return false, CorrectKeyLinkInMessage(message), ...
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
