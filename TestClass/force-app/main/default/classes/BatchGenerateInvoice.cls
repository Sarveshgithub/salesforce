/**
 * Class Name : BatchGenerateInvoice
 * About : This Batch is used for to generate invoice and related invoice item records
 */
public class BatchGenerateInvoice implements Database.Batchable<sObject> {
  private final String CLASS_NAME = 'BatchGenerateInvoice';
  private String query;

  public BatchGenerateInvoice(String query) {
    this.query = query;
  }

  /**
   * Method : start()
   * Params : bc
   * About : start method of Batch : query the Order record which are active and Invoice_Generated__c is false
   */
  public Database.querylocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  /**
   * Method : execute()
   * Params : bc, scope
   * About : execute method of Batch : generate invoice, invoice item and updating the Invoice_Generated__c to true
   */
  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    try {
      List<Order> lstOfOrder = (List<Order>) scope;
      Map<Id, List<OrderItem>> mapOfOrderToListOfOrderItem = new Map<Id, List<OrderItem>>();
      Map<Id, Invoice__c> mapOfOrderIdToInvoice = new Map<Id, Invoice__c>();

      for (Order objOrder : lstOfOrder) {
        mapOfOrderToListOfOrderItem.put(objOrder.Id, new List<OrderItem>());
        mapOfOrderIdToInvoice.put(
          objOrder.Id,
          new Invoice__c(Order__c = objOrder.Id)
        );
      }

      for (OrderItem objOrderItem : [
        SELECT Id, OrderId, Product2Id
        FROM OrderItem
        WHERE OrderId IN :mapOfOrderToListOfOrderItem.keyset()
      ]) {
        mapOfOrderToListOfOrderItem.get(objOrderItem.OrderId).add(objOrderItem);
      }

      //Insert Invoice
      if (mapOfOrderIdToInvoice.values().size() > 0) {
        List<Database.SaveResult> saveResultList = Database.insert(
          mapOfOrderIdToInvoice.values(),
          false
        );
        BatchGenerateInvoiceService.generateErrorLogforRecordFails(
          CLASS_NAME,
          saveResultList
        );
      }

      List<Invoice_Item__c> lstOfInvoiceItem = new List<Invoice_Item__c>();
      for (Invoice__c objInvoice : mapOfOrderIdToInvoice.values()) {
        for (
          OrderItem objOrderItem : mapOfOrderToListOfOrderItem.get(
            objInvoice.Order__c
          )
        ) {
          lstOfInvoiceItem.add(
            new Invoice_Item__c(
              Invoice__c = objInvoice.Id,
              Order_Item__c = objOrderItem.Id,
              Product__c = objOrderItem.Product2Id
            )
          );
        }
      }

      //Insert Invoice Item
      if (lstOfInvoiceItem.size() > 0) {
        List<Database.SaveResult> saveResultList = Database.insert(
          lstOfInvoiceItem,
          false
        );
        BatchGenerateInvoiceService.generateErrorLogforRecordFails(
          CLASS_NAME,
          saveResultList
        );
      }

      //Update Flag Invoice_Generated__c to 'true'
      List<Order> updateOrderFlag = new List<Order>();
      for (Order objOrder : lstOfOrder) {
        updateOrderFlag.add(
          new Order(Id = objOrder.Id, Invoice_Generated__c = true)
        );
      }
      if (updateOrderFlag.size() > 0) {
        List<Database.SaveResult> saveResultList = Database.update(
          updateOrderFlag,
          false
        );
        BatchGenerateInvoiceService.generateErrorLogforRecordFails(
          CLASS_NAME,
          saveResultList
        );
      }
    } catch (Exception e) {
      BatchGenerateInvoiceService.generateErrorException(
        CLASS_NAME,
        e.getMessage()
      );
    }
  }

  /**
   * Method : finish()
   * Params : bc
   * About : finish method of Batch : send Summary of Batch Process
   */
  public void finish(Database.BatchableContext BC) {
    //Email can be picked from Custom setting
    List<String> toAddresses = new List<String>{ 'sarveshkumar574@gmail.com' };
    BatchGenerateInvoiceService.sendEmails(BC.getJobId(), toAddresses);
  }
}