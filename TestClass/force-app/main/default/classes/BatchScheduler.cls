public class BatchScheduler implements Schedulable {
  private String query;
  public BatchScheduler(String query) {
    this.query = query;
  }
  public void execute(SchedulableContext context) {
    Database.executeBatch(new BatchGenerateInvoice(query));
  }
}