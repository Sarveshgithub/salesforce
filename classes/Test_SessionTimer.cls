@isTest
public class Test_SessionTimer {
    @isTest 
    static void test() {
        Contact con = new Contact(LastName = 'TestName');
        insert con;
        List<sobject> lst = SessionTimer.fetchSessionOwner(con.Id);
        System.assertEquals(true, lst.size() > 0);
        Case objNew = new Case(Status = 'New', Origin = 'Email' ,OwnerId = Userinfo.getUserId());
        insert objNew;
        Case_Session__c objcs = new Case_Session__c(Case__c = objNew.id, Time__c = '00:08:89',Date__c = Date.today());
        insert objcs;
        List<sobject> lstcs = SessionTimer.fetchSession(objcs.Id,'Case__c');
        
        SessionTimer.createSession(Json.serialize(new Case_Session__c(Case__c = objNew.id, Time__c = '00:08:89',Date__c = Date.today())));
        SessionTimer.totalTime(objcs.id, 'Case__c');
        //SessionTimer.createSession(Json.serialize(new Case_Session__c(Case__c = objcs.id, Time__c = '00:08:89',Date__c = Date.today())));
    }
    
}