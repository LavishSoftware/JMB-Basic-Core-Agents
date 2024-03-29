objectdef bwlSettings
{
    variable filepath AgentFolder="${Script.CurrentDirectory}"
    
    variable jsonvalue hotkeyToggleSwapOnActivate="$$>
    {
        "controls":"A",
        "modifiers":"shift+ctrl+alt"
    }
    <$$"
    variable jsonvalue hotkeyToggleFocusFollowsMouse="$$>
    {
        "controls":"M",
        "modifiers":"shift+ctrl+alt"
    }
    <$$"
    variable jsonvalue hotkeyFullscreen="$$>
    {
        "controls":"F",
        "modifiers":"shift+ctrl+alt"
    }
    <$$"
    variable jsonvalue hotkeyApplyWindowLayout="$$>
    {
        "controls":"W",
        "modifiers":"shift+ctrl+alt"
    }
    <$$"
    variable jsonvalue hotkeyNextWindow="$$>
    {
        "controls":"X",
        "modifiers":"shift+ctrl+alt"
    }
    <$$"
    variable jsonvalue hotkeyPreviousWindow="$$>
    {
        "controls":"Z",
        "modifiers":"shift+ctrl+alt"
    }
    <$$"

    method Initialize()
    {
        BWLSettings:SetReference[This]
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


        if ${jo.Has[swapOnHotkeyFocused]}
            SwapOnHotkeyFocused:Set["${jo.Get[swapOnHotkeyFocused]~}"]

        if ${jo.Has[swapOnActivate]}
            SwapOnActivate:Set["${jo.Get[swapOnActivate]~}"]

        if ${jo.Has[leaveHole]}
            LeaveHole:Set["${jo.Get[leaveHole]~}"]

        if ${jo.Has[focusFollowsMouse]}
            FocusFollowsMouse:Set["${jo.Get[focusFollowsMouse]~}"]

        if ${jo.Has[avoidTaskbar]}
            AvoidTaskbar:Set["${jo.Get[avoidTaskbar]~}"]

        if ${jo.Has[rescaleWindows]}
            RescaleWindows:Set["${jo.Get[rescaleWindows]~}"]

        if ${jo.Has[useLayout]}
            UseLayout:Set["${jo.Get[useLayout]~}"]

        if ${jo.Has[customLayout]}
            CustomLayout:SetValue["${jo.Get[customLayout].AsJSON~}"]

        if ${jo.Has[useMonitors]}
            UseMonitors:SetValue["${jo.Get[useMonitors].AsJSON~}"]

        variable jsonvalue joHotkeys
        joHotkeys:SetValue["${jo.Get[hotkeys].AsJSON~}"]

        if ${joHotkeys.Type.Equal[object]}
        {
            if ${joHotkeys.Has[toggleSwapOnActivate]}
                hotkeyToggleSwapOnActivate:SetValue["${joHotkeys.Get[toggleSwapOnActivate].AsJSON~}"]
            if ${joHotkeys.Has[toggleFocusFollowsMouse]}
                hotkeyToggleFocusFollowsMouse:SetValue["${joHotkeys.Get[toggleFocusFollowsMouse].AsJSON~}"]
            if ${joHotkeys.Has[fullscreen]}
                hotkeyFullscreen:SetValue["${joHotkeys.Get[fullscreen].AsJSON~}"]
            if ${joHotkeys.Has[applyWindowLayout]}
                hotkeyApplyWindowLayout:SetValue["${joHotkeys.Get[applyWindowLayout].AsJSON~}"]
            if ${joHotkeys.Has[nextWindow]}
                hotkeyNextWindow:SetValue["${joHotkeys.Get[nextWindow].AsJSON~}"]
            if ${joHotkeys.Has[previousWindow]}
                hotkeyPreviousWindow:SetValue["${joHotkeys.Get[previousWindow].AsJSON~}"]
        }
    }

    member:weakref GetMonitor(uint num)
    {
        if !${UseMonitors.Type.Equal[array]}
            return ${num}

        if ${UseMonitors.Used}<${num}
            return ${num}

        return "Display.Monitor[${UseMonitors.Get[${num}]}]"
    }

    member:string StealthFlag()
    {
        if ${RescaleWindows}
            return "-stealth "
        return ""
    }

    method Store()
    {
        variable jsonvalue jo
        jo:SetValue["${This.AsJSON~}"]
        jo:WriteFile["${AgentFolder~}/bwl.Settings.json",multiline]
    }

    member AsJSON()
    {
        variable jsonvalue jo
        jo:SetValue["$$>
        {
            "swapOnActivate":${SwapOnActivate.AsJSON~},
            "swapOnHotkeyFocused":${SwapOnHotkeyFocused.AsJSON~},
            "leaveHole":${LeaveHole.AsJSON~},
            "focusFollowsMouse":${FocusFollowsMouse.AsJSON~},
            "avoidTaskbar":${AvoidTaskbar.AsJSON~},
            "rescaleWindows":${RescaleWindows.AsJSON~},
            "hotkeys":{
                "toggleSwapOnActivate":${hotkeyToggleSwapOnActivate.AsJSON~},
                "toggleFocusFollowsMouse":${hotkeyToggleFocusFollowsMouse.AsJSON~},
                "fullscreen":${hotkeyFullscreen.AsJSON~},
                "applyWindowLayout":${hotkeyApplyWindowLayout.AsJSON~},
                "nextWindow":${hotkeyNextWindow.AsJSON~},
                "previousWindow":${hotkeyPreviousWindow.AsJSON~}
            },
            "useMonitors":${UseMonitors.AsJSON~}
            "useLayout":${UseLayout.AsJSON~},
            "customLayout":${CustomLayout.AsJSON~}
        }
        <$$"]
        return "${jo.AsJSON~}"
    }

    variable bool SwapOnActivate=TRUE
    variable bool SwapOnHotkeyFocused=TRUE
    variable bool LeaveHole=TRUE
    variable bool FocusFollowsMouse=FALSE    
    variable bool AvoidTaskbar=FALSE
    variable string UseLayout="Horizontal"
    variable bool RescaleWindows=TRUE

    variable jsonvalue UseMonitors="[1,2,3,4,5,6,7,8]"

    variable jsonvalue CustomLayout="$$>
    {
        "mainRegion":{
            "x":0,
            "y":0,
            "width":1920,
            "height":864
        },
        "regions":[
            {
                "x":0,
                "y":864,
                "width":384,
                "height":216
            },
            {
                "x":384,
                "y":864,
                "width":384,
                "height":216
            },
            {
                "x":768,
                "y":864,
                "width":384,
                "height":216
            },
            {
                "x":1152,
                "y":864,
                "width":384,
                "height":216
            },
            {
                "x":1536,
                "y":864,
                "width":384,
                "height":216
            }
        ]
    }
    <$$"
}

variable(global) weakref BWLSettings

; base class for window layouts
objectdef bwlLayout
{    
    method ApplyWindowLayout(bool setOtherSlots=TRUE)
    {

    }

    member ToText()
    {
        return "Unknown"   
    }
}

objectdef bwlHorizontalLayout
{
    member ToText()
    {
        return "Horizontal"   
    }

    method ApplyWindowLayout(bool setOtherSlots=TRUE)
    {
        variable jsonvalueref Slots="JMB.Slots"

        variable uint monitorWidth=${Display.Monitor.Width}
        variable uint monitorHeight=${Display.Monitor.Height}
        variable int monitorX=${Display.Monitor.Left}
        variable int monitorY=${Display.Monitor.Top}

        variable uint mainHeight
        variable uint numSmallRegions=${Slots.Used}
        variable uint mainWidth
        variable uint smallHeight
        variable uint smallWidth

        if ${BWLSettings.AvoidTaskbar}
        {
            monitorX:Set["${Display.Monitor.MaximizeLeft}"]
            monitorY:Set["${Display.Monitor.MaximizeTop}"]
            monitorWidth:Set["${Display.Monitor.MaximizeWidth}"]
            monitorHeight:Set["${Display.Monitor.MaximizeHeight}"]
        }


        ; if there's only 1 window, just go full screen windowed
        if ${numSmallRegions}==1
        {
            WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${monitorWidth}x${monitorHeight} -frame none
            BWLSession.Applied:Set[1]
            return
        }

        if !${BWLSettings.LeaveHole}
            numSmallRegions:Dec

        ; 2 windows is actually a 50/50 split screen and should probably handle differently..., pretend there's 3
        if ${numSmallRegions}<3
            numSmallRegions:Set[3]

        mainWidth:Set["${monitorWidth}"]
        mainHeight:Set["${monitorHeight}*${numSmallRegions}/(${numSmallRegions}+1)"]

        smallHeight:Set["${monitorHeight}-${mainHeight}"]
        smallWidth:Set["${monitorWidth}/${numSmallRegions}"]

        WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${mainWidth}x${mainHeight} -frame none
        BWLSession.Applied:Set[1]

        if !${setOtherSlots}
            return

        variable int useX
        variable uint numSlot

        variable uint slotID

        for (numSlot:Set[1] ; ${numSlot}<=${Slots.Used} ; numSlot:Inc)
        {
            slotID:Set["${Slots[${numSlot}].Get[id]~}"]
            if ${slotID}!=${JMB.Slot}
            {
                relay jmb${slotID} "WindowCharacteristics ${BWLSettings.StealthFlag}-pos -viewable ${useX},${mainHeight} -size -viewable ${smallWidth}x${smallHeight} -frame none"
                useX:Inc["${smallWidth}"]
            }
            else
            {
                if ${BWLSettings.LeaveHole}
                    useX:Inc["${smallWidth}"]
            }
            
        }
    }
}


objectdef bwlVerticalLayout
{   
    member ToText()
    {
        return "Vertical"   
    }

    method ApplyWindowLayout(bool setOtherSlots=TRUE)
    {
        variable jsonvalueref Slots="JMB.Slots"

        variable uint monitorWidth=${Display.Monitor.Width}
        variable uint monitorHeight=${Display.Monitor.Height}
        variable int monitorX=${Display.Monitor.Left}
        variable int monitorY=${Display.Monitor.Top}

        variable uint mainHeight
        variable uint numSmallRegions=${Slots.Used}
        variable uint mainWidth
        variable uint smallHeight
        variable uint smallWidth

        if ${BWLSettings.AvoidTaskbar}
        {
            monitorX:Set["${Display.Monitor.MaximizeLeft}"]
            monitorY:Set["${Display.Monitor.MaximizeTop}"]
            monitorWidth:Set["${Display.Monitor.MaximizeWidth}"]
            monitorHeight:Set["${Display.Monitor.MaximizeHeight}"]
        }


        ; if there's only 1 window, just go full screen windowed
        if ${numSmallRegions}==1
        {
            WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${monitorWidth}x${monitorHeight} -frame none
            BWLSession.Applied:Set[1]
            return
        }

        if !${BWLSettings.LeaveHole}
            numSmallRegions:Dec

        ; 2 windows is actually a 50/50 split screen and should probably handle differently..., pretend there's 3
        if ${numSmallRegions}<3
            numSmallRegions:Set[3]

        mainHeight:Set["${monitorHeight}"]
        mainWidth:Set["${monitorWidth}*${numSmallRegions}/(${numSmallRegions}+1)"]

        smallWidth:Set["${monitorWidth}-${mainWidth}"]
        smallHeight:Set["${monitorHeight}/${numSmallRegions}"]

        WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${mainWidth}x${mainHeight} -frame none
        BWLSession.Applied:Set[1]

        if !${setOtherSlots}
            return

        variable int useY
        variable uint numSlot

        variable uint slotID

        for (numSlot:Set[1] ; ${numSlot}<=${Slots.Used} ; numSlot:Inc)
        {
            slotID:Set["${Slots[${numSlot}].Get[id]~}"]
            if ${slotID}!=${JMB.Slot}
            {
                relay jmb${slotID} "WindowCharacteristics ${BWLSettings.StealthFlag}-pos -viewable ${mainWidth},${useY} -size -viewable ${smallWidth}x${smallHeight} -frame none"
                useY:Inc["${smallHeight}"]
            }
            else
            {
                if ${BWLSettings.LeaveHole}
                    useY:Inc["${smallHeight}"]
            }
            
        }
    }
}

objectdef bwlCustomWindowLayout
{
    member ToText()
    {
        return "Custom"   
    }

    method ApplyWindowLayout(bool setOtherSlots=TRUE)
    {
         variable jsonvalueref Slots="JMB.Slots"

        variable uint numSmallRegions=${Slots.Used}

        variable uint mainHeight=${BWLSettings.CustomLayout.Get[mainRegion,height]}
        variable uint mainWidth=${BWLSettings.CustomLayout.Get[mainRegion,width]}
        variable int mainX=${BWLSettings.CustomLayout.Get[mainRegion,x]}
        variable int mainY=${BWLSettings.CustomLayout.Get[mainRegion,y]}


        WindowCharacteristics -pos -viewable ${mainX},${mainY} -size -viewable ${mainWidth}x${mainHeight} -frame none
        BWLSession.Applied:Set[1]

        if !${BWLSettings.LeaveHole}
            numSmallRegions:Dec

        if !${setOtherSlots} || !${numSmallRegions}
            return

        variable uint numSlot
        variable uint numSmallRegion=1

        variable uint slotID

        variable int smallX
        variable int smallY
        variable uint smallWidth
        variable uint smallHeight

        for (numSlot:Set[1] ; ${numSlot}<=${Slots.Used} ; numSlot:Inc)
        {
            slotID:Set["${Slots[${numSlot}].Get[id]~}"]
            if ${slotID}!=${JMB.Slot}
            {
                smallX:Set["${BWLSettings.CustomLayout.Get[regions,${numSmallRegion},x]~}"]
                smallY:Set["${BWLSettings.CustomLayout.Get[regions,${numSmallRegion},y]~}"]
                smallWidth:Set["${BWLSettings.CustomLayout.Get[regions,${numSmallRegion},width]~}"]
                smallHeight:Set["${BWLSettings.CustomLayout.Get[regions,${numSmallRegion},height]~}"]

                if ${smallWidth} && ${smallHeight}
                {
                    if ${smallWidth}==${mainWidth} && ${smallHeight}==${mainHeight}
                        relay jmb${slotID} "WindowCharacteristics -pos -viewable ${smallX},${smallY} -size -viewable ${smallWidth}x${smallHeight} -frame none"
                    else
                        relay jmb${slotID} "WindowCharacteristics ${BWLSettings.StealthFlag}-pos -viewable ${smallX},${smallY} -size -viewable ${smallWidth}x${smallHeight} -frame none"
                }

                numSmallRegion:Inc
            }
            else
            {
                if ${BWLSettings.LeaveHole}
                   numSmallRegion:Inc
            }
            
        }
        
    }   
}