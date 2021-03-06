if SERVER then return end
surface.CreateFont("Heading", { font = 'arial bold', size = 22 })
surface.CreateFont("Category", { font = 'arial bold', size = 22 })

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() / 1.5, ScrH() / 1.5)
	self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))

	local close_btn = vgui.Create("DButton", self)
	close_btn:SetFont("marlett")
	close_btn:SetText("r")
	close_btn.Paint = function() end
	close_btn:SetColor(Color(255, 255, 255))
	close_btn:SetSize(32, 32)
	close_btn:SetPos(self:GetWide() - 40, 8)
	close_btn.DoClick = function() HORDE:ToggleShop() end

    local btn_container = vgui.Create("DPanel", self)
	btn_container:SetTall(32)
	btn_container:Dock(TOP)
	btn_container:DockMargin(0, 48, 0, 0)
    btn_container.Paint = function (pnl, w, h)
        surface.SetDrawColor(40, 40, 40, 0)
        surface.DrawRect(0, 0, self:GetWide(), 32)
    end

	local container = vgui.Create("DPanel", self)
	container:Dock(LEFT)
    container:SetSize(self:GetWide() / 2, self:GetTall() - 100)
	container:SetBackgroundColor(HORDE.color_hollow)

	local description_panel = vgui.Create("HordeDescription", self)
	description_panel:Dock(LEFT)
	description_panel:SetSize(self:GetWide() / 2, self:GetTall() - 100)

    local btns = {}
	local firstBtn = true
	local function createBtn(text, panel, dock)
		panel:SetParent(container)
		panel:Dock(FILL)
		panel.Paint = function(pnl, w, h) surface.SetDrawColor(40, 40, 40, 200) surface.DrawRect(0, 0, w, h) end

		if firstBtn then
			panel:SetZPos(100)
			panel:SetVisible(true)
		else
			panel:SetZPos(1)
			panel:SetVisible(false)
		end

		local btn = vgui.Create("DButton", btn_container)
		btn:Dock(dock)
		btn:SetText(text)
		btn:SetFont("Category")

		btn.Paint = function(pnl, w, h)
			if text == "Select Class" then
				surface.SetDrawColor(HORDE.color_crimson)
				surface.DrawRect(0, 0, w, h)
				return
			end
			surface.SetDrawColor(0,0,0,0)
			surface.DrawRect(0, 0, w, h)

			if pnl:GetActive() then
				surface.SetDrawColor(Color(40,40,40,230))
				surface.DrawRect(0, 0, w, h)
			end
		end

		btn.UpdateColours = function(pnl)
			if pnl:GetActive() then
				if text == "Select Class" then
					pnl:SetTextColor(Color(220,220,220))
				else
					pnl:SetTextColor(HORDE.color_crimson)
				end
				return
			end
			if pnl.Hovered then
				if text == "Select Class" then
					pnl:SetTextColor(Color(220,220,220))
				else
					pnl:SetTextColor(HORDE.color_crimson)
				end
			return end
			pnl:SetTextColor(Color(255, 255, 255))
		end

		btn.PerformLayout = function(pnl)
			pnl:SizeToContents() pnl:SetWide(pnl:GetWide() + 12) pnl:SetTall( pnl:GetParent():GetTall() ) DLabel.PerformLayout(pnl)
			pnl:SetContentAlignment(4)
			pnl:SetTextInset( 12, 0 )
		end

		btn.GetActive = function(pnl) return pnl.Active or false end
		btn.SetActive = function(pnl, state) pnl.Active = state end

		if firstBtn then firstBtn = false; btn:SetActive(true) end

		btn.DoClick = function(pnl)
			for k, v in pairs(btns) do v:SetActive(false) v:OnDeactivate() end
			pnl:SetActive(true) pnl:OnActivate()
			surface.PlaySound("UI/buttonclick.wav")
		end

		btn.OnDeactivate = function()
			panel:SetVisible(false)
			panel:SetZPos(1)
		end
		btn.OnActivate = function()
			panel:SetVisible(true)
			panel:SetZPos(100)
		end
		btn.OnCursorEntered = function ()
			surface.PlaySound("UI/buttonrollover.wav")
		end

		table.insert(btns, btn)

		return btn
	end

    local categories = {"Melee", "Pistol", "SMG", "Shotgun", "Rifle", "MG", "Explosive", "Special", "Equipment"}
	local class = LocalPlayer():GetHordeClass()

	for _, CATEGORY in pairs(categories) do
		local items = {}

		for _, item in pairs(HORDE.items) do
			if item.category == CATEGORY and item.whitelist and item.whitelist[class.name] then
				if LocalPlayer():HasWeapon(item.class) then
					item.cmp = -1
				else
					item.cmp = item.price
				end
				table.insert(items, item)
			end
		end

		if table.IsEmpty(items) then goto cont end

		table.sort(items, function(a, b)
			if a.cmp == b.cmp then
				return a.weight < b.weight
			else
				return a.cmp < b.cmp
			end
		end)

		local ShopCategoryTab = vgui.Create("DPanel")

		local DScrollPanel = vgui.Create("DScrollPanel", ShopCategoryTab)
		DScrollPanel:Dock(FILL)

		local ShopCategoryTabLayout = vgui.Create("DIconLayout", DScrollPanel)
		ShopCategoryTabLayout:Dock(FILL)
		ShopCategoryTabLayout:SetBorder(8)
		ShopCategoryTabLayout:SetSpaceX(8)
		ShopCategoryTabLayout:SetSpaceY(8)

		DScrollPanel:AddItem(ShopCategoryTabLayout)

		for _, item in pairs(items) do
			if item.category == CATEGORY then
				local model = vgui.Create("HordeShopItem")
				model:SetSize(container:GetWide() - 16, 40)
				model:SetData(item, description_panel)
				ShopCategoryTabLayout:Add(model)
			end
		end

		createBtn(CATEGORY, ShopCategoryTab, LEFT)

		::cont::
	end

	-- Class tab
	local ClassTab = vgui.Create("DPanel")
	local DScrollPanel = vgui.Create("DScrollPanel", ClassTab)
	DScrollPanel:Dock(FILL)

	local ClassTabLayout = vgui.Create("DIconLayout", DScrollPanel)
	ClassTabLayout:Dock(FILL)
	ClassTabLayout:SetBorder(8)
	ClassTabLayout:SetSpaceX(8)
	ClassTabLayout:SetSpaceY(8)

	for _, class in pairs(HORDE.classes) do
		local model = vgui.Create("HordeClass")
		model:SetSize(container:GetWide() - 16, 40)
		model:SetData(class, description_panel)
		ClassTabLayout:Add(model)
	end

	createBtn("Select Class", ClassTab, RIGHT)
end

function PANEL:Paint(w, h)
	-- Derma_DrawBackgroundBlur(self)

    -- Entire Panel
	draw.RoundedBox(0, 0, 0, w, h, HORDE.color_hollow)

	-- Money
	draw.SimpleText("Class: " .. LocalPlayer():GetHordeClass().name, 'Heading', 10, 24, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	if LocalPlayer():GetHordeClass().name == "Heavy" then
		draw.SimpleText("Cash: " .. tostring(LocalPlayer():GetHordeMoney()) .. '$ Weight: [' .. tostring(HORDE.max_weight + 5 - LocalPlayer():GetHordeWeight()) .. "/" .. HORDE.max_weight + 5 .. "]", 'Heading', self:GetWide() - 40, 24, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Cash: " .. tostring(LocalPlayer():GetHordeMoney()) .. '$ Weight: [' .. tostring(HORDE.max_weight - LocalPlayer():GetHordeWeight()) .. "/" .. HORDE.max_weight .. "]", "Heading", self:GetWide() - 40, 24, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

vgui.Register("HordeShop", PANEL)