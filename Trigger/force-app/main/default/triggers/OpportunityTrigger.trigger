trigger OpportunityTrigger on Opportunity (before insert,before update, before delete, after insert, after update, after delete, after undelete) {
    If(Trigger.isBefore){
        If(Trigger.isInsert){
            OpportunityTriggerHandler.beforeInsert();
        }
        If(Trigger.isUpdate){
            OpportunityTriggerHandler.beforeUpdate();
        }
        If(Trigger.isDelete){
            OpportunityTriggerHandler.beforeDelete();
        } 
    }else If(Trigger.isAfter){ 
        If(Trigger.isInsert){
            OpportunityTriggerHandler.afterInsert();
        }
        If(Trigger.isUpdate){
            OpportunityTriggerHandler.afterUpdate();  
        }
        If(Trigger.isDelete){
            OpportunityTriggerHandler.afterDelete();
        }
    }

    OpportunityTriggerHandler.afterInsert();
    
   
    
  
    OpportunityTriggerHandler.afterUnDelete();
}