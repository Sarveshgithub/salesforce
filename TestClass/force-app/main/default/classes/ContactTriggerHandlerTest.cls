/**
 * Usecase
 * - Contact LastName should be LastName + ' | ' + Account Name
 */

@isTest
public with sharing class ContactTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        Account objAcc = new Account(Name = 'Test Account');
        insert objAcc;
        Contact objCon = new Contact(
            LastName = 'Test Contact',
            AccountId = objAcc.ID
        );
        insert objCon;
    }

    @IsTest
    static void verifyContactLastName() {
        Contact objCon = [
            SELECT Id, Lastname
            FROM contact
            WHERE Account.Name = 'Test Account'
        ];
        System.assertEquals('Test Contact | Test Account', objCon.LastName);
    }
}
