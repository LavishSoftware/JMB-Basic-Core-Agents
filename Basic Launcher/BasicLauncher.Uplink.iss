objectdef basiclauncherSettings
{
   variable filepath AgentFolder="${Script.CurrentDirectory}"
    
    variable uint LaunchSlots=3

    variable string UseGame

    method Initialize()
    {    
        This:Load
    }

    method Load()
    {
        variable jsonvalue jo
        if !${AgentFolder.FileExists[bl.Settings.json]}
            return

        if !${jo:ParseFile["${AgentFolder~}/bl.Settings.json"](exists)} || !${jo.Type.Equal[object]}
        {
            return
        }

        if ${jo.Has[launchSlots]}
            LaunchSlots:Set["${jo.Get[launchSlots]~}"]

        if ${jo.Has[useGame]}
            UseGame:Set["${jo.Get[useGame]~}"]
    }


    method Store()
    {
        variable jsonvalue jo
        jo:SetValue["${This.AsJSON~}"]
        jo:WriteFile["${AgentFolder~}/bl.Settings.json",multiline]
    }

    member AsJSON()
    {
        variable jsonvalue jo
        jo:SetValue["$$>
        {
            "launchSlots":${LaunchSlots.AsJSON~},
            "useGame":${UseGame.AsJSON~},
        }
        <$$"]
        return "${jo.AsJSON~}"
    }
}

objectdef basiclauncher
{
    method Initialize()
    {
        LavishScript:RegisterEvent[GamesChanged]

        Event[GamesChanged]:AttachAtom[This:RefreshGames]

        Settings:Store
        This:RefreshGames
        LGUI2:LoadPackageFile[BasicLauncher.Uplink.lgui2Package.json]
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[BasicLauncher.Uplink.lgui2Package.json]
    }

    variable bool ReplaceSlots=TRUE
    variable jsonvalue Games="[]"

    variable basiclauncherSettings Settings

    method InstallCharacter(uint Slot)
    {
        variable string UseGameProfile="${Settings.UseGame~} Default Profile"

        variable jsonvalue jo
        jo:SetValue["$$>
        {
            "id":${Slot},
            "display_name":"Generic Character",
            "game":${Settings.UseGame.AsJSON~},
            "gameProfile":${UseGameProfile.AsJSON~}
            "virtualFiles":[
                {
                    "pattern":"*/Config.WTF",
                    "replacement":"{1}/Config.Generic.JMB${Slot}.WTF"
                },
                {
                    "pattern":"Software/Blizzard Entertainment/World of Warcraft/Client/\*",
                    "replacement":"Software/Blizzard Entertainment/World of Warcraft/Client-JMB${Slot}/\*"
                }
            ]
        }
        <$$"]
        JMB:AddCharacter["${jo.AsJSON~}"]
    }

    method Launch()
    {
        LGUI2.Element[bl.launchSlots]:PushTextBinding
        

        if ${ReplaceSlots}
        {
            JMB.Slots:ForEach["kill jmb\${ForEach.Value.Get[id]}"]
            JMB:ClearSlots
        }

        variable uint Slot
        variable uint NumAdded
        for (NumAdded:Set[1] ; ${NumAdded}<=${Settings.LaunchSlots} ; NumAdded:Inc)
        {
            Slot:Set["${JMB.AddSlot.ID}"]
            This:InstallCharacter[${Slot}]
            JMB.Slot[${Slot}]:SetCharacter[${Slot}]
            JMB.Slot[${Slot}]:Launch
        }
    }

    method Relaunch(uint numSlot)
    {
        if !${JMB.Slot[${numSlot}].ProcessID}
            JMB.Slot[${numSlot}]:Launch
    }
    
    method RelaunchMissingSlots()
    {
        JMB.Slots:ForEach["This:Relaunch[\${ForEach.Value.Get[id]}]"]
    }


    method SetGame(string newValue)
    {
        if ${newValue.Equal["${Settings.UseGame~}"]}
            return

        Settings.UseGame:Set["${newValue~}"]
        Settings:Store
    }

    method SetLaunchSlots(uint newValue)
    {
        if ${newValue}==${Settings.LaunchSlots}
            return
        Settings.LaunchSlots:Set[${newValue}]
        Settings:Store
    }

    method AllFullScreen()
    {
        relay all "WindowCharacteristics -pos -viewable ${Display.Monitor.Left},${Display.Monitor.Top} -size -viewable ${Display.Monitor.Width}x${Display.Monitor.Height} -frame none"
    }

    method ShowConsoles()
    {
        relay all "LGUI2.Element[consoleWindow]:SetVisibility[Visible]"
    }
    method HideConsoles()
    {
        relay all "LGUI2.Element[consoleWindow]:SetVisibility[Hidden]"
    }

    method CloseAll()
    {
        relay all exit
    }

    method GenerateItemView_Game()
	{
       ; echo GenerateItemView_Game ${Context(type)} ${Context.Args}

		; build an itemview lgui2element json
		variable jsonvalue joListBoxItem
		joListBoxItem:SetValue["${LGUI2.Template["BasicLauncher.gameView"].AsJSON~}"]
        		
		Context:SetView["${joListBoxItem.AsJSON~}"]
	}

    method RefreshGames()
    {
        variable jsonvalue jo="${JMB.GameConfiguration.AsJSON~}"
        jo:Erase["_set_guid"]

        variable jsonvalue jaKeys
        jaKeys:SetValue["${jo.Keys.AsJSON~}"]
        jo:SetValue["[]"]

        variable uint i
        for (i:Set[1] ; ${i}<=${jaKeys.Used} ; i:Inc)
        {
            jo:Add["$$>
            {
                "display_name":${jaKeys[${i}].AsJSON~}
            }
            <$$"]
        }
    
        Games:SetValue["${jo.AsJSON~}"]
        LGUI2.Element[BasicLauncher.events]:FireEventHandler[onGamesUpdated]
    }
}

variable(global) basiclauncher BasicLauncher

function main()
{
    while 1
        waitframe
}