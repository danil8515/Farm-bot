script_name('Farm Bot')
script_author('kopnev')
script_version('1.5')
script_version_number(15)

local sampev   = require 'lib.samp.events'
local inicfg   = require 'inicfg'
local imgui   = require 'imgui'
local imadd    = require 'imgui_addons'
local encoding = require 'encoding'
local effil    = require 'effil'
local memory   = require 'memory'
local rkeys    = require 'rkeys'
local vkeys    = require 'vkeys'
local dlstatus = require('moonloader').download_status
--local band     = bit.band
--local sha1     = require 'sha1'
--local basexx   = require 'basexx'

encoding.default = 'CP1251'
u8 = encoding.UTF8


local main_windows_state = imgui.ImBool(false) --------------------------ДАНЯ НЕ ЗАБУДЬ ПЕРЕКЛЮЧИТЬ В ФАЛС
local settings_window = imgui.ImBool(false)
local loop_window = imgui.ImBool(false)
local changelog_window = imgui.ImBool(false)




local sat_flag = false -- https://blast.hk/threads/31640/
local sat_full = false
local f_scrText_state = false
local hun = 0
local textdraw = { numb = 549.5, del = 54.5, {549.5, 60, -1436898180}, {547.5, 58, -16777216}, {549.5, 60, 1622575210} }


local def = {
	settings = {
        theme = 7,
        style = 1,
        vkladka = 5,
        reload = false,
        reloadR = false,
        post = 0,
        limit = true,
        lim = 30,
        limit1 = true,
        lim1 = 4,
        key1 = 114,
        helptext = true,
        b_loop = false,
		d_loop = 350,
        uahungry = false,
		hungry = false,
		animsuse = false,
		anims = "/anims 32",
		altbot = false,
		animsbot = false,
		chipsbot = false,
        fishbot = false,
        venisonbot = false,
        idVK = 0,
        auto = false,
        bg = false,
        faedit = false,
    },
    vk = {
        token = "",
        id = 0,
        InChat = true,
        ot = true,
        manage = false,
        active = false,
        cord = true,
        hp = true
    }
}

local directIni = "KopnevScripts\\Farm Bot.ini"

local ini = inicfg.load(def, directIni)

local faedit = imgui.ImBool(ini.settings.faedit)

local faico = faedit.v

if faico then
    fa = require 'fAwesome5'
    fa_font = nil
    fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
end

local InChat = imgui.ImBool(ini.vk.InChat)
local ot = imgui.ImBool(ini.vk.ot)
local manage = imgui.ImBool(ini.vk.manage)
local active = imgui.ImBool(ini.vk.active)
local cord = imgui.ImBool(ini.vk.cord)
local hp = imgui.ImBool(ini.vk.hp)
local style = imgui.ImInt(ini.settings.style)

local b_loop = imgui.ImBool(ini.settings.b_loop)
local d_loop = imgui.ImInt(ini.settings.d_loop)

local tema = imgui.ImInt(ini.settings.theme)
local post = imgui.ImInt(ini.settings.post)
local limit = imgui.ImBool(ini.settings.limit)
local lim = imgui.ImInt(ini.settings.lim)
local helptext = imgui.ImBool(ini.settings.helptext)

local limit1 = imgui.ImBool(ini.settings.limit1)
local lim1 = imgui.ImInt(ini.settings.lim1)

local uahungry = imgui.ImBool(ini.settings.uahungry)
local hungry = imgui.ImBool(ini.settings.hungry)
local animsuse = imgui.ImBool(ini.settings.animsuse)
local anims = imgui.ImBuffer(ini.settings.anims, 32)

local altbot = imgui.ImBool(ini.settings.altbot)
local animsbot = imgui.ImBool(ini.settings.animsbot)
local chipsbot = imgui.ImBool(ini.settings.chipsbot)
local fishbot = imgui.ImBool(ini.settings.fishbot)
local venisonbot = imgui.ImBool(ini.settings.venisonbot)

local auto = imgui.ImBool(ini.settings.auto)
local bg = imgui.ImBool(ini.settings.bg)

local idVK = imgui.ImInt(ini.settings.idVK)

local GroupToken = imgui.ImBuffer(ini.vk.token, 128)
local id = imgui.ImInt(ini.vk.id)

value = 0
value1 = 0
work = false
work1 = false
gopoint = false
onpoint = false
bplant = false
success = false
onpoint2 = false
ww = false
gopay = false
zdorov = false
gou = false

local vkladki = {
    false,
		false,
		false,
		false,
		false,
		false,
}

vkladki[ini.settings.vkladka] = true

local ActiveMenu = {
	v = {ini.settings.key1,ini.settings.key2}
}
local bindID = 0

local items = {
	u8"Тёмная тема",
	u8"Синия тема",
	u8"Красная тема",
	u8"Голубая тема",
	u8"Зелёная тема",
	u8"Оранжевая тема",
	u8"Фиолетовая тема",
	u8"Тёмно-светлая тема"
}

local styles = {
	u8'Строгий',
	u8'Мягкий'
}

local posts = {
	u8"Начальный фермер",
	u8"Тракторист",
	u8"Комбайнер",
	u8"Водитель кукурузника"
}

--------------------------------------------VK NOTF--------------------------------------------------
--Автор: Aniki
--Тема на бх: https://blast.hk/threads/33250/
--Там это, лайк ему поставьте, а то что вы как не люди

--longpoll
local key, server, ts

function threadHandle(runner, url, args, resolve, reject)
	local t = runner(url, args)
	local r = t:get(0)
	while not r do
		r = t:get(0)
		wait(0)
	end
	local status = t:status()
	if status == 'completed' then
		local ok, result = r[1], r[2]
		if ok then resolve(result) else reject(result) end
	elseif err then
		reject(err)
	elseif status == 'canceled' then
		reject(status)
	end
	t:cancel(0)
end

function requestRunner()
	return effil.thread(function(u, a)
		local https = require 'ssl.https'
		local ok, result = pcall(https.request, u, a)
		if ok then
			return {true, result}
		else
			return {false, result}
		end
	end)
end

function async_http_request(url, args, resolve, reject)
	local runner = requestRunner()
	if not reject then reject = function() end end
	lua_thread.create(function()
		threadHandle(runner, url, args, resolve, reject)
	end)
end

local vkerr, vkerrsend

function loop_async_http_request(url, args, reject)
	local runner = requestRunner()
	if not reject then reject = function() end end
	lua_thread.create(function()
		while true do
			while not key do wait(0) end
			url = server .. '?act=a_check&key=' .. key .. '&ts=' .. ts .. '&wait=25'
			threadHandle(runner, url, args, longpollResolve, reject)
		end
	end)
end

function longpollResolve(result)
	if result then
			--print(result)
		if not result:sub(1,1) == '{' then
			vkerr = 'Ошибка!\nПричина: Нет соединения с VK!'
			return
		end
		local t = decodeJson(result)
		if t.failed then
			if t.failed == 1 then
				ts = t.ts
			else
				key = nil
				longpollGetKey()
			end
			return
		end
		if t.ts then
			ts = t.ts
		end
			for k, v in ipairs(t.updates) do
				if v.type == 'message_new' and v.object.text and ini.vk.active then
					if v.object.payload then
						local pl = decodeJson(v.object.payload)
						if pl.button then
                            if pl.button == 'off' then
                                if ini.vk.manage then
                                    work = false
                                    work1 = false
                                    vk_request('Бот отключен')
                                else vk_request('Ошибка') end
                                elseif pl.button == 'status' then
                                    sendStatus()
                                elseif pl.button == 'offzp' then
                                    if ini.vk.manage then 
                                        if work then
                                            
                                            gopoint = false
                                            lua_thread.create(function() 
                                                BeginToPoint(-120.1061,88.2469,3.1172, 3, -255, true)  
                                            end)
                                        end
                                        if work1 then 
                                            gopay = true
                                            vk_request('Бот поехал за зарплатой')
                                            lua_thread.create(function()
                                                rideTo(-121.1731,85.7734,3.0719, 50)
                                                rideTo(-115.0045,79.7263,3.0729, 50)
                                                rideTo(-108.6299,76.0149,3.0727, 50)
                                                rideTo(-96.1733,75.8351,3.0727, 20)
                                                rideTo(-87.7826,74.0141,3.0721, 10)
                                                sampSendChat('/engine')
                                                ww = false
                                                wait(500)
                                                while true do
                                                    wait(150)
                                                    setGameKeyState(15, 255)
                                                    break
                                                end
                                                wait(2000)
                                                if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then 
                                                    while true do
                                                        wait(150)
                                                        setGameKeyState(15, 255)
                                                        break
                                                    end
                                                    wait(1500)
                                                end
                                                BeginToPoint(-80.5411,82.7958,3.1096, 1, -255, false)
                                                wait(2000)
                                                while true do
                                                    wait(150)
                                                    setGameKeyState(21, 255)
                                                    break
                                                end
                                            end)
                                        end end
                                    else vk_request('\n[Ошибка] У вас не включено управление ботом из вк.')
                                end
						end
						return
                    end
                    if ini.vk.InChat then
                        local text = v.object.text .. ' ' --костыль на случай если одна команда является подстрокой другой (!d и !dc как пример)
                        text = text:sub(1, text:len() - 1)
                        sampProcessChatInput(u8:decode(text))
                    end
				end
			end
	end
end

function longpollGetKey()
	async_http_request('https://api.vk.com/method/groups.getLongPollServer?group_id=' .. ini.vk.id .. '&access_token=' .. ini.vk.token .. '&v=5.80', '', function (result)
		if result then
				--print(result)
			if not result:sub(1,1) == '{' then
				vkerr = 'Ошибка!\nПричина: Нет соединения с VK!'
				print(vkerr)
				return
			end
			local t = decodeJson(result)
			if t.error then
                vkerr = 'Ошибка!\nКод: ' .. t.error.error_code .. ' Причина: ' .. t.error.error_msg
                
                sampAddChatMessage('[Farm Bot] Обнаружены следующие ощибки:', 0xFF0000)
                sampAddChatMessage('[Ошибка] Сообщения из группы вк не будут доставлены', 0xFF0000)
                sampAddChatMessage('[Ошибка] Неправильно указан ИД группы', 0xFF0000)
                ini.vk.active = false
                inicfg.save(def, directIni)
                active.v = false
				print(vkerr)
				return
			end
			server = t.response.server
			ts = t.response.ts
			key = t.response.key
			vkerr = nil
		end
	end)
end

function vk_request(msg)
    if active.v then
        _, idPed = sampGetPlayerIdByCharHandle(PLAYER_PED)
        msg = 'Новое уведомление от Farm Bot\nАккаунт: '.. sampGetPlayerNickname(idPed) .. '\nУведомление: '.. msg
        msg = msg:gsub('{......}', '')
        msg = u8(msg)
        msg = url_encode(msg)
        local keyboard = vkKeyboard()
        --print(keyboard)
        keyboard = u8(keyboard)
        keyboard = url_encode(keyboard)
        msg = msg .. '&keyboard=' .. keyboard
        --if sendBuf.v and 195184331 ~= '' then
            async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. ini.settings.idVK .. '&message=' .. msg .. '&access_token=' .. ini.vk.token .. '&v=5.80',
            function (result)
                    --print(result)
                local t = decodeJson(result)
                if not t then
                    --print(result)
                    return
                end
                if t.error then
                    vkerrsend = 'Ошибка!\nКод: ' .. t.error.error_code .. '\nПричина: ' .. t.error.error_msg
                    if t.error.error_code == 901 then vkerrsend = vkerrsend..'\nНеправильно указан ид ВК или вы не разрешили группе писать вам' end
                    if t.error.error_code == 5 then vkerrsend = vkerrsend..'\nНеверный Токен группы' end
                    print(vkerrsend)
                    return
                end
                vkerrsend = nil
            end)
        --end
    else vkerrsend = 'Уведомления отключены' end
end

function vkKeyboard() --создает конкретную клавиатуру для бота VK
	local keyboard = {}
	keyboard.one_time = false
    keyboard.buttons = {}
    keyboard.buttons[1] = {}
    local row = keyboard.buttons[1]
    
    row[1] = {}
    row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "status"}'
    row[1].action.label = 'Статус'
    if ( work or work1 ) and ini.vk.manage then
        keyboard.buttons[2] = {}
        local row = keyboard.buttons[2]
        row[1] = {}
        row[1].action = {}
        row[1].color = 'negative'
        row[1].action.type = 'text'
        row[1].action.payload = '{"button": "off"}'
        row[1].action.label = 'Отключить бота'
        keyboard.buttons[3] = {}
        local row = keyboard.buttons[3]
        row[1] = {}
        row[1].action = {}
        row[1].color = 'negative'
        row[1].action.type = 'text'
        row[1].action.payload = '{"button": "offzp"}'
        row[1].action.label = 'Отключить бота и получить зарплату'
    end
	return encodeJson(keyboard)
end

local hun = 0

function sendStatus()
    if work then f1 = 'Работает' else f1 = 'Отключен' end
    if work1 then f2 = 'Работает' else f2 = 'Отключен' end

    msg = '\nСостояние бота \'Начальный фермер\': '..f1..'\nСостояние бота \'Тракторист\': '..f2..'\nЗдоровье: '..getCharHealth(PLAYER_PED)..'\nГолод: '..hun..'/100'

    if work then 
        more = lim.v - value
        msg = msg .. '\nБот фермера перетащил сена: '..value..'\n'
        if not limit.v then msg = msg .. 'Осталось пертащить: '..more..'\n' end
    end
    if work1 then 
        more = lim1.v - value1
        msg = msg .. '\nБот тракториста сделал рейсов: '..value1..'\n'
        if not limit1.v then msg = msg .. 'Осталось сделать ещё: '..more..' рейсов\n' end
    end

    vk_request(msg)
end

-----------------------------------------------------------------------------------------------------

-- https://blast.hk/threads/31640/


local jhg = false
potok = false

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    bindID = rkeys.registerHotKey(ActiveMenu.v, true, function ()
		main_windows_state.v = not main_windows_state.v
	end)
    update()
    if ini.vk.active then longpollGetKey() end

    if doesFileExist('moonloader/farmer bot.lua') then
		os.rename('moonloader/farmer bot.lua', 'moonloader/Farm-Bot v1.5.lua')
    end
    if doesFileExist('moonloader/farmer bot (NU).lua') then
		os.remove('moonloader/farmer bot (NU).lua')
	end

    if ini.settings.reload == true then
		SCM('Успешно сохранено и применено.')
		main_windows_state.v = true
		ini.settings.reload = false
		inicfg.save(def, directIni)
	end
    if ini.settings.reloadR == true then
		ini.settings.reloadR = false
		inicfg.save(def, directIni)
	end
    while true do
        wait(0)
        imgui.Process = main_windows_state.v

        if gou == true then
            goupdate()
        end

        if work then
            res, x, y, z = FindObject()
            if gopoint and res then 
                BeginToPoint(x,y,z,3,-255,true)
                gopoint = false
            end
            if onpoint then
                lua_thread.create(function() 
                    while true do
                        wait(150)
                        setGameKeyState(21, 255)
                        break
                    end
                end)
                onpoint = false
                bplant = true
            end
            if not zdorov and 15 <= getCharHealth(PLAYER_PED) and ini.vk.hp then
                zdorov = true -- Защита от повторной отправки
                vk_request('Здоровье персонажа упало ниже 15. \n\nТекущее здоровье: '..getCharHealth(PLAYER_PED))
            end
        end

        if bg.v == true then
            WorkInBackground(true)
        else WorkInBackground(false) end

    end
end

lua_thread.create(function() 
	while true do
		wait(30)
		if isKeyDown(17) and isKeyDown(82) then -- CTRL+R
			ini.settings.reloadR = true
			inicfg.save(def, directIni)
		end
	  end
end)

----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------Анти-Голод by Hawk---------------------------------------------------
------------------------------------------https://blast.hk/threads/31640/---------------------------------------------
----------------------------------------------------------------------------------------------------------------------

lua_thread.create(function()
	while true do 
		wait(300)
		if (altbot.v or animsbot.v or chipsbot.v or fishbot.v or venisonbot.v) and (b_loop.v or f_scrText_state or sat_flag) then -- Анти-голод от Хавка
			if b_loop.v then
				wait(d_loop.v*1000)
				if not b_loop.v then
					break
				end
			elseif f_scrText_state or sat_flag then
				if potok == false and helptext.v then SCM('Поспали, теперь можно и поесть.') end
				wait(50)
			end
			if altbot.v or animsbot.v then
				sampSendChat("/house")
				wait(250)
				sampSendDialogResponse(174, 1, 1)
				wait(250)
				sampSendDialogResponse(2431, 1, 0)
				wait(250)
				sampSendDialogResponse(185, 1, 6)
				wait(250)
				sampCloseCurrentDialogWithButton(0)
				SCM('Поели, теперь можно и поспать.')
				if animsuse.v then
					if altbot.v then
						setGameKeyState(21, 255)--alt
					elseif animsbot.v and chipsbot.v or fishbot.v or venisonbot.v then
						sampSendChat(anims.v)
					end
				end
			elseif chipsbot.v or fishbot.v or venisonbot.v then
				wait(250)
					if potok == false then
						lua_thread.create(function()
							potok = true
							if chipsbot.v  then
								while not sat_full and chipsbot.v do
									sampSendChat("/cheeps")
									wait(100)
									for i=90, 99 do
										text = sampGetChatString(i)
										--print(text)
										if text == "У тебя нет чипсов!" then
											SCM('Chips-bot отключен.')
											chipsbot.v = false
											break
										end
									end
									wait(4000)
								end
								potok = false
							elseif fishbot.v then
								while not sat_full and fishbot.v do
									sampSendChat("/eat")
									sampSendDialogResponse(9965, 1, 1)
									wait(100)
									for i=90, 99 do
										text = sampGetChatString(i)
										--print(text)
										if text == "У тебя нет жареной рыбы!" then
											SCM('Fish-bot отключен.')
											fishbot.v = false
											break
										end
									end
									wait(4000)
								end
								potok = false
							elseif venisonbot.v then
								while not sat_full and venisonbot.v do
									sampSendChat("/eat")
									sampSendDialogResponse(9965, 1, 2)
									wait(100)
									for i=90, 99 do
										text = sampGetChatString(i)
										--print(text)
										if text == "У тебя нет жареного мяса оленины!" then
											SCM('Venison-bot отключен.')
											venisonbot.v = false
											break
										end
									end
									wait(4000)
								end
								potok = false
							end
							if animsuse.v and (chipsbot.v or fishbot.v or venisonbot.v) then
								if altbot.v then
									setGameKeyState(21, 255)--alt
								elseif animsbot.v or chipsbot.v or fishbot.v or venisonbot.v then
									sampSendChat(anims.v)
								end
							end
						end)
					end
				if sat_full and helptext.v then SCM('Поели, теперь можно и поспать.') sampCloseCurrentDialogWithButton(0) end
			end
		end
	end
end)

-----------------------------------Самп евентс---------------------------------------

function sampev.onSetPlayerAttachedObject(pid, index, create, obj)
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if work and myid == pid then
        if obj.modelId == 2901 then
            lua_thread.create(function() 
          BeginToPoint(-105.7775,100.9354,3.1172, 3, -255, true)  end)
          success = true
        end
        if obj.modelId == 0 and onpoint2 then
            if ini.settings.limit == false and value == ini.settings.lim then
                lua_thread.create(function() 
                    BeginToPoint(-120.1061,88.2469,3.1172, 3, -255, true)  end)
            else gopoint = true end
        end
    end
end

function sampev.onSetPlayerHealth(hp)
    zdorov = false
end

function sampev.onSetPlayerPos(pos)
    if ini.vk.cord then
        local x, y, z = getCharCoordinates(PLAYER_PED)
        vk_request('\nСервер изменил позицию персонажа на\n X:' .. string.format('%.3f', pos.x) .. ' Y: ' .. string.format('%.3f', pos.y) .. ' Z: ' .. string.format('%.3f',  pos.z) .. '. Расстояние: ' .. string.format('%.3f', getDistanceBetweenCoords3d(x, y, z, pos.x, pos.y, pos.z)))
    end
end

function sampev.onApplyPlayerAnimation(pid, animLib, animName, loop)
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if pid == myid and bplant and animName == "BOM_Plant" then
        bplant = false
        success = false
        lua_thread.create(function() 
            wait(15000)
            if success == false then
                success = false
                gopoint = true
            end
        end)
    end
end

otvet = false

function sampev.onServerMessage(clr, msg)
    if work and msg:find('Сена перетащено:') then
        value = value + 1
    end
    if (work or work1) and msg:find('Вы успешно забрали свою зарплату в размере:') then
        lua_thread.create(function() 
            BeginToPoint(-92.8096,93.2234,3.1172, 5, -255, true)  
            work = false
            work1 = false
            vk_request('Бот закончил работу')
        end)
    end
    if (work or work1) and msg:find('Вы еще ничего не заработали и не можете получить зарплату!') then
        lua_thread.create(function() 
            BeginToPoint(-92.8096,93.2234,3.1172, 5, -255, true)  
            work = false
            work1 = false
            vk_request('\n'..msg..'\nБот закончил работу. Бот ничего не заработал')
        end)
    end
    if msg:find('Вы тут?') or msg:find('вы тут?') or msg:find('ответил вам') and ini.vk.ot then
        vk_request('\n'..msg)
        if ini.settings.auto then 
            lua_thread.create(function() 
                if not otvet then
                    otvet = true
                    wait(3200) 
                    sampSendChat('Да')
                    wait(5000)
                    otvet = false
                end
            end)
        end
    end
    if msg:find('закончилось топливо') and (work or work1) then
        vk_request('В тракторе закончилось топливо.')
    end
    if work1 and msg:find('Вы успешно отработали.') then
        value1 = value1 + 1
        num = 0
        --print(value1)
        --print(ini.settings.lim1)
        --print(limit1)
        if value1 >= ini.settings.lim1 and not ini.settings.limit1 then
            gopay = true
            ww = true
            lua_thread.create(function()
                rideTo(-108.5108,119.1330,3.0700, 50)
                rideTo(-121.1731,85.7734,3.0719, 50)
                rideTo(-115.0045,79.7263,3.0729, 50)
                rideTo(-108.6299,76.0149,3.0727, 50)
                rideTo(-96.1733,75.8351,3.0727, 20)
                rideTo(-87.7826,74.0141,3.0721, 10)
                sampSendChat('/engine')
                ww = false
                wait(500)
                while true do
                    wait(150)
                    setGameKeyState(15, 255)
                    break
                end
                wait(2000)
                if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then 
                    while true do
                        wait(150)
                        setGameKeyState(15, 255)
                        break
                    end
                    wait(1500)
                end
                BeginToPoint(-80.5411,82.7958,3.1096, 1, -255, false)
                wait(2000)
                while true do
                    wait(150)
                    setGameKeyState(21, 255)
                    break
                end
            end)
        else
        ww = true 
        end
    end
    if f_scrText_state and (altbot or animsbot or chipsbot or fishbot) then
		if string.find(text,"Вы взяли комплексный обед. Посмотреть состояние голода можно") then
			f_scrText_state=false
		end
	end
end

num = 0

function sampev.onSetRaceCheckpoint(type, pos)
    if work1 and not gopay then
        num = num + 1
        lua_thread.create(function() 
            if num == 70 then 
                rideTo(-119.7002, 84.2271, 3.0719, 60) 
                rideTo(pos.x,pos.y,pos.z, 60)
            else
                rideTo(pos.x,pos.y,pos.z, 60) 
            end 
        end)
    end
end
-- -118.17479705811   97.49169921875   3.0650999546051
------------------------------------------------------------------------------------------------------------------

--------------------------------------https://blast.hk/threads/31640/-------------------------------------------
function onReceiveRpc(id, bs)
    if id == 134 then
		local td = readBitstream(bs)
		if td.x == textdraw[1][1] and td.y == textdraw[1][2] and td.color == textdraw[1][3] then
			sat = td.hun
			--print(sat)
			--print(math.floor((sat/textdraw.del)*100))
            --print(tostring(sat_flag))
            hun = math.floor((sat/textdraw.del)*100)
			local tmp = math.floor((sat/textdraw.del)*100)
			if hungry.v then
				if tmp < 20 then
					sat_flag = true
					--print(tostring(sat_flag))
				else
					sat_flag = false
				end
			end
			if tmp > 99 then sat_full = true else sat_full = false end
		end
    end
end

function sampev.onDisplayGameText(style, time, text)
    if uahungry.v and (altbot.v or animsbot.v or chipsbot.v or fishbot.v) then
        if text:find("You are hungry!") or text:find("You are very hungry!") then
			f_scrText_state = true
		end
	end
end
-----------------------------------------------------------------------------------------------------------

function FindObject()
    local xped, yped, zped = getCharCoordinates(PLAYER_PED)

    for i = 5, 85, 1 do
        for b = 1, 3, 1 do
            res, object = findAllRandomObjectsInSphere(xped, yped, zped, i, true)

            if res and getObjectModel(object) == 864 then
                local _, x, y, z = getObjectCoordinates(object)
                local res, _ = findAllRandomCharsInSphere(x, y, z, 10, false, true)
                if res == false then
                    return true, x, y, z
                end
            end
        end
    end

    return false, 0, 0, 0

end

function ShowHelpMarker(desc)
    if faico then imgui.TextDisabled(fa.ICON_FA_QUESTION_CIRCLE) else imgui.TextDisabled(u8'(?)') end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450.0)
        imgui.TextUnformatted(desc)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function ShowCOPYRIGHT(desc)

    if faico then imgui.TextDisabled(fa.ICON_FA_QUESTION_CIRCLE) else imgui.TextDisabled(u8'(С)') end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450.0)
        imgui.TextUnformatted(desc)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.BeforeDrawFrame()
    if faico then
        if fa_font == nil then
            local font_config = imgui.ImFontConfig()
            font_config.MergeMode = true
            fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 11.0, font_config, fa_glyph_ranges)
        end
    end
end

function imgui.OnDrawFrame()
	if ini.settings.style == 0 then strong_style() end
	if ini.settings.style == 1 then easy_style() end
	if ini.settings.theme == 0 then theme1() end
	if ini.settings.theme == 1 then theme2() end
	if ini.settings.theme == 2 then theme3() end
	if ini.settings.theme == 3 then theme4() end
	if ini.settings.theme == 4 then theme5() end
	if ini.settings.theme == 5 then theme6() end
	if ini.settings.theme == 6 then theme7() end
	if ini.settings.theme == 7 then theme8() end

    local tLastKeys = {}
    
    if main_windows_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(700, 340), imgui.Cond.FirstUseEver)
        imgui.Begin(thisScript().name..' | version '..thisScript().version, main_windows_state, 2)

        imgui.BeginChild('left pane', imgui.ImVec2(150, 0), true)
            if faico then 
                if imgui.Button(u8"Настройки бота  "..fa.ICON_FA_ROBOT, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[1] = true
                    ini.settings.vkladka = 1
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Анти-голод  "..fa.ICON_FA_UTENSILS, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[2] = true
                    ini.settings.vkladka = 2
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Уведомления ВК  "..fa.ICON_FA_INFO, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[3] = true
                    ini.settings.vkladka = 3
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Настройки  "..fa.ICON_FA_COGS, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[4] = true
                    ini.settings.vkladka = 4
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Информация  "..fa.ICON_FA_INFO_CIRCLE, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[5] = true
                    ini.settings.vkladka = 5
                    inicfg.save(def, directIni)
                end
            else
                if imgui.Button(u8"Настройки бота  ", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[1] = true
                    ini.settings.vkladka = 1
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Анти-голод  ", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[2] = true
                    ini.settings.vkladka = 2
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Уведомления ВК  ", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[3] = true
                    ini.settings.vkladka = 3
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Настройки  ", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[4] = true
                    ini.settings.vkladka = 4
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Информация", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[5] = true
                    ini.settings.vkladka = 5
                    inicfg.save(def, directIni)
                end
            end
        imgui.EndChild()
        imgui.SameLine()

        if vkladki[1] == true then -- Настройки бота
			imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8'Настройки бота '..fa.ICON_FA_ROBOT) else imgui.Text(u8'Настройки бота') end
			imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(30) imgui.Text(u8'Выбор должности:') imgui.SameLine(170)
            imgui.PushItemWidth(250)
			if imgui.Combo('##dl', post, posts, -1)then
				ini.settings.post = post.v
				inicfg.save(def, directIni)
            end imgui.PopItemWidth()
            imgui.NewLine() imgui.Separator() imgui.NewLine() imgui.NewLine()
            if ini.settings.post == 0 then
                imgui.SameLine(30) imgui.Text(u8'Без ограничения:') imgui.SameLine(170) 
                if imadd.ToggleButton('##limit', limit) then
                    ini.settings.limit = limit.v
                    inicfg.save(def, directIni)
                end
                if ini.settings.limit == false then
                    imgui.NewLine() imgui.NewLine()
                    imgui.SameLine(30) imgui.Text(u8'Ограничение:') imgui.SameLine(170) 
                    imgui.PushItemWidth(250) 
                        if imgui.InputInt('##lim', lim) then
                            ini.settings.lim = lim.v
                            inicfg.save(def, directIni)
                        end
                    imgui.PopItemWidth()
                end
                imgui.SetCursorPos(imgui.ImVec2(486, 300))
                if faico then
                    if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8'  Начать', imgui.ImVec2(100, 30)) then
                        work = true
                        gopoint = true
                    end imgui.SameLine()
                    if work == true then
                        if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8'  Стоп', imgui.ImVec2(100, 30)) then
                            work = false
                        end
                    end
                else
                    if imgui.Button(u8'Начать', imgui.ImVec2(100, 30)) then
                        work = true
                        gopoint = true
                    end imgui.SameLine()
                    if work == true then
                        if imgui.Button(u8'Стоп', imgui.ImVec2(100, 30)) then
                            work = false
                        end
                    end
                end
            end
            if ini.settings.post == 1 then
                imgui.SameLine(30) imgui.Text(u8'Без ограничения:') imgui.SameLine(170) 
                if imadd.ToggleButton('##liimit', limit1) then
                    ini.settings.limit1 = limit1.v
                    inicfg.save(def, directIni)
                end
                if ini.settings.limit1 == false then
                    imgui.NewLine() imgui.NewLine()
                    imgui.SameLine(30) imgui.Text(u8'Ограничение:') imgui.SameLine(170) 
                    imgui.PushItemWidth(250) 
                        if imgui.InputInt('##lim', lim1) then
                            ini.settings.lim1 = lim1.v
                            inicfg.save(def, directIni)
                        end
                    imgui.PopItemWidth()
                    imgui.SameLine() ShowHelpMarker(u8'Не рекомендуется ставить больше 4, т.к кончается топливо')
                end
                imgui.SetCursorPos(imgui.ImVec2(486, 300))
                if faico then
                    if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8'  Начать', imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 531 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work1 = true
                                gopay = false
                                value1 = 0
                                num = 0
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) then
                                    sampSendChat('/engine')
                                end
                            else SCM('Вы не в тракторе.') end
                        else SCM('Вы не в тракторе.') end
                        lua_thread.create(function() 
                        rideTo(-118.1747, 97.4916, 3.0650, 60) end)
                    end imgui.SameLine()
                    if work1 == true then
                        if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8'  Стоп', imgui.ImVec2(100, 30)) then
                            work1 = false
                            gopay = false
                        end
                    end
                else
                    if imgui.Button(u8'Начать', imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 531 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work1 = true
                                gopay = false
                                value1 = 0
                                num = 0
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) then
                                    sampSendChat('/engine')
                                end
                            else SCM('Вы не в тракторе.') end
                        else SCM('Вы не в тракторе.') end
                        lua_thread.create(function() 
                        rideTo(-118.1747, 97.4916, 3.0650, 60) end)
                    end imgui.SameLine()
                    if work1 == true then
                        if imgui.Button(u8'Стоп', imgui.ImVec2(100, 30)) then
                            work1 = false
                            gopay = false
                        end
                    end
                end
            end
            if ini.settings.post == 2 or ini.settings.post == 3 then
                imgui.SameLine(210) imgui.Text(u8'Coming soon...') 
            end
            imgui.EndGroup()
        end
        
        if vkladki[2] == true then -- Анти-голод
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200) imgui.Text(u8'Анти-Голод')
            imgui.SameLine() ShowCOPYRIGHT(u8'Автор: James Hawk')
            imgui.NewLine() imgui.Separator() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8'Выберите тип работы скрипта:')
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8'You are hungry: ') imgui.SameLine() if imadd.ToggleButton(u8'Yoy are hungry', uahungry) then
                hungry.v = false
                b_loop.v = false
                ini.settings.b_loop = b_loop.v
                ini.settings.hungry = hungry.v
                ini.settings.uahungry = uahungry.v
                inicfg.save(def, directIni)
            end imgui.SameLine() ShowHelpMarker(u8'You are hungry - срабатывает, когда на экране появляется красная надпись \"You are hungry!\" или \"You are very hungry!\".') imgui.SameLine(200)
            imgui.Text(u8'Голод: ') imgui.SameLine() if imadd.ToggleButton(u8'Голод', hungry)  then
                uahungry.v = false
                b_loop.v = false
                ini.settings.b_loop = b_loop.v
                ini.settings.hungry = hungry.v
                ini.settings.uahungry = uahungry.v
                inicfg.save(def, directIni)
            end imgui.SameLine() ShowHelpMarker(u8'Голод - срабатывает когда значение сытости достигает ниже 20 единиц.') imgui.SameLine(340)
            imgui.Text(u8'Цикличный: ') imgui.SameLine() if imadd.ToggleButton(u8'Цикличный', b_loop)  then
                uahungry.v = false
                hungry.v = false
                ini.settings.b_loop = b_loop.v
                ini.settings.hungry = hungry.v
                ini.settings.uahungry = uahungry.v
                inicfg.save(def, directIni)
            end imgui.SameLine() ShowHelpMarker(u8'Цикличный - срабатывает через определённое время указанное пользователем') imgui.SameLine()
            if faico then
                if imgui.Button(fa.ICON_FA_SLIDERS_H) then
                    loop_window.v = true
                end
            else 
                if imgui.Button(u8'=') then
                    loop_window.v = true
                end
            end
            imgui.NewLine() imgui.Separator() imgui.NewLine() 
            imgui.SameLine(15) imgui.Text(u8'Использовать анимации: ') imgui.SameLine()
            if imadd.ToggleButton(u8'Использовать анимации', animsuse) then
                ini.settings.animsuse = animsuse.v
                inicfg.save(def, directIni)
            end
            if animsuse.v == true and not altbot.v then
                imgui.SameLine(215)  imgui.PushItemWidth(150) imgui.InputText('##anims', anims) imgui.PopItemWidth()
            end
            imgui.NewLine() imgui.Separator() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8'Чтобы начать выберите тип бота:')
            imgui.SameLine() ShowHelpMarker(u8'Чтобы использовать анимации, не забудьте включить их, в пункет выше')
            imgui.NewLine()	imgui.NewLine()


            imgui.SameLine(15) imgui.Text(u8'Alt-bot:') imgui.SameLine(100) if imadd.ToggleButton('##alt', altbot) then
                chipsbot.v = false
                animsbot.v = false
                fishbot.v = false
                venisonbot.v = false
                ini.settings.chipsbot = chipsbot.v
                ini.settings.animsbot = animsbot.v
                ini.settings.altbot = altbot.v
                ini.settings.fishbot = fishbot.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8'Alt-бот: Ест еду из холодильника. После того как поест переходит в alt анимацию (Нажимает ALT)')


            imgui.SameLine(180) imgui.Text(u8'Chips-bot:') imgui.SameLine(265) if imadd.ToggleButton('##Chips', chipsbot) then
                altbot.v = false
                animsbot.v = false
                fishbot.v = false
                venisonbot.v = false
                if chipsbot.v == false then potok = false end
                ini.settings.chipsbot = chipsbot.v
                ini.settings.animsbot = animsbot.v
                ini.settings.altbot = altbot.v
                ini.settings.fishbot = fishbot.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8'Chips-бот: Ест чипсы. После того как поест переходит в анимацию из (/anims)')

            imgui.SameLine(365) imgui.Text(u8'Vinison-bot:') imgui.SameLine(450) if imadd.ToggleButton('##venison', venisonbot) then
                altbot.v = false
                chipsbot.v = false
                animsbot.v = false
                fishbot.v = false
                if venisonbot.v == false then potok = false end
                ini.settings.chipsbot = chipsbot.v
                ini.settings.animsbot = animsbot.v
                ini.settings.altbot = altbot.v
                ini.settings.fishbot = fishbot.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8'Vinison-бот: ест оленину. После того как поест переходит в анимацию из (/anims)')


            imgui.NewLine()	imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8'Anims-bot:') imgui.SameLine(100) if imadd.ToggleButton('##animsbot', animsbot) then
                altbot.v = false
                chipsbot.v = false
                fishbot.v = false
                venisonbot.v = false
                ini.settings.chipsbot = chipsbot.v
                ini.settings.animsbot = animsbot.v
                ini.settings.altbot = altbot.v
                ini.settings.fishbot = fishbot.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8'Anims-бот: Ест еду из холодильника. После того как поест переходит в анимацию из (/anims)')


            imgui.SameLine(180) imgui.Text(u8'Fish-bot:') imgui.SameLine(265) if imadd.ToggleButton('##fish', fishbot) then
                altbot.v = false
                chipsbot.v = false
                animsbot.v = false
                venisonbot.v = false
                if fishbot.v == false then potok = false end
                ini.settings.chipsbot = chipsbot.v
                ini.settings.animsbot = animsbot.v
                ini.settings.altbot = altbot.v
                ini.settings.fishbot = fishbot.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8'Fish-бот: ест рыбу. После того как поест переходит в анимацию из (/anims)')

            imgui.EndGroup()
        end

        if vkladki[3] == true then -- Увед вк
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8'Уведомления ВК  '..fa.ICON_FA_INFO) else imgui.Text(u8'Уведомления ВК') end
			imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine() imgui.SameLine(15) 
            imgui.Text(u8'Ваш id ВКонтакте:') imgui.SameLine(150)
            imgui.PushItemWidth(200) 
            if imgui.InputInt('##id', idVK, 0) then
                ini.settings.idVK = idVK.v
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth(0) 

            imgui.SameLine(360) 
            if faico then
                if imgui.Button(fa.ICON_FA_USERS_COG..u8'  Настройка группы') then 
                    settings_window.v = not settings_window.v
                end
            else 
                if imgui.Button(u8'Настройка группы') then 
                    settings_window.v = not settings_window.v
                end
            end

            imgui.NewLine() imgui.NewLine() imgui.SameLine(15) 
            imgui.Text(u8'Стаус уведомлений:') imgui.SameLine(300)
            if imadd.ToggleButton('##active', active) then
                if active.v == true then longpollGetKey() end
                ini.vk.active = active.v
                inicfg.save(def, directIni)
            end

            imgui.NewLine() imgui.SameLine(15) 
            imgui.Text(u8'Отправлять сообщения из вк в чат:') imgui.SameLine(300)
            if imadd.ToggleButton('##InChat', InChat) then
                ini.vk.InChat = InChat.v
                inicfg.save(def, directIni)
            end

            imgui.NewLine() imgui.SameLine(15) 
            imgui.Text(u8'Уведомлять об ответе от Администратора:') imgui.SameLine(300)
            if imadd.ToggleButton('##ot', ot) then
                ini.vk.ot = ot.v
                inicfg.save(def, directIni)
            end

            imgui.NewLine() imgui.SameLine(15) 
            imgui.Text(u8'Управление ботом из вк:') imgui.SameLine(300)
            if imadd.ToggleButton('##manage', manage) then
                ini.vk.manage = manage.v
                inicfg.save(def, directIni)
            end

            imgui.NewLine() imgui.SameLine(15) 
            imgui.Text(u8'Уведомлять об изменении координат:') imgui.SameLine(300)
            if imadd.ToggleButton('##cord', cord) then
                ini.vk.cord = cord.v
                inicfg.save(def, directIni)
            end

            imgui.NewLine() imgui.SameLine(15) 
            imgui.Text(u8'Уведомлять о низком уровне HP:') imgui.SameLine(300)
            if imadd.ToggleButton('##hp', hp) then
                ini.vk.hp = hp.v
                inicfg.save(def, directIni)
            end
            if vkerrsend then imgui.NewLine() imgui.SameLine(15)  imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), u8(vkerrsend)) end
            imgui.SetCursorPos(imgui.ImVec2(590, 300))
            if faico then
                if imgui.Button(fa.ICON_FA_COMMENT_DOTS..u8'  Тест', imgui.ImVec2(100, 30)) then
                    vk_request('Тестовое сообщение')
                end
            else
                if imgui.Button(u8'Тест', imgui.ImVec2(100, 30)) then
                    vk_request('Тестовое сообщение')
                end
            end
            imgui.EndGroup()
        end

        if vkladki[4] == true then -- Настройки 
            imgui.BeginGroup()
			imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200)
            if faico then imgui.Text(u8'Настройки  '..fa.ICON_FA_COGS) else imgui.Text(u8'Настройки') end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'Выбор темы: ') imgui.SameLine()
            imgui.PushItemWidth(150)
            if imgui.Combo('##theme', tema, items)then
                ini.settings.theme = tema.v
                inicfg.save(def, directIni)
            end imgui.PopItemWidth()
            imgui.SameLine(260)
            imgui.Text(u8'Выбор стиля: ') imgui.SameLine()
            imgui.PushItemWidth(150)
            if imgui.Combo('##style', style, styles)then
                ini.settings.style = style.v
                inicfg.save(def, directIni)
            end imgui.PopItemWidth()
			imgui.NewLine() imgui.NewLine() imgui.SameLine(15)
			imgui.Text(u8'Активация:      ') imgui.SameLine()
			if imadd.HotKey("##active", ActiveMenu, tLastKeys, 100) then
                rkeys.changeHotKey(bindID, ActiveMenu.v)
                SCM("Успешно! Старое значение: " .. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. " | Новое: " .. table.concat(rkeys.getKeysName(ActiveMenu.v), " + "), -1)
				ini.settings.key1 = ActiveMenu.v[1]
				ini.settings.key2 = ActiveMenu.v[2]
				inicfg.save(def, directIni)
            end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15)
            imgui.Text(u8'FA иконки:') imgui.SameLine(290)
            if imadd.ToggleButton(u8'##faedit', faedit) then
                ini.settings.faedit = faedit.v
                ini.settings.reload = true
                inicfg.save(def, directIni)
                lua_thread.create(function() wait(130) thisScript():reload() end)
                
            end imgui.NewLine()
			imgui.SameLine(15)
            imgui.Text(u8'Автоматически отвечать администрации:') imgui.SameLine(290)
            if imadd.ToggleButton(u8'##auto', auto) then
                ini.settings.auto = auto.v
                inicfg.save(def, directIni)
            end imgui.SameLine() ShowHelpMarker(u8'Отвечать на вопросы: Вы тут?')
            imgui.NewLine() 
			imgui.SameLine(15)
            imgui.Text(u8'Работа в свёрнутом режиме:') imgui.SameLine(290)
            if imadd.ToggleButton(u8'##bg', bg) then
                ini.settings.bg = bg.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8'Может работать некорректно')


            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) 
            if faico then
                if imgui.Button(fa.ICON_FA_UPLOAD ..  u8'   Проверить обновления') then
                    local fpath = os.getenv('TEMP') .. '\\farmbot_version.json' -- куда будет качаться наш файлик для сравнения версии
                    downloadUrlToFile('https://raw.githubusercontent.com/danil8515/Farm-bot/master/FA%20icons%20edition/version.json', fpath, function(id, status, p1, p2) -- ссылку на ваш гитхаб где есть строчки которые я ввёл в теме или любой другой сайт
                        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                            local f = io.open(fpath, 'r') -- открывает файл
                            if f then
                                local info = decodeJson(f:read('*a')) -- читает
                                updatelink = info.updateurl
                                if info and info.latest then
                                    version = tonumber(info.latest) -- переводит версию в число
                                    ver = tonumber(info.ver)
                                    if version > thisScript().version_num then -- если версия больше чем версия установленная то...
                                        new = 1
                                        SCM(('Доступно обновление!'))
                                    else -- если меньше, то
                                        update = false -- не даём обновиться
                                        SCM(('У вас установлена последния версия!'))
                                    end
                                end
                            end
                        end
                    end)
                end
            else
                if imgui.Button(u8'Проверить обновления') then
                    local fpath = os.getenv('TEMP') .. '\\farmbot_version.json' -- куда будет качаться наш файлик для сравнения версии
                    downloadUrlToFile('https://raw.githubusercontent.com/danil8515/Farm-bot/master/version.json', fpath, function(id, status, p1, p2) -- ссылку на ваш гитхаб где есть строчки которые я ввёл в теме или любой другой сайт
                        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                            local f = io.open(fpath, 'r') -- открывает файл
                            if f then
                                local info = decodeJson(f:read('*a')) -- читает
                                updatelink = info.updateurl
                                if info and info.latest then
                                    version = tonumber(info.latest) -- переводит версию в число
                                    ver = tonumber(info.ver)
                                    if version > thisScript().version_num then -- если версия больше чем версия установленная то...
                                        new = 1
                                        SCM(('Доступно обновление!'))
                                    else -- если меньше, то
                                        update = false -- не даём обновиться
                                        SCM(('У вас установлена последния версия!'))
                                    end
                                end
                            end
                        end
                    end)
                end
            end


			if new == 1 then
				imgui.SameLine()
				if imgui.Button(u8'Обновить') then
					gou = true
				end
            end
            
            imgui.SetCursorPos(imgui.ImVec2(560, 220))
            if imgui.Button(u8'ChangeLog', imgui.ImVec2(100, 25)) then 
                changelog_window.v = not changelog_window.v
            end
            imgui.EndGroup()
        end

        if vkladki[5] == true then -- Информация
			imgui.BeginGroup()
			imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200)
            if faico then imgui.Text(u8'Информация  '..fa.ICON_FA_INFO_CIRCLE) else imgui.Text(u8'Информация') end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine()
            imgui.NewLine()
			imgui.SameLine(210)
            imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), u8'Внимание!')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8'За ваш аккаунт несёте отвественность только вы!')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8'Если вас забанят за бота, то это чисто ваша вина.')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8'Рекомендуется не отходить далеко от компьютера...')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8'...чтобы вовремя среагировать на ответы админов.')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.NewLine() imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8'Автор: Даниил Копнев')
			imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8'Группа: vk.com/kscripts   ')
			imgui.SameLine(290) if imgui.Button(u8'Перейти') then os.execute('explorer "https://vk.com/kscripts"') end
			imgui.NewLine() imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8'Версия скрипта: '..thisScript().version)
			if new == 1 then imgui.SameLine() imgui.Text(u8'( Доступна новая версия: '..ver..' )') else
				imgui.SameLine() imgui.Text(u8'( Последняя версия )') end
			imgui.EndGroup()
		end

        imgui.End()
    end

    if settings_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 5, imgui.GetIO().DisplaySize.y / 7), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Настройка для группы', settings_window, 64)
		imgui.Text(u8'Введите данные группы: ')
		imgui.InputInt(u8'Введите ID группы', id, 0)
        imgui.InputText(u8'Введите Token группы', GroupToken) 
        imgui.SameLine()
		imgui.NewLine() imgui.NewLine()
        imgui.SameLine(350) if imgui.Button(u8'Сохранить') then
            ini.vk.token = GroupToken.v
            ini.vk.id = id.v
            inicfg.save(def, directIni)
            settings_window.v = false
        end
		imgui.End()
    end

    if loop_window.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowSize(imgui.ImVec2(350, 140), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Установка задержки', loop_window, 2)
		imgui.NewLine()
		imgui.NewLine()
		imgui.SameLine(15) imgui.Text(u8'Установка задержки:') imgui.SameLine(150) 
		imgui.PushItemWidth(190) 
		if imgui.InputInt('sec ', d_loop, 1) then
			ini.settings.d_loop = d_loop.v
			inicfg.save(def, directIni)
		end
		imgui.PopItemWidth()
		imgui.NewLine() imgui.NewLine()
		imgui.SameLine(15) imgui.Text(u8'Вспомогательный текст:') imgui.SameLine(170) 
		if imadd.ToggleButton("##helptext", helptext) then
			ini.settings.helptext = helptext.v
			inicfg.save(def, directIni)
		end
		imgui.SameLine() ShowHelpMarker(u8'Текст до или после начала процесса употребления еды: "Поспали, теперь можно и поесть" или "Поели, теперь можно и поспать"')
		imgui.SetCursorPos(imgui.ImVec2(260, 110))
		if imgui.Button(u8'Закрыть', imgui.ImVec2(80, 25)) then
			loop_window.v = false
		end
		imgui.End()
    end
    
    if changelog_window.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400, 500), imgui.Cond.FirstUseEver)
		imgui.Begin(' ', changelog_window, 2)
		
		imgui.SameLine(150)
		imgui.Text(u8'Список изменений')
		imgui.NewLine()
		--imgui.NewLine()
		--imgui.SameLine(25)
		imgui.BeginGroup()
			
			imgui.Separator() imgui.NewLine() imgui.NewLine() imgui.SameLine(170)
			imgui.Text(u8'V 1.5') imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'1. Доработана система Анти-Голод.') imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'2. Переделана система "Стили и Темы".') imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'3. Возможность откючать FA icons.') imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'4. Кнопка "Начать" перенесена левее.') imgui.NewLine() imgui.NewLine()
		imgui.EndGroup()
		imgui.SetCursorPos(imgui.ImVec2(300, 460))
		if imgui.Button(u8"Закрыть", imgui.ImVec2(80, 25)) then 
			changelog_window.v = false
		end
		imgui.End()
	end
end

function uu()
    for i = 0,5 do
        vkladki[i] = false
    end
end

-------------------------------Жизненно необходимые потоки-------------------------------------------
huy222 = true
lua_thread.create(function() 
    while true do
        wait(0)
        if ww == true then
            wait(1500)
            ww = false
        end
        if not huy228 then
            wait(5000)
            huy228 = true
        end
    end
end)

lua_thread.create(function() 
    while true do
        wait(0)
        if ww then
            lua_thread.create(function() 
            while ww do
                wait(0)
                setGameKeyState(0,255)
                setGameKeyState(14, 255)
            end end)
        end
    end
end)
-------------------------------Я знаю можно было проще-------------------------------------------

function rideTo(x,y,z,speed)
	while true do
		wait(0)
        if not isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then break end
        if not work1 then break end

        if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) and not gopay then
            sampSendChat('/engine')
        end

		local posX, posY, posZ = GetCoordinates() -- тут понятно
		local pX = x - posX
		local pY = y - posY
		local zAngle = getHeadingFromVector2d(pX, pY) -- получаем угол
		ang1 = getCarHeading(getCarCharIsUsing(PLAYER_PED)) -- угол авто
		
		local angsum = 360 - ang1 + zAngle 	-- очень интересный момент, у меня по геометрии средний бал 3,6 , но я путем какого-то анализа сделал
		if angsum > 360 then				-- эту сумму, которая нужна дальше
			angsum = angsum - 360 			-- если эта сумма больше 360 то вычитаем 360, в итоге получается число от 0 до 360
        end
		if angsum < 180 and not ww then -- так вот, если сумма меньше 180, то нужно поворачивать налево, а если больше, то направо. Ну тут 100 проц багов нет, провено
			local aang = angsum
			if aang > 8 then  -- если градус больше 10 то он резко поворачивает
				setGameKeyState(0,-255) -- ну типо если - 255 то колеса сильнее поворачиваются
			else	
				setGameKeyState(0,-7) -- а тут слегка, но все равно резко, пробуй -3 мб
			end
		else -- поворачиваем направо
			local aang = 360 - angsum
			if aang > 5 then -- анологично строкам 18-22
				setGameKeyState(0,230)
			else
				setGameKeyState(0,3)
			end
		end
		
		local dista = getDistanceBetweenCoords3d(x,y,z, posX, posY, z)
		if dista < 1 then break end -- проверка на дистанцию до точки, и если что прерываем цикл, а вообще сам цикл бесеонечный
		
        local skorost = getCarSpeed(getCarCharIsUsing(PLAYER_PED) ) -- текущая скорость авто

        if skorost < 0.5 and huy228 and not gopay then
            ww = true
            huy228 = false
		end
		
		if skorost < speed and not ww then
			setGameKeyState(14,-255) -- газ, я долго его искал, на самом деле это тормоз, в keys.lua это BRAKE, но если ставить отрицательные значения то газует
		else
			if skorost - speed > 0 and not ww then
				setGameKeyState(6,255) -- тормоз на пробел
			end
		end
        -- и да, тут нету функции тормоза, так что 
	end
end

function BeginToPoint(x, y, z, radius, move_code, isSprint)
    repeat
        wait(0)
        if not work and not work1 then break end
        local posX, posY, posZ = GetCoordinates()
        local vehHandle = nil
        vehHandle = getNearestVehicle(15)
        if vehHandle ~= nil then
            setCarCollision(vehHandle, true)
        end
        SetAngle(x, y, z)
        MovePlayer(move_code, isSprint)
        local dist = getDistanceBetweenCoords3d(x, y, z, posX, posY, posZ)
    until dist < radius 
    --Ой девачки, я в ахуе от такого ПРО кода
    if x == -105.7775 and y == 100.9354 and z == 3.1172 then 
        onpoint2 = true
    else   
        if x == -120.1061 and y == 88.2469 and z == 3.1172 then -- Идёт за зп
        lua_thread.create(function() 
        BeginToPoint(-106.0395,71.8690,3.1172, 3, -255, true) end)
        else 
            if x == -106.0395 and y == 71.8690 and z == 3.1172 then
            lua_thread.create(function() 
            BeginToPoint(-80.4831,82.9485,3.1096, 1.1, -255, true) end)
            else   
                if x == -80.4831 and y == 82.9485 and z == 3.1096 then
                        lua_thread.create(function() 
                            while true do
                                wait(150)
                                setGameKeyState(21, 255) -- альт
                                break
                            end
                        end)
                    else
                    if x ~= -92.8096 and y ~= 93.2234 and z ~= 3.1172 then onpoint = true end
                end
            end 
        end 
    end
end -- -120.1061,88.2469,3.1172

function MovePlayer(move_code, isSprint)
    setGameKeyState(1, move_code)
    --[[255 - обычный бег назад
       -255 - обычный бег вперед
      65535 - идти шагом вперед
     -65535 - идти шагом назад]]
    if isSprint then setGameKeyState(16, 255) end
end
 
function SetAngle(x, y, z)
    local posX, posY, posZ = GetCoordinates()
    local pX = x - posX
    local pY = y - posY
    local zAngle = getHeadingFromVector2d(pX, pY)
 
    if isCharInAnyCar(playerPed) then
        local car = storeCarCharIsInNoSave(playerPed)
        setCarHeading(car, zAngle)
    else
        setCharHeading(playerPed, zAngle)
    end
 
    restoreCameraJumpcut()
end
 
function GetCoordinates()
    if isCharInAnyCar(playerPed) then
        local car = storeCarCharIsInNoSave(playerPed)
        return getCarCoordinates(car)
    else
        return getCharCoordinates(playerPed)
    end
end

function getNearestVehicle(radius)
    if not sampIsLocalPlayerSpawned() then return end

    local pVehicle = getLocalVehicle()
    local pCoords = {getCharCoordinates(PLAYER_PED)}
    local vehicles = getAllVehicles()

    -- Sort vehicles by distance to local player
    table.sort(vehicles, function(a, b)
        local aX, aY, aZ = getCarCoordinates(a)
        local bX, bY, bZ = getCarCoordinates(b)
        return getDistanceBetweenCoords3d(aX, aY, aZ, unpack(pCoords)) < getDistanceBetweenCoords3d(bX, bY, bZ, unpack(pCoords))
    end)

    -- Remove local player's vehicle and filter vehicles, whose distance exceeding radius
    for i = #vehicles, 1, -1 do
        if vehicles[i] == pVehicle then
            table.remove(vehicles, i)
        elseif radius ~= nil then
            local x, y, z = getCarCoordinates(vehicles[i])
            if getDistanceBetweenCoords3d(x, y, z, unpack(pCoords)) > radius then
                table.remove(vehicles, i)
            end
        end
    end

    return vehicles[1]
end

function getLocalVehicle()
    return isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or nil
end

function readBitstream(bs) -- Анти-Голод от Хавка
	local data = {}
	data.id = raknetBitStreamReadInt16(bs)
	raknetBitStreamIgnoreBits(bs, 104)
	data.hun = raknetBitStreamReadFloat(bs) - textdraw.numb
	raknetBitStreamIgnoreBits(bs, 32)
	data.color = raknetBitStreamReadInt32(bs)
	raknetBitStreamIgnoreBits(bs, 64)
	data.x = raknetBitStreamReadFloat(bs)
	data.y = raknetBitStreamReadFloat(bs)
	return data
end

function char_to_hex(str)
    return string.format("%%%02X", string.byte(str))
end
  
function url_encode(str)
    local str = string.gsub(str, "\\", "\\")
    local str = string.gsub(str, "([^%w])", char_to_hex)
    return str
end

function WorkInBackground(work)
    local memory = require 'memory'
    if work then
        memory.setuint8(7634870, 1)
        memory.setuint8(7635034, 1)
        memory.fill(7623723, 144, 8)
        memory.fill(5499528, 144, 6)
    else
        memory.setuint8(7634870, 0)
        memory.setuint8(7635034, 0)
        memory.hex2bin('5051FF1500838500', 7623723, 8)
        memory.hex2bin('0F847B010000', 5499528, 6)
    end
end

function onScriptTerminate(LuaScript, quitGame)
	if LuaScript == thisScript() and not quitGame and not ini.settings.reload and not ini.settings.reloadR then
		sampShowDialog(6405, "                                        {FF0000}Произошла ошибка!", "{FFFFFF}Этот сообщение может быть ложным, если вы \nиспользовали скрипт AutoReboot \n\nК сожалению скрипт {F1CB09}Farm-Bot{FFFFFF} завершился неудачно\nЕсли вы хотите помочь разработчику\nТо можете описать при каком действии произошла ошибка\nНаша группа: {0099CC}vk.com/kscripts", "ОК", "", DIALOG_STYLE_MSGBOX)
		SCM('Произошла ошибка')
		showCursor(false, false)
	end
end

function update()
    local fpath = os.getenv('TEMP') .. '\\farmbot_version.json' -- куда будет качаться наш файлик для сравнения версии
    downloadUrlToFile('https://raw.githubusercontent.com/danil8515/Farm-bot/master/version.json', fpath, function(id, status, p1, p2) -- ссылку на ваш гитхаб где есть строчки которые я ввёл в теме или любой другой сайт
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
        local f = io.open(fpath, 'r') -- открывает файл
        if f then
            local info = decodeJson(f:read('*a')) -- читает
            updatelink = info.updateurl
            if info and info.latest then
            version = tonumber(info.latest) -- переводит версию в число
            ver = tonumber(info.ver)
            if version > thisScript().version_num then -- если версия больше чем версия установленная то...
                new = 1
                        SCM(('Доступно обновление!'))
                else -- если меньше, то
                update = false -- не даём обновиться
                SCM(('У вас установлена последния версия!'))
            end
            end
        end
        end
    end)
end
  
function goupdate()
    gou = false
    SCM(('Обнаружено обновление. AutoReload может конфликтовать. Обновляюсь...'))
    SCM(('Текущая версия: '..thisScript().version..". Новая версия: "..ver))
    wait(300)
    downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- качает ваш файлик с latest version
        if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
        SCM(('Обновление завершено!'))
        thisScript():reload()
        end
    end)
end

function SCM(arg1)
	sampAddChatMessage("[Farm-bot]: {FFFFFF}"..arg1, 0xF1CB09)
end

function theme1()
	local style = imgui.GetStyle()
	local Colors = style.Colors
    local ImVec4 = imgui.ImVec4
		    Colors[imgui.Col.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
		    Colors[imgui.Col.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
		    Colors[imgui.Col.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		    Colors[imgui.Col.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		    Colors[imgui.Col.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
		    Colors[imgui.Col.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
		    Colors[imgui.Col.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		    Colors[imgui.Col.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
		    Colors[imgui.Col.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
		    Colors[imgui.Col.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		    Colors[imgui.Col.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
		    Colors[imgui.Col.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
		    Colors[imgui.Col.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		    Colors[imgui.Col.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		    Colors[imgui.Col.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
		    Colors[imgui.Col.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
		    Colors[imgui.Col.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
		    Colors[imgui.Col.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
		    Colors[imgui.Col.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
		    Colors[imgui.Col.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		    Colors[imgui.Col.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
		    Colors[imgui.Col.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		    Colors[imgui.Col.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
		    Colors[imgui.Col.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function theme2()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function theme3()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function theme4()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function theme5()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
	style.Alpha = 1.0
	style.Colors[clr.Text] = ImVec4(1.000, 1.000, 1.000, 1.000)
	style.Colors[clr.TextDisabled] = ImVec4(0.000, 0.543, 0.983, 1.000)
	style.Colors[clr.WindowBg] = ImVec4(0.000, 0.000, 0.000, 0.895)
	style.Colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	style.Colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	style.Colors[clr.Border] = ImVec4(0.184, 0.878, 0.000, 0.500)
	style.Colors[clr.BorderShadow] = ImVec4(1.00, 1.00, 1.00, 0.10)
	style.Colors[clr.TitleBg] = ImVec4(0.026, 0.597, 0.000, 1.000)
	style.Colors[clr.TitleBgCollapsed] = ImVec4(0.099, 0.315, 0.000, 0.000)
	style.Colors[clr.TitleBgActive] = ImVec4(0.026, 0.597, 0.000, 1.000)
	style.Colors[clr.MenuBarBg] = ImVec4(0.86, 0.86, 0.86, 1.00)
	style.Colors[clr.ScrollbarBg] = ImVec4(0.000, 0.000, 0.000, 0.801)
	style.Colors[clr.ScrollbarGrab] = ImVec4(0.238, 0.238, 0.238, 1.000)
	style.Colors[clr.ScrollbarGrabHovered] = ImVec4(0.238, 0.238, 0.238, 1.000)
	style.Colors[clr.ScrollbarGrabActive] = ImVec4(0.004, 0.381, 0.000, 1.000)
	style.Colors[clr.CheckMark] = ImVec4(0.009, 0.845, 0.000, 1.000)
	style.Colors[clr.SliderGrab] = ImVec4(0.139, 0.508, 0.000, 1.000)
	style.Colors[clr.SliderGrabActive] = ImVec4(0.139, 0.508, 0.000, 1.000)
	style.Colors[clr.Button] = ImVec4(0.000, 0.000, 0.000, 0.400)
	style.Colors[clr.ButtonHovered] = ImVec4(0.000, 0.619, 0.014, 1.000)
	style.Colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
	style.Colors[clr.Header] = ImVec4(0.26, 0.59, 0.98, 0.31)
	style.Colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
	style.Colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
	style.Colors[clr.ResizeGrip] = ImVec4(0.000, 1.000, 0.221, 0.597)
	style.Colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
	style.Colors[clr.ResizeGripActive] = ImVec4(0.26, 0.59, 0.98, 0.95)
	style.Colors[clr.PlotLines] = ImVec4(0.39, 0.39, 0.39, 1.00)
	style.Colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
	style.Colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
	style.Colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	style.Colors[clr.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
	style.Colors[clr.ModalWindowDarkening] = ImVec4(0.20, 0.20, 0.20, 0.35)

	style.ScrollbarSize = 16.0
	style.GrabMinSize = 8.0
	style.WindowRounding = 0.0

	style.AntiAliasedLines = true
end

function theme6()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	colors[clr.Text] = ImVec4(0.90, 0.90, 0.90, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
	colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
	colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function theme7()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
    colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
    colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
    colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
    colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
    colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
    colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
    colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
    colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
    colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
    colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24);
    colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
    colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
    colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
    colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
    colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
    colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
    colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
    colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
	colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
end

function theme8()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
    colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
    colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
    colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
    colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
    colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
    colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
    colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
    colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
    colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
    colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
    colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
    colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
    colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
    colors[clr.CloseButton]            = ImVec4(0.45, 0.45, 0.45, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.70, 0.70, 0.90, 0.60)
    colors[clr.CloseButtonActive]      = ImVec4(0.70, 0.70, 0.70, 1.00)
    colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
end

function easy_style()
	imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowPadding = imgui.ImVec2(9, 14)
    style.WindowRounding = 10
    style.ChildWindowRounding = 10
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 6.0
    style.ItemSpacing = imgui.ImVec2(9.0, 3.0)
    style.ItemInnerSpacing = imgui.ImVec2(9.0, 3.0)
    style.IndentSpacing = 21
    style.ScrollbarSize = 6.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 17.0
    style.GrabRounding = 16.0

    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
end

function strong_style()
	imgui.SwitchContext()
    local style = imgui.GetStyle()

    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 2
    style.ChildWindowRounding = 2
    style.FramePadding = imgui.ImVec2(4, 3)
    style.FrameRounding = 2
    style.ItemSpacing = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing = imgui.ImVec2(4, 4)
    style.IndentSpacing = 21
    style.ScrollbarSize = 13
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8
    style.GrabRounding = 1

    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
end