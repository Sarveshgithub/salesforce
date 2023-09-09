trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OpportunityTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            OpportunityTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.old);
        } else if (Trigger.isDelete) {
            OpportunityTriggerHandler.handleBeforeDelete(Trigger.old);
        }
        // Add conditions for other "before" events as needed
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OpportunityTriggerHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            OpportunityTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.old);
        } else if (Trigger.isDelete) {
            OpportunityTriggerHandler.handleAfterDelete(Trigger.old);
        } else if (Trigger.isUndelete) {
            OpportunityTriggerHandler.handleAfterUndelete(Trigger.new);
        }
        // Add conditions for other "after" events as needed
    }
}