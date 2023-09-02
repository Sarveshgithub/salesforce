trigger ContactTrigger on Contact(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            ContactTriggerHandler.handleBeforeInsert(Trigger.new, Trigger.newMap, null);
        } else if (Trigger.isUpdate) {
            ContactTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            ContactTriggerHandler.handleBeforeDelete(Trigger.oldMap, null);
        }
        // Add conditions for other "before" events as needed
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ContactTriggerHandler.handleAfterInsert(Trigger.new, Trigger.newMap, null);
        } else if (Trigger.isUpdate) {
            ContactTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            ContactTriggerHandler.handleAfterDelete(Trigger.oldMap, null);
        } else if (Trigger.isUndelete) {
            ContactTriggerHandler.handleAfterUndelete(Trigger.new, Trigger.newMap, null);
        }
        // Add conditions for other "after" events as needed
    }
}