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

    method ToggleProfile(string newProfile)
    {
        if !${newProfile.NotNULLOrEmpty} || ${Settings.CurrentProfile.Name.Equal["${newProfile~}"]}
        {
;            echo "[BRR] Disabling"
            ; activating same profile is a toggle off
            Settings:ClearCurrentProfile

            ; push updated setting
            relay all "BRRSession:Disable"

            if ${RestoreFocusFollowsMouse}
            {
                BWLUplink:SetFocusFollowsMouse[TRUE]
            }
        }
        else
        {
;            echo "[BRR] Enabling"
            if !${Settings.CurrentProfile.Reference(exists)}
                RestoreFocusFollowsMouse:Set[${BWLUplink.Settings.FocusFollowsMouse}]

            BWLUplink:SetFocusFollowsMouse[FALSE]
            Settings:SetCurrentProfile["${newProfile~}"]

            ; push updated setting
            relay all "BRRSession:Enable[${newProfile.AsJSON~}]"
        }        
    }

}

variable(global) brrUplink BRRUplink

function main()
{
    while 1
        waitframe
}