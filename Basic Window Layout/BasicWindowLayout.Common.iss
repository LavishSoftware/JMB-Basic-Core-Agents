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

        if ${jo.Has[useLayout]}
            UseLayout:Set["${jo.Get[useLayout]~}"]

        if ${jo.Has[customLayout]}
            CustomLayout:SetValue["${jo.Get[customLayout].AsJSON~}"]

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
            "hotkeys":{
                "toggleSwapOnActivate":${hotkeyToggleSwapOnActivate.AsJSON~},
                "toggleFocusFollowsMouse":${hotkeyToggleFocusFollowsMouse.AsJSON~},
                "fullscreen":${hotkeyFullscreen.AsJSON~},
                "applyWindowLayout":${hotkeyApplyWindowLayout.AsJSON~},
                "nextWindow":${hotkeyNextWindow.AsJSON~},
                "previousWindow":${hotkeyPreviousWindow.AsJSON~}
            },
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
    variable uint TwoMonitorColumns=2

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

        if ${BWLSession.Settings.AvoidTaskbar}
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

        if !${BWLSession.Settings.LeaveHole}
            numSmallRegions:Dec

        ; 2 windows is actually a 50/50 split screen and should probably handle differently..., pretend there's 3
        if ${numSmallRegions}==2
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
                relay jmb${slotID} "WindowCharacteristics -stealth -pos -viewable ${useX},${mainHeight} -size -viewable ${smallWidth}x${smallHeight} -frame none"
                useX:Inc["${smallWidth}"]
            }
            else
            {
                if ${BWLSession.Settings.LeaveHole}
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

        if ${BWLSession.Settings.AvoidTaskbar}
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

        if !${BWLSession.Settings.LeaveHole}
            numSmallRegions:Dec

        ; 2 windows is actually a 50/50 split screen and should probably handle differently..., pretend there's 3
        if ${numSmallRegions}==2
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
                relay jmb${slotID} "WindowCharacteristics -stealth -pos -viewable ${mainWidth},${useY} -size -viewable ${smallWidth}x${smallHeight} -frame none"
                useY:Inc["${smallHeight}"]
            }
            else
            {
                if ${BWLSession.Settings.LeaveHole}
                    useY:Inc["${smallHeight}"]
            }
            
        }
    }
}

objectdef bwlTwoMonitorLayout
{   
    member ToText()
    {
        return "TwoMonitor"   
    }

    method ApplyWindowLayout(bool setOtherSlots=TRUE)
    {
        variable jsonvalueref Slots="JMB.Slots"

        variable uint monitorOneWidth=${Display.Monitor[1].Width}
        variable uint monitorOneHeight=${Display.Monitor[1].Height}
        variable int monitorOneX=${Display.Monitor[1].Left}
        variable int monitorOneY=${Display.Monitor[1].Top}
        
        variable uint monitorTwoWidth=${Display.Monitor[2].Width}
        variable uint monitorTwoHeight=${Display.Monitor[2].Height}
        variable int monitorTwoX=${Display.Monitor[2].Left}
        variable int monitorTwoY=${Display.Monitor[2].Top}

        variable uint mainHeight
        variable uint numSmallRegions=${Slots.Used}
        variable uint mainWidth
        variable uint smallHeight
        variable uint smallWidth
        variable uint smallColumns=2
        variable uint smallRows

        ; If there is only 1 column, everything will be stacked.  Make at least 2 columns.
        if ${BWLSession.Settings.TwoMonitorColumns}>1
            smallColumns:Set["${BWLSession.Settings.TwoMonitorColumns}"]

        if ${BWLSession.Settings.AvoidTaskbar}
        {
            monitorOneX:Set["${Display.Monitor[1].MaximizeLeft}"]
            monitorOneY:Set["${Display.Monitor[1].MaximizeTop}"]
            monitorOneWidth:Set["${Display.Monitor[1].MaximizeWidth}"]
            monitorOneHeight:Set["${Display.Monitor[1].MaximizeHeight}"]

            monitorTwoX:Set["${Display.Monitor[2].MaximizeLeft}"]
            monitorTwoY:Set["${Display.Monitor[2].MaximizeTop}"]
            monitorTwoWidth:Set["${Display.Monitor[2].MaximizeWidth}"]
            monitorTwoHeight:Set["${Display.Monitor[2].MaximizeHeight}"]
        }

        ; If there's only 1 window, just go full screen windowed on Monitor One
        if ${numSmallRegions}==1
        {
            WindowCharacteristics -pos -viewable ${monitorOneX},${monitorOneY} -size -viewable ${monitorOneWidth}x${monitorOneHeight} -frame none
            BWLSession.Applied:Set[1]
            return
        }

        ; If there's only 2 windows, go full screen on each Monitor
        if ${numSmallRegions}==2
        {
            WindowCharacteristics -pos -viewable ${monitorOneX},${monitorOneY} -size -viewable ${monitorOneWidth}x${monitorOneHeight} -frame none
            relay jmb2 "WindowCharacteristics -stealth -pos -viewable ${monitorTwoX},${monitorTwoY} -size -viewable ${monitorTwoWidth}x${monitorTwoHeight} -frame none"
            BWLSession.Applied:Set[1]
            return
        }

        if !${BWLSession.Settings.LeaveHole}
            numSmallRegions:Dec

        mainHeight:Set["${monitorOneHeight}"]
        mainWidth:Set["${monitorOneWidth}"]

        if ${numSmallRegions}%${smallColumns}==0
        {
            smallRows:Set["${numSmallRegions}/${smallColumns}"]
        }
        else
        {
            ; Move the numerator up to the next value that divides evenly by small columns
            smallRows:Set["(${numSmallRegions}+(${smallColumns}-(${numSmallRegions}%${smallColumns})))/${smallColumns}"]
        }
        
        ; If there is only 1 row, everything will be stretched side by side.  Make at least 2 rows.
        if ${smallRows}==1
            smallRows:Set["2"]

        smallWidth:Set["${monitorTwoWidth}/${smallColumns}"]
        smallHeight:Set["${monitorTwoHeight}/${smallRows}"]

        WindowCharacteristics -pos -viewable ${monitorOneX},${monitorOneY} -size -viewable ${mainWidth}x${mainHeight} -frame none
        BWLSession.Applied:Set[1]

        if !${setOtherSlots}
            return

        variable int useX
        variable int useY
        variable int useRow
        variable int useColumn
        variable uint numSlot
        variable uint slotID
        variable uint posID

        for (numSlot:Set[1] ; ${numSlot}<=${Slots.Used} ; numSlot:Inc)
        {
            slotID:Set["${Slots[${numSlot}].Get[id]~}"]
            posID:Set["${slotID}"]

            if ${slotID}!=${JMB.Slot}
            {
                if !${BWLSession.Settings.LeaveHole}  && ${slotID}>${JMB.Slot}
                    posID:Set["${posID}-1"]

                ;Leveraging INT typecasting to find Row/Column.  Quotient is used for Row, Modulo is used for Column
                useRow:Set["(${posID}-1)/${smallColumns}"]
                useColumn:Set["(${posID}-1)%${smallColumns}"]

                useX:Set["${monitorTwoX}+(${smallWidth}*${useColumn})"]
                useY:Set["${monitorTwoY}+(${smallHeight}*${useRow})"]

                relay jmb${slotID} "WindowCharacteristics -stealth -pos -viewable ${useX},${useY} -size -viewable ${smallWidth}x${smallHeight} -frame none"
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

        variable uint mainHeight=${BWLSession.Settings.CustomLayout.Get[mainRegion,height]}
        variable uint mainWidth=${BWLSession.Settings.CustomLayout.Get[mainRegion,width]}
        variable int mainX=${BWLSession.Settings.CustomLayout.Get[mainRegion,x]}
        variable int mainY=${BWLSession.Settings.CustomLayout.Get[mainRegion,y]}


        WindowCharacteristics -pos -viewable ${mainX},${mainY} -size -viewable ${mainWidth}x${mainHeight} -frame none
        BWLSession.Applied:Set[1]

        if !${BWLSession.Settings.LeaveHole}
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
                smallX:Set["${BWLSession.Settings.CustomLayout.Get[regions,${numSmallRegion},x]~}"]
                smallY:Set["${BWLSession.Settings.CustomLayout.Get[regions,${numSmallRegion},y]~}"]
                smallWidth:Set["${BWLSession.Settings.CustomLayout.Get[regions,${numSmallRegion},width]~}"]
                smallHeight:Set["${BWLSession.Settings.CustomLayout.Get[regions,${numSmallRegion},height]~}"]

                if ${smallWidth} && ${smallHeight}
                {
                    if ${smallWidth}==${mainWidth} && ${smallHeight}==${mainHeight}
                        relay jmb${slotID} "WindowCharacteristics -pos -viewable ${smallX},${smallY} -size -viewable ${smallWidth}x${smallHeight} -frame none"
                    else
                        relay jmb${slotID} "WindowCharacteristics -stealth -pos -viewable ${smallX},${smallY} -size -viewable ${smallWidth}x${smallHeight} -frame none"
                }

                numSmallRegion:Inc
            }
            else
            {
                if ${BWLSession.Settings.LeaveHole}
                   numSmallRegion:Inc
            }
            
        }
        
    }   
}