#include "BasicRoundRobin.Common.iss"

objectdef brrUplink
{
    variable brrSettings Settings

    variable bool RestoreFocusFollowsMouse

    method Initialize()
    {
        LGUI2:LoadPackageFile[BasicRoundRobin.Uplink.lgui2Package.json]
        Settings:Store
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[BasicRoundRobin.Uplink.lgui2Package.json]
    }

    method NextWindow()
    {
        BWLSession:NextWindow
    }


    method ToggleEnable()
    {
        This:SetEnable[${Settings.Enable.Not}]
    }

    method SetEnable(bool newValue)
    {
        if ${newValue}==${Settings.Enable}
            return
        Settings.Enable:Set[${newValue}]

        if ${newValue}
        {
            RestoreFocusFollowsMouse:Set[${BWLUplink.FocusFollowsMouse}]
            BWLUplink:SetFocusFollowsMouse[FALSE]
        }
        else
        {
            if ${RestoreFocusFollowsMouse}
            {
                BWLUplink:SetFocusFollowsMouse[TRUE]
            }
        }

;        Settings:Store

        ; push updated setting
        if ${newValue}
            relay all "BRRSession:Enable"
        else
            relay all "BRRSession:Disable"
    }

}

variable(global) brrUplink BRRUplink

function main()
{
    while 1
        waitframe
}