/**
 * Class Name : BatchGenerateInvoiceService
 * About : This class is used for service class of BatchGenerateInvoice
 */
public with sharing class BatchGenerateInvoiceService {
  /**
   * Method : generateErrorLogforRecordFails()
   * Params : className, saveResultList
   * About : generate error logs of failed records
   */
  public static void generateErrorLogforRecordFails(
    String className,
    List<Database.SaveResult> saveResultList
  ) {
    List<Error_Log__c> errorLog = new List<Error_Log__c>();
    for (Database.SaveResult sr : saveResultList) {
      if (!sr.isSuccess()) {
        for (Database.Error err : sr.getErrors()) {
          errorLog.add(
            new Error_Log__c(
              Class_Name__c = className,
              Error__c = 'The following error has occurred.\n' +
                err.getStatusCode() +
                ': ' +
                err.getMessage()
            )
          );
        }
      }
    }
    if (errorLog.size() > 0) {
      insert errorLog;
    }
  }
  /**
   * Method : generateErrorException()
   * Params : className, errorMsg
   * About : generate error log for exception
   */
  public static void generateErrorException(String className, String errorMsg) {
    insert new Error_Log__c(Class_Name__c = className, Error__c = errorMsg);
  }
  /**
   * Method : sendEmails()
   * Params : jobId, toAddresses
   * About : send summary mail
   */
  public static void sendEmails(Id jobId, List<String> toAddresses) {
    AsyncApexJob a = [
      SELECT
        Id,
        Status,
        ExtendedStatus,
        NumberOfErrors,
        JobItemsProcessed,
        TotalJobItems,
        CreatedBy.Email
      FROM AsyncApexJob
      WHERE Id = :jobId
    ];

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toAddresses);
    mail.setSubject('Invoice Generation Process ' + a.Status);
    mail.setPlainTextBody(
      'No of Invoice processed ' +
      a.TotalJobItems +
      ' with ' +
      a.NumberOfErrors +
      ' failures' +
      ' At ' +
      system.now()
    );
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }
}