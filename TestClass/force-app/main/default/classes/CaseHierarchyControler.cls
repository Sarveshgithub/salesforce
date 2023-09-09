/**
 * Class Name : CaseHierarchyControler
 * About : Controler of caseHierarchy controller
 */
public with sharing class CaseHierarchyControler {
  /**
   * Class Name : caseData
   * About : Structure case data
   */
  public class caseData {
    @AuraEnabled
    public Id caseId;
    @AuraEnabled
    public Id parentId;
    @AuraEnabled
    public String subject;
    @AuraEnabled
    public String caseNum;
    @AuraEnabled
    public String origin;
    @AuraEnabled
    public Boolean hasChildrenContent;

    public caseData(
      Id caseId,
      Id parentId,
      String subject,
      String caseNum,
      String origin,
      Boolean hasChildrenContent
    ) {
      this.caseId = caseId;
      this.parentId = parentId;
      this.subject = subject;
      this.caseNum = caseNum;
      this.origin = origin;
      this.hasChildrenContent = hasChildrenContent;
    }
  }

  /**
   * Method Name : getCaseChildRecords()
   * About : this method return wrapper of child cases
   */
  @AuraEnabled
  public static List<caseData> getCaseChildRecords(Id parentId) {
    try {
      Map<Id, caseData> mapOfCaseData = new Map<Id, caseData>();
      for (Case objCase : [
        SELECT Id, ParentId, Subject, Origin, CaseNumber
        FROM Case
        WHERE ParentId = :parentId
      ]) {
        mapOfCaseData.put(
          objCase.Id,
          new caseData(
            objCase.Id,
            objCase.ParentId,
            objCase.Subject,
            objCase.CaseNumber,
            objCase.Origin,
            false
          )
        );
      }

      for (Case objCase : [
        SELECT Id, ParentId, Subject, Origin, CaseNumber
        FROM Case
        WHERE ParentId = :mapOfCaseData.keySet()
      ]) {
        if (mapOfCaseData.containsKey(objCase.ParentId)) {
          mapOfCaseData.get(objCase.ParentId).hasChildrenContent = true;
        }
      }
      return mapOfCaseData.values();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}