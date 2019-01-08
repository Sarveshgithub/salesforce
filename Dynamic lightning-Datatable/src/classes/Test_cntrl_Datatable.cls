@isTest
private class Test_cntrl_Datatable 
{
    @isTest 
    static void test_dynQry() 
    {
        list<RecordType> recType = [SELECT Id,name, DeveloperName 
                                    FROM RecordType 
                                    WHERE SObjectType = 'Account'];
        Account acc = new Account(Name = 'TestAcc');
        if(!recType.isEmpty()){
            acc.put('recordTypeId', recType[0].Id);
        }
        insert acc;
        list<RecordType> recTypeCon = [SELECT Id,name, DeveloperName 
                                       FROM RecordType 
                                       WHERE SObjectType = 'Contact'];
        Contact con = new Contact(LastName = 'TestCon',
                                  AccountId = acc.Id);
        if(!recTypeCon.isEmpty()){
            con.put('recordTypeId', recTypeCon[0].Id);
        }
        insert con;
        
        
        Test.startTest();
        cntrl_Datatable.loadData('Contact',
                                 'Id,name,lastname,firstname,ownerid,createddate,Accountid,Phone,LeadSource,Account.Name,Account.phone,Account.parent.name',
                                 '',
                                 false,
                                 '',
                                 '');
        cntrl_Datatable.deleteRecord(con.Id);
        
        Test.stopTest();
    }
}