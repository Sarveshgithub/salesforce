public class SessionTimer {
    
    @AuraEnabled
    public static List<Sobject> fetchSessionOwner(Id recId){
        String sObjName = recId.getSObjectType().getDescribe().getName();
        String soql = 'SELECT ownerid FROM '+sObjName+' Where Id=\'' + recId + '\'';
        List<Sobject> lstresult = Database.query(soql); 
        return lstresult;
    }
    
    @AuraEnabled
    public static List<Sobject> fetchSession(String recId, String CurrLookup){
        String soql;
        soql = 'SELECT Session_Owner__r.Name,Date__c,Time__c FROM Case_session__c Where '+CurrLookup+'=\'' + recId + '\' ORDER By CreatedDate DESC LIMIT 7';
        List<Sobject> lstresult = Database.query(soql);
        return lstresult;
    }
    @AuraEnabled
    public static Boolean createSession(String jsonstr){
        Case_session__c caseSession = (Case_session__c) JSON.deserialize(jsonstr, Case_session__c.class);
        try {
            insert caseSession;
            return true;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Sobject> totalTime(String recId, String CurrLookup){
        String soql;
        soql = 'SELECT Time__c FROM Case_session__c Where '+CurrLookup+'=\'' + recId + '\'';
        List<Sobject> lstresult = Database.query(soql);
        return lstresult;
    }
}