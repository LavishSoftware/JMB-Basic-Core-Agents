#include "Layouts/Layout.Bottom.iss"
#include "Layouts/Layout.Top.iss"
#include "Layouts/Layout.Left.iss"
#include "Layouts/Layout.Right.iss"

; Defines the layout type object to be used by layout models.

objectdef layoutType
{
    variable string name
    variable uint mainHeight
    variable uint mainWidth
    variable uint smallHeight
    variable uint smallWidth
    variable uint numSmallRegions
    method getWindowCharacteristics(uint SlotID, bool isMain, bool avoidTaskbar, bool leaveHole) 
    {
        ; Return a windows charateristic string.  Default to full screen if not implemented in child object
        return "WindowCharacteristics -pos -viewable ${monitorX},${monitorY} -size -viewable ${monitorWidth}x${monitorHeight} -frame none"
    }
    
    
    member AsJSON()
    {
        variable jsonvalue jo
        jo:SetValue["$$>
        {
            "mame":${name.AsJSON~},
            "mainHeight":${mainHeight.AsJSON~},
            "mainWidth":${mainWidth.AsJSON~},
            "smallHeight":${smallHeight.AsJSON~},
            "smallWidth":${smallWidth.AsJSON~},
            "numSmallRegions":${numSmallRegions.AsJSON~}
        }
        <$$"]
        return "${jo.AsJSON~}" 
    }

}

objectdef bwlViews
{
    variable jsonvalueref Slots="JMB.Slots"
    variable filepath LayoutFolder="${Script.CurrentDirectory}/Layouts"

    variable uint monitorWidth=${Display.Monitor.Width}
    variable uint monitorHeight=${Display.Monitor.Height}
    variable int monitorX=${Display.Monitor.Left}
    variable int monitorY=${Display.Monitor.Top}

    variable uint mainHeight
    variable uint mainWidth
    variable uint smallHeight
    variable uint smallWidth
    variable uint numSmallRegions


}