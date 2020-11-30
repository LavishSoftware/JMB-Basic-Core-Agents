objectdef brrSettings
{
    variable filepath AgentFolder="${Script.CurrentDirectory}"
    
    variable jsonvalue hotkeyToggleRoundRobin="$$>
    {
        "controls":"F12"
    }
    <$$"

    method Initialize()
    {
        Overrides:SetValue["$$>
    {
        "F12":{"ignore":true},
        "${Input.Button[160]}":{"ignore":true},
        "${Input.Button[161]}":{"ignore":true},
        "${Input.Button[162]}":{"ignore":true},
        "${Input.Button[163]}":{"ignore":true},
        "${Input.Button[164]}":{"ignore":true},
        "${Input.Button[165]}":{"ignore":true}
    }<$$"]
    
        This:Load
    }

    method Load()
    {
        variable jsonvalue jo
        if !${AgentFolder.FileExists[bwl.Settings.json]}
            return

        if !${jo:ParseFile["${AgentFolder~}/bwl.Settings.json"](exists)} || !${jo.Type.Equal[object]}
        {
            return
        }


        if ${jo.Has[enable]}
            Enable:Set["${jo.Get[enable]~}"]

        variable jsonvalue joHotkeys
        joHotkeys:SetValue["${jo.Get[hotkeys].AsJSON~}"]

        if ${joHotkeys.Type.Equal[object]}
        {
            if ${joHotkeys.Has[toggleRoundRobin]}
                hotkeyToggleRoundRobin:SetValue["${joHotkeys.Get[toggleRoundRobin].AsJSON~}"]
        }
    }


    method Store()
    {
        variable jsonvalue jo
        jo:SetValue["${This.AsJSON~}"]
        jo:WriteFile["${AgentFolder~}/brr.Settings.json",TRUE]
    }

    member AsJSON()
    {
        variable jsonvalue jo
        jo:SetValue["$$>
        {
            "enable":${Enable.AsJSON~},
            "overrides":${Overrides.AsJSON~},
            "hotkeys":{
                "toggleRoundRobin":${hotkeyToggleRoundRobin.AsJSON~}
            }
        }
        <$$"]
        return "${jo.AsJSON~}"
    }

    variable bool Enable=FALSE
    variable jsonvalue Overrides
}
