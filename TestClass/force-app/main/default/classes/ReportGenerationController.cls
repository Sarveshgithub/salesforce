public class ReportGenerationController {
  //Generate report Based on parameter
  public void generateReport() {
    try {
      List<Report> reportList = [
        SELECT Id, DeveloperName, Name
        FROM Report
        WHERE DeveloperName = 'New_Accounts_Report'
      ];
      if (reportList.size() > 0) {
        String reportId = (String) reportList.get(0).get('Id');

        //Get Report Name
        string reportName = (String) reportList.get(0).get('Name');

        //get instance Url
        String instanceName = URL.getSalesforceBaseUrl().toExternalForm();

        string url =
          instanceName +
          '/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=' +
          reportId;

        ApexPages.PageReference objPage = new ApexPages.PageReference(url);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();
        objMsgEmailAttach.setFileName(reportName + '.csv');
        objMsgEmailAttach.setBody(objPage.getContent());
        objMsgEmailAttach.setContentType('text/csv');
        email.setSubject(reportName);

        List<Messaging.EmailFileAttachment> attach = new List<Messaging.EmailFileAttachment>();
        attach.add(objMsgEmailAttach);
        email.setFileAttachments(attach);

        EmailService service = new EmailService(email);
        service.body =
          'Hello, <br/><br/> Here is attached ' +
          reportName +
          '.<br/><br/>Thank You.<br/>Admin';
        service.isHtml = true;
        service.toAddresses = new List<string>();
        //service.toAddresses.add('contactus@salesforcecodex.com');
        service.toAddresses.add('sarveshkumar574@gmail.com');
        service.displayName = 'Salesforce Codex';
        service.subject = reportName;
        service.sendMail();
        system.debug('Ran');
      }
    } catch (Exception ex) {
      system.debug(ex.getMessage());
    }
  }
}