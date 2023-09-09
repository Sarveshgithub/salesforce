public class OpportunityTriggerHandler {
    public static void handleBeforeInsert(List<Opportunity> newList) { 
        // Add your before insert logic here
        Set<Id> accIds = new Set<Id>();
            for(Opportunity objOpp : newList){
                accIds.add(objOpp.AccountId);  
            }
        Map<Id,Account> mapOfAccount = new Map<Id,Account>([SELECT id,Name from Account where Id = : accIds]);
        for(Opportunity objOpp : newList){
            String accountName = mapOfAccount.get(objOpp.AccountId).Name;
            objOpp.Name = objOpp.Name +' | ' + accountName;
        }
    }

    public static void handleBeforeUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
        // Add your before update logic here
    }

    public static void handleBeforeDelete(List<Opportunity> oldList) {
        // Add your before delete logic here
    } 
    public static void handleAfterInsert(List<Opportunity> newList) {
        // Add your after insert logic here
    }

    public static void handleAfterUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
        // Add your after update logic here
    }

    public static void handleAfterDelete(List<Opportunity> oldList) {
        // Add your after delete logic here
    }

    public static void handleAfterUndelete(List<Opportunity> newList) {
        // Add your after undelete logic here
    }

}