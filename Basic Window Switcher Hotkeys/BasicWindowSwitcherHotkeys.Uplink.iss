objectdef bwshUplink
{
    variable jsonvalue SlotHotkeys="[]"
    variable bool Enabled=1
    variable filepath AgentFolder="${Script.CurrentDirectory}"
    variable string NextWindowKey="Ctrl+Alt+X"
    variable string PreviousWindowKey="Ctrl+Alt+Z"

    method Initialize()
    {
        This:LoadSettings

        LGUI2:LoadPackageFile[BasicWindowSwitcherHotkeys.Uplink.lgui2Package.json]
        LGUI2.Element[bwsh.filename]:SetText["${AgentFolder.Replace["/","\\"]~}\\bwsh.Settings.json"]
    }
    
    method Shutdown()
    {
        This:Disable
        LGUI2:UnloadPackageFile[BasicWindowSwitcherHotkeys.Uplink.lgui2Package.json]
    }

    method LoadSettings()
    {
        variable jsonvalue jo

        if !${AgentFolder.FileExists[bwsh.Settings.json]}
        {
            jo:SetValue["$$>
            {
                "slotHotkeys":[
                    "Ctrl+Alt+1",
                    "Ctrl+Alt+2",
                    "Ctrl+Alt+3",
                    "Ctrl+Alt+4",
                    "Ctrl+Alt+5",
                    "Ctrl+Alt+6",
                    "Ctrl+Alt+7",
                    "Ctrl+Alt+8",
                    "Ctrl+Alt+9",
                    "Ctrl+Alt+0",
                    "Ctrl+Alt+-",
                    "Ctrl+Alt+=",
                ],
                "previousWindowHotkey":"Ctrl+Alt+Z",
                "nextWindowHotkey":"Ctrl+Alt+X"
            }
            <$$"]

            jo:WriteFile["${AgentFolder~}/bwsh.Settings.json",multiline]
        }

        if !${jo:ParseFile["${AgentFolder~}/bwsh.Settings.json"](exists)} || !${jo.Type.Equal[object]}
        {
            return
        }

        SlotHotkeys:SetValue["${jo.Get["slotHotkeys"].AsJSON~}"]
        if ${jo.Has[nextWindowHotkey]}
            NextWindowKey:Set["${jo.Get["nextWindowHotkey"]~}"]
        if ${jo.Has[previousWindowHotkey]}
            PreviousWindowKey:Set["${jo.Get["previousWindowHotkey"]~}"]

        if !${SlotHotkeys.Type.Equal[array]}
            SlotHotkeys:SetValue["[]"]
    }

    method StoreSettings()
    {
        variable jsonvalue jo
        jo:SetValue["${This.AsJSON~}"]
        jo:WriteFile["${AgentFolder~}/bwsh.Settings.json",multiline]
    }

    member AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:Set["slotHotkeys","${SlotHotkeys.AsJSON~}"]
        jo:Set["nextWindowHotkey","${NextWindowKey.AsJSON~}"]
        jo:Set["previousWindowHotkey","${PreviousWindowKey.AsJSON~}"]
        return "${jo.AsJSON~}"
    }

    method Enable()
    {
        if ${Enabled}
            return

        Enabled:Set[1]
        
        relay all BWSHSession:InstallHotkey
    }

    method Disable()
    {
        if !${Enabled}
            return
        Enabled:Set[0]
        relay all BWSHSession:UninstallHotkey
    }

}

variable(global) bwshUplink BWSHUplink

function main()
{
    while 1
        waitframe
}