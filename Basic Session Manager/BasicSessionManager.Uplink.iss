objectdef basicsessionmanager
{
    ; snapshots of current state
    variable jsonvalueref JMBSessions
    variable jsonvalueref JMBSlots

    ; current selection in list boxes
    variable string UseSession
    variable uint UseSlot

    ; object constructor
    method Initialize()
    {
        ; features used by this Agent are specifcially ready in build 6841. If not on 6841 or later, don't do anything
        if ${JMB.Build}<6841
        {
            echo "Basic Session Manager requires JMB build 6841 or later"
            return
        }

        ; good practice in LavishScript is to register an event before attaching
        ; JMB_OnSlotsUpdated and OnSessionsUpdated events are provided by JMB
        LavishScript:RegisterEvent[JMB_OnSlotsUpdated]
        LavishScript:RegisterEvent[OnSessionsUpdated]

        ; attach an atom (a method in our object) to the LavishScript events we want to listen to
        Event[JMB_OnSlotsUpdated]:AttachAtom[This:OnSlotsUpdated]
        Event[OnSessionsUpdated]:AttachAtom[This:OnSessionsUpdated]

        ; load our GUI
        LGUI2:LoadPackageFile[BasicSessionManager.Uplink.lgui2Package.json]

        ; grab snapshots and notify the GUI of the data
        This:OnSessionsUpdated

        ; add a button to JMB's quickbar (usually at the top of the JMB Uplink window)
        This:EnableQuickbarButton
    }

    ; object destructor
    method Shutdown()
    {
        ; remove the button from JMB's quickbar
        This:DisableQuickbarButton

        ; unload our GUI
        LGUI2:UnloadPackageFile[BasicSessionManager.Uplink.lgui2Package.json]
    }

    ; add a button to JMB's quickbar (usually at the top of the JMB Uplink window)
    method EnableQuickbarButton()
    {
        ; if our button is already there, let's not make it again!
        if ${LGUI2.Element[bsm.quickbarButton](exists)}
            return

        ; retrieve the 'bsm.quickbarButton' LGUI2 template, as defined in our LGUI2 Package file
		variable jsonvalue joQuickbarButton
		joQuickbarButton:SetValue["${LGUI2.Template["bsm.quickbarButton"].AsJSON~}"]
        
        ; now just add our button to "jmb.quickBar"!
        LGUI2.Element[jmb.quickBar]:AddChild["${joQuickbarButton.AsJSON~}"]
    }

    ; remove the button from JMB's quickbar
    method DisableQuickbarButton()
    {
        ; just destroy our button
        LGUI2.Element[bsm.quickbarButton]:Destroy
    }

    ; used by GUI to generate a listbox view of a Slot. Here we use our own LGUI2 template.
    method GenerateItemView_Slot()
	{
  ;      echo GenerateItemView_Slot ${Context(type)} ${Context.Args}

        ; retrieve the 'bsm.slotView' LGUI2 template, as defined in our LGUI2 Package file
		variable jsonvalue joListBoxItem
		joListBoxItem:SetValue["${LGUI2.Template["bsm.slotView"].AsJSON~}"]
        		
        ; because our template is a complete listbox item definition, we can use Context:SetView as part of the "item view generator" mechanism to fill in the GUI
		Context:SetView["${joListBoxItem.AsJSON~}"]
	}

    ; used by GUI to generate a listbox view of a Session. Here we use our own LGUI2 template.
    method GenerateItemView_Session()
	{
  ;      echo GenerateItemView_Session ${Context(type)} ${Context.Args}

        ; retrieve the 'bsm.sessionView' LGUI2 template, as defined in our LGUI2 Package file
		variable jsonvalue joListBoxItem
		joListBoxItem:SetValue["${LGUI2.Template["bsm.sessionView"].AsJSON~}"]
        		
        ; because our template is a complete listbox item definition, we can use Context:SetView as part of the "item view generator" mechanism to fill in the GUI
		Context:SetView["${joListBoxItem.AsJSON~}"]
	}

    ; performed when JMB reports that its Sessions list has been updated
    method OnSessionsUpdated()
    {
        ; grab a new snapshot of ${JMBUplink.Sessions}
        JMBSessions:SetReference[JMBUplink.Sessions]

        ; notify our GUI that our snapshot is updated
        LGUI2.Element[bsm.events]:FireEventHandler[onSessionsUpdated]

        ; also force a Slots update
        This:OnSlotsUpdated
 ;       echo "OnSessionsUpdated ${JMBSessions~}"
    }

    ; performed when JMB reports that its Slots list has been updated
    method OnSlotsUpdated()
    {
        ; grab a new snapshot of ${JMB.Slots}
        JMBSlots:SetReference[JMB.Slots]

        ; notify our GUI that our snapshot is updated
        LGUI2.Element[bsm.events]:FireEventHandler[onSlotsUpdated]
 ;       echo "OnSlotsUpdated ${JMBSlots~}"
    }

    ; used by the GUI to set the currently selected Slot
    method SetSlot(uint newValue)
    {
        ; quick check for out of range, in which case we select no Slot
        if ${newValue} > ${JMBSlots.Used}
            newValue:Set[0]

        UseSlot:Set[${newValue}]
    }

    ; used by the GUI to set the currently selected Session (by name)
    method SetSession(string newValue)
    {
        UseSession:Set[${newValue~}]
    }

    ; kill the currently selected Session
    method OnTerminateSession()
    {
        Session["${UseSession~}"]:Kill
    }

    ; kill the currently selected Slot
    method OnTerminateSlot()
    {
        JMBUplink.Session[-pid,${JMB.Slot[${UseSlot}].ProcessID}]:Kill
    }

    ; request that the currently selected Slot close (may or may not work)
    method OnCloseSlot()
    {
        JMB.Slot[${UseSlot}]:Close
    }

    ; Add an empty Slot
    method OnAddSlot()
    {
        JMB:AddSlot
    }

    ; remove the currently selected Slot
    method OnRemoveSlot()
    {
        JMB.Slot[${UseSlot}]:Remove
    }

    ; re-launch the currently selected Slot, if it is not currently running
    method OnRelaunchSlot()
    {
        if ${JMB.Slot[${UseSlot}].ProcessID}
        {
            echo "Slot ${UseSlot} already running"
            return
        }
        JMB.Slot[${UseSlot}]:Launch
    }

    ; clear all Slots
    method OnResetSlots()
    {
        JMB:ClearSlots
    }
}

; our globally accessible BasicSessionManager object instance
variable(global) basicsessionmanager BasicSessionManager

; this is the entry point for the script. We handle everything in our object, so its purpose is just to keep the script "running" and the object alive
function main()
{
    ; a simple loop which does nothing, for each rendered frame
    while 1
        waitframe
}
