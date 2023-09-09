/**
 * Class Name : LWCSchedulerInvoiceJobController
 * About : This class is controller of LWC Scheduler
 */
public with sharing class LWCSchedulerInvoiceJobController {
  private static final String SOQL = 'SELECT Id,Invoice_Generated__c,Status FROM Order WHERE Status = \'Activated\' AND Invoice_Generated__c = false';
  private static final String CLASS_NAME = 'LWCSchedulerInvoiceJobController';

  @AuraEnabled
  public static CronTrigger getCurrentlyScheduleCron(String cronJobName) {
    List<CronTrigger> cronTriggers = [
      SELECT
        Id,
        CronExpression,
        PreviousFireTime,
        NextFireTime,
        StartTime,
        TimeZoneSidKey,
        State
      FROM CronTrigger
      WHERE CronJobDetail.Name = :cronJobName
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    CronTrigger cronTrigger = (cronTriggers.size() == 1)
      ? cronTriggers.get(0)
      : null;

    if (cronTrigger != null) {
      return cronTrigger;
    }

    return null;
  }

  @AuraEnabled
  public static Boolean scheduleJob(String cronString, String cronJobName) {
    try {
      BatchScheduler scheduler = new BatchScheduler(SOQL);
      System.schedule(cronJobName, cronString, scheduler);
      return true;
    } catch (Exception e) {
      BatchGenerateInvoiceService.generateErrorException(
        CLASS_NAME,
        e.getMessage()
      );
      return false;
    }
  }

  @AuraEnabled
  public static Boolean reScheduleJob(String cronString, String cronJobName) {
    try {
      return deleteScheduledJob(cronJobName)
        ? scheduleJob(cronString, cronJobName)
        : false;
    } catch (Exception e) {
      BatchGenerateInvoiceService.generateErrorException(
        CLASS_NAME,
        e.getMessage()
      );
      return false;
    }
  }

  @AuraEnabled
  public static Boolean deleteScheduledJob(String cronJobName) {
    try {
      List<CronTrigger> cronTriggers = [
        SELECT Id, CronExpression
        FROM CronTrigger
        WHERE CronJobDetail.Name = :cronJobName
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      CronTrigger cronTrigger = (cronTriggers.size() == 1)
        ? cronTriggers.get(0)
        : null;
      System.abortJob(cronTrigger.Id);
      return true;
    } catch (Exception e) {
      BatchGenerateInvoiceService.generateErrorException(
        CLASS_NAME,
        e.getMessage()
      );
      return false;
    }
  }

  public static void executeInvoiceBatch(){
    Database.executeBatch(new BatchGenerateInvoice(SOQL));
  }
}