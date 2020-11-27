    ; This layout puts all small windows on the bottom of the screen.  The height of the windows is 1/N where N is the number of small windows.  The width is the monitor width / n

objectdef layoutBottom inherits layoutType
{
    variable string name
    variable uint monitorWidth=${Display.Monitor.Width}
    variable uint monitorHeight=${Display.Monitor.Height}
    variable int monitorX=${Display.Monitor.Left}
    variable int monitorY=${Display.Monitor.Top}
    variable uint mainHeight
    variable uint mainWidth
    variable uint smallHeight
    variable uint smallWidth
    variable uint numSmallRegions

    member:string getWindowCharacteristics(uint slotID, uint mainSlotID, bool avoidTaskbar, bool leaveHole) 
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
        
        if ${slotID}==${mainSlotID}
        {
            mainWidth:Set["${monitorWidth}"]
            mainHeight:Set["${monitorHeight}*${numSmallRegions}/(${numSmallRegions}+1)"]

            smallHeight:Set["${monitorHeight}-${mainHeight}"]
            smallWidth:Set["${monitorWidth}/${numSmallRegions}"]

            return "WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${mainWidth}x${mainHeight} -frame none"
        }

        variable int posX
        variable int posY=${mainHeight}
        if ${leaveHole}
        {
            posX:Set["(${slotID"}-1)*${smallWidth}"]
        }
        else
        {
            if ${slotID}<${mainSlotID}
            {
               posX:Set["(${slotID"}-1)*${smallWidth}"] 
            }
            else
            {
                posX:Set["(${slotID"}-2)*${smallWidth}"] 
            }
        }
        ; Return a windows charateristic string.  Default to full screen if not implemented in child object
        return "WindowCharacteristics -stealth -pos -viewable ${posX},${posY} -size -viewable ${smallWidth}x${smallHeight} -frame none"
    }    

}