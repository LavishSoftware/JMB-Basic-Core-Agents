    ; This layout puts all small windows on the bottom of the screen.  The height of the windows is 1/N where N is the number of small windows.  The width is the monitor width / n

objectdef layoutBottom inherits layoutType
{
    variable string name
    variable uint mainHeight
    variable uint mainWidth
    variable uint smallHeight
    variable uint smallWidth
    variable uint numSmallRegions
    
    method getWindowCharacteristics(uint slotID, uint mainSlotID, bool avoidTaskbar, bool leaveHole) 
    {
        variable uint monitorWidth=${Display.Monitor.Width}
        variable uint monitorHeight=${Display.Monitor.Height}
        variable int monitorX=${Display.Monitor.Left}
        variable int monitorY=${Display.Monitor.Top}
        
        if ${avoidTaskbar}
        {
            monitorX:Set["${Display.Monitor.MaximizeLeft}"]
            monitorY:Set["${Display.Monitor.MaximizeTop}"]
            monitorWidth:Set["${Display.Monitor.MaximizeWidth}"]
            monitorHeight:Set["${Display.Monitor.MaximizeHeight}"]
        }

        if ${numSmallRegions}==1
        {
            return "WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${monitorWidth}x${monitorHeight} -frame none"
        }

        if !${leaveHole}
            numSmallRegions:Dec
; Can we move this to a separate function and script variables versus calculating each time?

        mainWidth:Set["${monitorWidth}*${numSmallRegions}/(${numSmallRegions}+1)"]
        mainHeight:Set["${monitorHeight}"]

        smallHeight:Set["${monitorHeight}-${mainHeight}"]
        smallWidth:Set["${monitorWidth}/${numSmallRegions}"]

        if ${slotID}==${mainSlotID}
        {
            monitorX:Set["${monitorX}+${smallWidth}"]
            return "WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${mainWidth}x${mainHeight} -frame none"
        }

        variable int posX=${monitorX}
        variable int posY

        if ${leaveHole}
        {
            posY:Set["(${slotID"}-1)*${smallHeight}"]
        }

        else
        {
            if ${slotID}<${mainSlotID}
            {
               posY:Set["(${slotID"}-1)*${smallHeight}"] 
            }
            else
            {
                posY:Set["(${slotID"}-2)*${smallHeight}"] 
            }
        }
        ; Return a windows charateristic string.  Default to full screen if not implemented in child object
        return "WindowCharacteristics -stealth -pos -viewable ${posX},${posY} -size -viewable ${smallWidth}x${smallHeight} -frame none"
    }    

}