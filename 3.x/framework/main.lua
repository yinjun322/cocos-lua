--===================================================
-- File Name    : main.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:54
-- Description  :
-- Modify       :
--===================================================


-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
__platform = cc.Application:getInstance():getTargetPlatform()
__write_path = cc.FileUtils:getInstance():getWritablePath()

local platform_name = {
	[cc.PLATFORM_OS_WINDOWS   ] = "Windows",
	[cc.PLATFORM_OS_LINUX     ] = "Linux",
	[cc.PLATFORM_OS_MAC       ] = "Mac",
	[cc.PLATFORM_OS_ANDROID   ] = "Android",
	[cc.PLATFORM_OS_IPHONE    ] = "iPhone",
	[cc.PLATFORM_OS_IPAD      ] = "iPad",
	[cc.PLATFORM_OS_BLACKBERRY] = "BlackBerry",
	[cc.PLATFORM_OS_NACL      ] = "nacl",
	[cc.PLATFORM_OS_EMSCRIPTEN] = "emscripten",
	[cc.PLATFORM_OS_TIZEN     ] = "tizen",
}

require("project.lua")
require("framework/preload.lua")
require(PROJECT_PATH.."/preload.lua")
assert(PreloadScript() == 1)

local function MainLoop(delta)
	if FetchConsoleCmd then
		local string = FetchConsoleCmd()
		if string then
			local f = loadstring(string)
			if f then
				xpcall(f, __G__TRACKBACK__)
			else
				cclog("Invalid CMD! %s", string)
			end
		end
	end
	local tbModule = nil
	function ModulLoop()
		tbModule:OnLoop(delta)
	end

	tbModule = Physics
	xpcall(ModulLoop, __G__TRACKBACK__)

	tbModule = GameMgr
	xpcall(ModulLoop, __G__TRACKBACK__)

	tbModule = SceneMgr
	xpcall(ModulLoop, __G__TRACKBACK__)
end

if __platform == cc.PLATFORM_OS_WINDOWS then
	function OnWin32End()
		Exit()
	end
end

local function main()
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	print("main start")
	
    if GameMgr.Preset then
    	GameMgr:Preset()
    end
    local director = cc.Director:getInstance()
	visible_size = director:getVisibleSize()
	local glview = director:getOpenGLView()
	resolution_size = glview:getDesignResolutionSize()
	
	math.randomseed(os.time())
	math.random(100)
	Event:Preload()
    assert(Debug:Init(Debug.MODE_BLACK_LIST) == 1)
    
    assert(SceneMgr:Init() == 1)
    if __Debug then
    	assert(SceneMgr:CheckAllClass() == 1)
    end
    assert(Resource:Init() == 1)
    assert(Physics:Init() == 1)
    assert(Ui:Init() == 1)
    CCDirector:getInstance():setDisplayStats(true)
    CCDirector:getInstance():getScheduler():scheduleScriptFunc(MainLoop, 0, false)
    print("================================================")
    print("Debug:", __Debug)
    print("Project:", PROJECT_PATH)
    print("Platform:", platform_name[__platform] or __platform) 
    if CCVersion then
		print("Version: ", CCVersion())
	end
    print(string.format("Resolution: %d * %d", resolution_size.width, resolution_size.height))
    print(string.format("Screen Size: %d * %d", visible_size.width, visible_size.height))   
	print("================================================")
    assert(GameMgr:Init() == 1)
end

--This function will be called when the app is inactive. When comes a phone call,it's be invoked too
function DidEnterBackground()
	-- body
end

--this function will be called when the app is active again
function WillEnterForeground()
	-- body
end

function Exit()
	GameMgr:Uninit()
	Ui:Uninit()
	Physics:Uninit()
	SceneMgr:Uninit()
	Net:Uninit()
end
xpcall(main, __G__TRACKBACK__)