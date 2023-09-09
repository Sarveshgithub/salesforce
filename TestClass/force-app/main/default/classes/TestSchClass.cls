global class TestSchClass implements Schedulable {
  global static void schedule(String exp) {
    TestSchClass obj = new TestSchClass();
    //String exp = '0 0 * * * ?';
    System.schedule('Send Mail To Biden', exp, obj);
  }
  global void execute(SchedulableContext ctx) {
    ReportGenerationController obj = new ReportGenerationController();
    obj.generateReport();
  }
}