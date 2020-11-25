#include "BasicWindowLayout.Common.iss"

objectdef bwlSession
{
    variable bwlSettings Settings

    variable bool Applied

    method Initialize()
    {
        LavishScript:RegisterEvent[On Activate]
        LavishScript:RegisterEvent[OnWindowStateChanging]
		LavishScript:RegisterEvent[OnMouseEnter]
		LavishScript:RegisterEvent[OnMouseExit]

        Event[On Activate]:AttachAtom[This:OnActivate]
        Event[OnWindowStateChanging]:AttachAtom[This:OnWindowStateChanging]
		Event[OnMouseEnter]:AttachAtom[This:OnMouseEnter]
		Event[OnMouseExit]:AttachAtom[This:OnMouseExit]

        FocusClick eat
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

        if ${Settings.AvoidTaskbar}
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
            This.Applied:Set[1]
            return
        }

        if !${Settings.LeaveHole}
            numSmallRegions:Dec

        ; 2 windows is actually a 50/50 split screen and should probably handle differently..., pretend there's 3
        if ${numSmallRegions}==2
            numSmallRegions:Set[3]

        mainWidth:Set["${monitorWidth}"]
        mainHeight:Set["${monitorHeight}*${numSmallRegions}/(${numSmallRegions}+1)"]

        smallHeight:Set["${monitorHeight}-${mainHeight}"]
        smallWidth:Set["${monitorWidth}/${numSmallRegions}"]

        WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${mainWidth}x${mainHeight} -frame none
        This.Applied:Set[1]

        if !${setOtherSlots}
            return

        variable uint numSmallRegion
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
                if ${Settings.LeaveHole}
                    useX:Inc["${smallWidth}"]
            }
            
        }
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

    method OnWindowStateChanging(string change)
    {
      ;  echo OnWindowStateChanging ${change~}
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