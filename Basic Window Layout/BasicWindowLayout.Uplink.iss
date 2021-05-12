#include "BasicWindowLayout.Common.iss"

objectdef bwlUplink
{
    variable bwlSettings Settings
    variable jsonvalue Layouts="$$>{
            "Vertical":{
                "name":"Vertical"                
            },
            "Horizontal":{
                "name":"Horizontal"
            },
            "Custom":{
                "name":"Custom"
            }
        }<$$"

    method Initialize()
    {
        LavishScript:RegisterEvent[JMB_OnSlotsUpdated]

        Event[JMB_OnSlotsUpdated]:AttachAtom[This:OnSlotsUpdated]
        LGUI2:LoadPackageFile[BasicWindowLayout.Uplink.lgui2Package.json]
        Settings:Store
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[BasicWindowLayout.Uplink.lgui2Package.json]
    }

    method ToggleFocusFollowsMouse()
    {
        This:SetFocusFollowsMouse[${Settings.FocusFollowsMouse.Not}]
    }

    method SetFocusFollowsMouse(bool newValue)
    {
        if ${newValue}==${Settings.FocusFollowsMouse}
            return
        Settings.FocusFollowsMouse:Set[${newValue}]
        Settings:Store

        ; push updated setting
        relay all "BWLSession.Settings.FocusFollowsMouse:Set[${newValue}]"
    }

    method ToggleAvoidTaskbar()
    {
        This:SetAvoidTaskbar[${Settings.AvoidTaskbar.Not}]
    }

    method SetAvoidTaskbar(bool newValue)
    {
        if ${newValue}==${Settings.AvoidTaskbar}
            return
        Settings.AvoidTaskbar:Set[${newValue}]
        Settings:Store

        ; push updated setting
        relay all "BWLSession.Settings.AvoidTaskbar:Set[${newValue}]"
    }

    method ToggleSwapOnActivate()
    {
        This:SetSwapOnActivate[${Settings.SwapOnActivate.Not}]
    }

    method SetSwapOnActivate(bool newValue)
    {
        if ${newValue}==${Settings.SwapOnActivate}
            return
        Settings.SwapOnActivate:Set[${newValue}]
        Settings:Store

        ; push updated setting
        relay all "BWLSession.Settings.SwapOnActivate:Set[${newValue}]"
    }

    method SetRescaleWindows(bool newValue)
    {
        if ${newValue}==${Settings.RescaleWindows}
            return
        Settings.RescaleWindows:Set[${newValue}]
        Settings:Store

        ; push updated setting
        relay all "BWLSession.Settings.RescaleWindows:Set[${newValue}]"
    }

    method ToggleSwapOnHotkeyFocused()
    {
        This:SetSwapOnHotkeyFocused[${Settings.SwapOnHotkeyFocused.Not}]
    }

    method SetSwapOnHotkeyFocused(bool newValue)
    {
        if ${newValue}==${Settings.SwapOnHotkeyFocused}
            return
        Settings.SwapOnHotkeyFocused:Set[${newValue}]
        Settings:Store

        ; push updated setting
        relay all "BWLSession.Settings.SwapOnHotkeyFocused:Set[${newValue}]"
    }

    method ToggleLeaveHole()
    {
        This:SetLeaveHole[${Settings.LeaveHole.Not}]
    }

    method SetLeaveHole(bool newValue)
    {
        if ${newValue}==${Settings.LeaveHole}
            return
        Settings.LeaveHole:Set[${newValue}]
        Settings:Store

        ; push updated setting
        relay all "BWLSession.Settings.LeaveHole:Set[${newValue}]"
    }    

    method SelectLayout(string newValue)
    {
        if ${newValue.Equal["${Settings.UseLayout~}"]}
            return

        Settings.UseLayout:Set["${newValue~}"]
        Settings:Store

        relay all "BWLSession:SelectLayout[${newValue.AsJSON~}]"
    }

    method ApplyWindowLayout()
    {
        relay foreground "BWLSession:ApplyWindowLayout"
    }

    method OnSlotsUpdated()
    {
        This:ApplyWindowLayout
    }

    method GenerateItemView_Layout()
	{
      ;  echo GenerateItemView_Layout ${Context(type)} ${Context.Args}

		; build an itemview lgui2element json
		variable jsonvalue joListBoxItem
		joListBoxItem:SetValue["${LGUI2.Template["basicWindowLayout.layoutView"].AsJSON~}"]
        		
		Context:SetView["${joListBoxItem.AsJSON~}"]
	}
}

variable(global) bwlUplink BWLUplink

function main()
{
    while 1
        waitframe
}