objectdef bwshSession
{
    variable taskmanager TaskManager=${LMAC.NewTaskManager["bwshSession"]}

    variable jsonvalue SlotHotkeys="[]"
    variable bool Enabled=0
    variable bool HotkeyInstalled
    variable filepath AgentFolder="${Script.CurrentDirectory}"

    variable string NextWindowKey="Ctrl+Alt+X"
    variable string PreviousWindowKey="Ctrl+Alt+Z"

    method Initialize()
    {
        LavishScript:RegisterEvent[OnHotkeyFocused]

        This:LoadSettings
        This:Enable

;        LGUI2.Element[consolewindow]:SetVisibility[Visible]
    }

    method Shutdown()
    {
        ; shut down the Task Manager, ensuring that any hotkey we're still holding is effectively released
        TaskManager:Destroy

        This:Disable
    }

    method LoadSettings()
    {
        variable jsonvalue jo

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

    method Enable()
    {
        if ${Enabled}
            return

        Enabled:Set[1]
        This:InstallHotkeys
    }

    method Disable()
    {
        if !${Enabled}
            return
        Enabled:Set[0]
        This:UninstallHotkeys
    }

    ; Installs a Hotkey, given a name, a key combination, and LavishScript code to execute on PRESS
    method InstallHotkey(string name, string keyCombo, string methodName)
    {
        variable jsonvalue joBinding
        ; initialize a LGUI2 input binding object with JSON
        joBinding:SetValue["$$>
        {
            "name":${name.AsJSON~},
            "combo":${keyCombo.AsJSON~},
            "eventHandler":{
                "type":"task",
                "taskManager":"bwshSession",
                "task":{
                    "type":"ls1.code",
                    "start":${methodName.AsJSON~}
                }
            }
        }
        <$$"]

        ; now add the binding to LGUI2!
        LGUI2:AddBinding["${joBinding.AsJSON~}"]
    }

    method InstallHotkeys()
    {
        variable uint i
        for (i:Set[1] ; ${i}<=${SlotHotkeys.Used} ; i:Inc)
        {
            This:InstallHotkey[bwsh.Slot${i},"${SlotHotkeys.Get[${i}]~}","BWSHSession:OnSlotHotkey[${i}]"]
        }

        if ${NextWindowKey.NotNULLOrEmpty}
            This:InstallHotkey[bwsh.NextWindow,"${NextWindowKey~}","BWSHSession:NextWindow"]
        if ${PreviousWindowKey.NotNULLOrEmpty}
            This:InstallHotkey[bwsh.PreviousWindow,"${PreviousWindowKey~}","BWSHSession:PreviousWindow"]
    }

    member:uint GetNextSlot()
    {
        variable uint Slot=${JMB.Slot}
        if !${Slot}
            return 0

        Slot:Inc
        if ${Slot}>${JMB.Slots.Used}
            return 1

        return ${Slot}
    }

    member:uint GetPreviousSlot()
    {
        variable uint Slot=${JMB.Slot}
        if !${Slot}
            return 0

        Slot:Dec
        if !${Slot}
            return ${JMB.Slots.Used}

        return ${Slot}
    }

    method PreviousWindow()
    {
        variable uint previousSlot=${This.GetPreviousSlot}
        if !${previousSlot}
            return

        if !${Display.Window.IsForeground}
            return

        uplink focus "jmb${previousSlot}"
        relay "jmb${previousSlot}" "Event[OnHotkeyFocused]:Execute"
    }

    method NextWindow()
    {
        variable uint nextSlot=${This.GetNextSlot}
        if !${nextSlot}
            return

        if !${Display.Window.IsForeground}
            return

        uplink focus "jmb${nextSlot}"
        relay "jmb${nextSlot}" "Event[OnHotkeyFocused]:Execute"
    }

    method OnSlotHotkey(uint numSlot)
    {
        uplink focus "jmb${numSlot}"
        relay "jmb${numSlot}" "Event[OnHotkeyFocused]:Execute"
    }
}

variable(global) bwshSession BWSHSession

function main()
{
    while 1
        waitframe
}