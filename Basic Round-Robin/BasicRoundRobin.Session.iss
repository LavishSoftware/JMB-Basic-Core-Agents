#include "BasicRoundRobin.Common.iss"

objectdef brrSession
{
    variable taskmanager TaskManager=${LMAC.NewTaskManager["brrSession"]}
    variable brrSettings Settings
    variable bool Enabled

    method Initialize()
    {
        LGUI2:LoadPackageFile[BasicRoundRobin.Session.lgui2Package.json]
        if ${Settings.Enable}
            This:Enable

        This:EnableHotkeys
    }

    method Shutdown()
    {
        This:Disable
        This:DisableHotkeys
        TaskManager:Destroy
        LGUI2:UnloadPackageFile[BasicRoundRobin.Session.lgui2Package.json]
    }


    method EnableHotkeys()
    {
        variable jsonvalue joBinding
        if ${Settings.hotkeyToggleRoundRobin.Type.Equal[object]} && ${Settings.hotkeyToggleRoundRobin.Has[controls]}
        {
            joBinding:SetValue["${Settings.hotkeyToggleRoundRobin.AsJSON~}"]
            joBinding:Set[name,"\"brr.toggleRoundRobin\""]
            joBinding:Set[eventHandler,"$$>
            {
                "type":"task",
                "taskManager":"brrSession",
                "task":{
                    "type":"ls1.code",
                    "start":"uplink BRRUplink:ToggleEnable"
                }
            }
            <$$"]

            LGUI2:AddBinding["${joBinding.AsJSON~}"]
        }
    }

    method DisableHotkeys()
    {
        LGUI2:RemoveBinding["brr.toggleRoundRobin"]
    }
    method NextWindow()
    {
        BWLSession:NextWindow[${Settings.SwitchAsHotkey}]
    }

    method OnButtonHook()
    {
        variable bool Advance=${Settings.DefaultAllow}

        ; check for overrides

        variable jsonvalueref Override
        Override:SetReference["Settings.Overrides[${Context.Args[controlName].AsJSON~}]"]

        if ${Override.Type.Equal[object]}
        {

;            echo "Keyboard button released: \"${Context.Args[controlName]}\" override=${Override.AsJSON~}"

            if ${Override.Get[allow]}
            {
                Advance:Set[1]
            }
            if ${Override.Get[ignore]}
            {
                Advance:Set[0]
            }
        }
        else
        {
;            echo "Keyboard button released: \"${Context.Args[controlName]}\""
        }

        if ${Advance}
            This:NextWindow
    }

    method Enable()
    {
        LGUI2:LoadJSON["${LGUI2.Template[brr.allButtons].AsJSON~}"]
        Enabled:Set[1]
    }

    method Disable()
    {
        LGUI2.Element[basicRoundRobin.allButtons]:Destroy
        Enabled:Set[0]
    }
}

variable(global) brrSession BRRSession

function main()
{
    while 1
        waitframe
}