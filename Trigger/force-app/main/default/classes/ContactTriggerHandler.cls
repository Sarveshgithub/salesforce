public class ContactTriggerHandler {
    public static void handleBeforeInsert(List<Contact> newList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        // Add your before insert logic here
        updateContactName(newList);
    }

    public static void handleBeforeUpdate(List<Contact> newList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        List<Contact> lstCon = new List<Contact>();
        for (Contact objCon : newMap.values()) {
            if (objCon.LastName != oldMap.get(objCon.Id).LastName) {
                lstCon.add(objCon);
            }
        }
        updateContactName(lstCon);
    }

    public static void handleBeforeDelete(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        deleteCase(oldMap.keySet());
    }

    public static void handleAfterInsert(List<Contact> newList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        // Add your after insert logic here
    }

    public static void handleAfterUpdate(List<Contact> newList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        List<Contact> lstCon = new List<Contact>();
        for (Contact objCon : newMap.values()) {
            if (objCon.Department != oldMap.get(objCon.Id).Department && objCon.Department == 'tech') {
                lstCon.add(objCon);
            }
        }
        createCase(lstCon);
    }

    public static void handleAfterDelete(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        // Add your after delete logic here
    }

    public static void handleAfterUndelete(List<Contact> newList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        // Add your after undelete logic here
    }

    private static void updateContactName(List<Contact> lstContact) {
        Set<Id> setOfId = new Set<Id>();
        for (Contact objCon : lstContact) {
            setOfId.add(objCon.AccountId);
        }
        Map<Id, Account> mapOfAccount = new Map<Id, Account>([SELECT id, name FROM account WHERE id IN :setOfId]);

        for (Contact objCon : lstContact) {
            String accountName = mapOfAccount.get(objCon.AccountId).Name;
            objCon.LastName = objCon.LastName + ' | ' + accountName;
        }
    }

    private static void createCase(List<Contact> lstContact) {
        List<Case> lstCase = new List<Case>();
        for (Contact objCon : lstContact) {
            lstCase.add(new Case(Subject = 'Tech Case', Description = 'tech contact updated', contactid = objCon.Id));
        }
        if (lstCase.size() > 0) {
            insert lstCase;
        }
    }

    private static void deleteCase(Set<Id> setOfConId) {
        delete [SELECT id FROM case WHERE contactid IN :setOfConId];
    }
}