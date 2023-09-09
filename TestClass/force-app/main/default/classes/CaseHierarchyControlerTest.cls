/**
 * Class Name : CaseHierarchyControlerTest
 * About : Test class for CaseHierarchyControler
 */
@isTest
public class CaseHierarchyControlerTest {
  @TestSetup
  static void makeData() {
    List<Case> lstCase = new List<Case>{
      new case(Status = 'New', Origin = 'Email', Subject = 'Case1'),
      new case(Status = 'New', Origin = 'Email', Subject = 'Case2'),
      new case(Status = 'New', Origin = 'Email', Subject = 'Case3')
    };
    insert lstCase;
    lstCase[1].ParentId = lstCase[0].Id;
    lstCase[2].ParentId = lstCase[1].Id;
    update lstCase;
  }
  
  /**
   * Method Name : test_getCaseChildRecords()
   * About : verify getCaseChildRecords()
   */
  @IsTest
  static void test_getCaseChildRecords() {
    User contextuser = new user(ID = UserInfo.getUserID());
    List<Case> lstCase = [SELECT Id FROM Case WHERE Subject = 'Case1' LIMIT 1];
    Test.startTest();
    System.runAs(contextuser) {
      CaseHierarchyControler.getCaseChildRecords(lstCase[0].Id);
    }
    Test.stopTest();
  }
}