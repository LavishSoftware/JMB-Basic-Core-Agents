#include "BasicWindowLayout.Common.iss"
#include "BasicWindowLayout.LayoutController.iss"

objectdef bwlSession
{
    variable taskmanager TaskManager=${LMAC.NewTaskManager["bwlSession"]}
    variable bwlSettings Settings
    variable bwlLayoutController LayoutController

    variable bwlHorizontalLayout HorizontalLayout
    variable bwlVerticalLayout VerticalLayout
    variable bwlCustomWindowLayout CustomLayout
    variable weakref CurrentLayout

    variable bool Applied

    method Initialize()
    {
        This:UpdateCurrentLayout

        LavishScript:RegisterEvent[On Activate]
        LavishScript:RegisterEvent[OnWindowStateChanging]
		LavishScript:RegisterEvent[OnMouseEnter]
		LavishScript:RegisterEvent[OnMouseExit]
        LavishScript:RegisterEvent[OnHotkeyFocused]

        Event[On Activate]:AttachAtom[This:OnActivate]
        Event[OnWindowStateChanging]:AttachAtom[This:OnWindowStateChanging]
		Event[OnMouseEnter]:AttachAtom[This:OnMouseEnter]
		Event[OnMouseExit]:AttachAtom[This:OnMouseExit]
        Event[OnHotkeyFocused]:AttachAtom[This:OnHotkeyFocused]

        This:EnableHotkeys
        FocusClick eat
    }

    method Shutdown()
    {
        This:DisableHotkeys
        TaskManager:Destroy
    }

    method UpdateCurrentLayout()
    {
        switch ${Settings.UseLayout}
        {
            default
            case Horizontal
                CurrentLayout:SetReference["HorizontalLayout"]
                break
            case Vertical
                CurrentLayout:SetReference["VerticalLayout"]
                break
            case Custom
                CurrentLayout:SetReference["CustomLayout"]
                break
        }
    }

    method SelectLayout(string newValue)
    {
        Settings.UseLayout:Set["${newValue~}"]
        This:UpdateCurrentLayout
    }

    method ApplyWindowLayout(bool setOtherSlots=TRUE)
    {
        CurrentLayout:ApplyWindowLayout[${setOtherSlots}]        
    }

    method OnActivate()
    {
        if ${Settings.SwapOnActivate} && !${Settings.FocusFollowsMouse}
            This:ApplyWindowLayout
        else
        {
            if !${Applied}
                This:ApplyWindowLayout[FALSE]
        }
    }

    method OnHotkeyFocused()
    {
        ; if it would have been handled by SwapOnActivate, don't do it again here
        if (!${Settings.SwapOnActivate} || ${Settings.FocusFollowsMouse}) && ${Settings.SwapOnHotkeyFocused}
        {
            This:ApplyWindowLayout
        }
        else
        {
            if !${Applied}
                This:ApplyWindowLayout[FALSE]
        }
    }

    method OnWindowStateChanging(string change)
    {
      ;  echo OnWindowStateChanging ${change~}
    }

    method ToggleFocusFollowsMouse()
    {
        echo ToggleFocusFollowsMouse
        uplink "BWLUplink:ToggleFocusFollowsMouse"
    }

    method ToggleSwapOnActivate()
    {
        echo ToggleSwapOnActivate
        uplink "BWLUplink:ToggleSwapOnActivate"
    }
    method ToggleLeaveHole()
    {
        uplink "BWLUplink:ToggleLeaveHole"
    }
    method ToggleAvoidTaskbar()
    {
        uplink "BWLUplink:ToggleAvoidTaskbar"
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

    method PreviousWindow(bool hotkeyFocused=TRUE)
    {
        variable uint previousSlot=${This.GetPreviousSlot}
        if !${previousSlot}
            return

        if !${Display.Window.IsForeground}
            return

        uplink focus "jmb${previousSlot}"
        if ${hotkeyFocused}
            relay "jmb${previousSlot}" "Event[OnHotkeyFocused]:Execute"
    }

    method NextWindow(bool hotkeyFocused=TRUE)
    {
        variable uint nextSlot=${This.GetNextSlot}
        if !${nextSlot}
            return

        if !${Display.Window.IsForeground}
            return

        uplink focus "jmb${nextSlot}"
        if ${hotkeyFocused}
            relay "jmb${nextSlot}" "Event[OnHotkeyFocused]:Execute"
    }

    method Fullscreen()
    {
        echo Fullscreen
        variable uint monitorWidth=${Display.Monitor.Width}
        variable uint monitorHeight=${Display.Monitor.Height}
        variable int monitorX=${Display.Monitor.Left}
        variable int monitorY=${Display.Monitor.Top}
        
        WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${monitorWidth}x${monitorHeight} -frame none        
    }

    method EnableHotkeys()
    {
        variable jsonvalue joBinding
        if ${Settings.hotkeyFullscreen.Type.Equal[object]} && ${Settings.hotkeyFullscreen.Has[controls]}
        {
            joBinding:SetValue["${Settings.hotkeyFullscreen.AsJSON~}"]
            joBinding:Set[name,"\"bwl.fullscreen\""]
            joBinding:Set[eventHandler,"$$>
            {
                "type":"task",
                "taskManager":"bwlSession",
                "task":{
                    "type":"ls1.code",
                    "start":"BWLSession:Fullscreen"
                }
            }
            <$$"]

            LGUI2:AddBinding["${joBinding.AsJSON~}"]
        }

        if ${Settings.hotkeyApplyWindowLayout.Type.Equal[object]} && ${Settings.hotkeyApplyWindowLayout.Has[controls]}
        {
            joBinding:SetValue["${Settings.hotkeyApplyWindowLayout.AsJSON~}"]
            joBinding:Set[name,"\"bwl.applyWindowLayout\""]
            joBinding:Set[eventHandler,"$$>
            {
                "type":"task",
                "taskManager":"bwlSession",
                "task":{
                    "type":"ls1.code",
                    "start":"BWLSession:ApplyWindowLayout"
                }
            }
            <$$"]

            LGUI2:AddBinding["${joBinding.AsJSON~}"]
        }

        if ${Settings.hotkeyToggleFocusFollowsMouse.Type.Equal[object]} && ${Settings.hotkeyToggleFocusFollowsMouse.Has[controls]}
        {
            joBinding:SetValue["${Settings.hotkeyToggleFocusFollowsMouse.AsJSON~}"]
            joBinding:Set[name,"\"bwl.toggleFocusFollowsMouse\""]
            joBinding:Set[eventHandler,"$$>
            {
                "type":"task",
                "taskManager":"bwlSession",
                "task":{
                    "type":"ls1.code",
                    "start":"BWLSession:ToggleFocusFollowsMouse"
                }
            }
            <$$"]

            LGUI2:AddBinding["${joBinding.AsJSON~}"]
        }


        if ${Settings.hotkeyToggleSwapOnActivate.Type.Equal[object]} && ${Settings.hotkeyToggleSwapOnActivate.Has[controls]}
        {
            joBinding:SetValue["${Settings.hotkeyToggleSwapOnActivate.AsJSON~}"]
            joBinding:Set[name,"\"bwl.toggleSwapOnActivate\""]
            joBinding:Set[eventHandler,"$$>
             {
                "type":"task",
                "taskManager":"bwlSession",
                "task":{
                    "type":"ls1.code",
                    "start":"BWLSession:ToggleSwapOnActivate"
                }
            }
            <$$"]

            LGUI2:AddBinding["${joBinding.AsJSON~}"]
        }

        if ${Settings.hotkeyNextWindow.Type.Equal[object]} && ${Settings.hotkeyNextWindow.Has[controls]}
        {
            joBinding:SetValue["${Settings.hotkeyNextWindow.AsJSON~}"]
            joBinding:Set[name,"\"bwl.nextWindow\""]
            joBinding:Set[eventHandler,"$$>
             {
                "type":"task",
                "taskManager":"bwlSession",
                "task":{
                    "type":"ls1.code",
                    "start":"BWLSession:NextWindow"
                }
            }
            <$$"]

            LGUI2:AddBinding["${joBinding.AsJSON~}"]
        }

        if ${Settings.hotkeyPreviousWindow.Type.Equal[object]} && ${Settings.hotkeyPreviousWindow.Has[controls]}
        {
            joBinding:SetValue["${Settings.hotkeyPreviousWindow.AsJSON~}"]
            joBinding:Set[name,"\"bwl.previousWindow\""]
            joBinding:Set[eventHandler,"$$>
             {
                "type":"task",
                "taskManager":"bwlSession",
                "task":{
                    "type":"ls1.code",
                    "start":"BWLSession:PreviousWindow"
                }
            }
            <$$"]

            LGUI2:AddBinding["${joBinding.AsJSON~}"]
        }

    }

    method DisableHotkeys()
    {
        LGUI2:RemoveBinding["bwl.fullscreen"]
        LGUI2:RemoveBinding["bwl.applyWindowLayout"]
        LGUI2:RemoveBinding["bwl.toggleFocusFollowsMouse"]
        LGUI2:RemoveBinding["bwl.toggleSwapOnActivate"]
        LGUI2:RemoveBinding["bwl.nextWindow"]
        LGUI2:RemoveBinding["bwl.previousWindow"]
    }

    method ApplyFocusFollowMouse()
    {
        if !${Settings.FocusFollowsMouse}
            return

        if ${Display.Window.IsForeground}
            return

        relay all "BWLSession:FocusSession[\"${Session~}\"]"
    }
     
    method FocusSession(string name)
    {
        if !${Display.Window.IsForeground}
            return
        uplink focus "${name~}"
    }

    method OnMouseEnter()
    {
        This:ApplyFocusFollowMouse
    }

    method OnMouseExit()
    {

    }
}

variable(global) bwlSession BWLSession

function main()
{
    while 1
    {
        waitframe
    }
}