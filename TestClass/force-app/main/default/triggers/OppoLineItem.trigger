trigger OppoLineItem on OpportunityLineItem (after Insert) {
    // Family Family == 'Sponsor'
    Map<Id,Id> mapofOppLineToProduct = new Map<Id,Id>();
    Map<Id,Id> mapofProductToOpp = new Map<Id,Id>();
    
    for(OpportunityLineItem objOppLineItem : Trigger.New){
        if(objOppLineItem.Product2Id != null && objOppLineItem.OpportunityId != null){
            mapofOppLineToProduct.put(objOppLineItem.Id, objOppLineItem.Product2Id);
            mapofProductToOpp.put(objOppLineItem.Product2Id, objOppLineItem.OpportunityId);
        }
    }
    
    List<Opportunity> oppInsert = new List<Opportunity>();
    
    for(Product2 product : [Select Id,Family From Product2 Where  Family = 'Sponsor' AND ID IN : mapofOppLineToProduct.values()]){
        oppInsert.add(new Opportunity(Id = mapofProductToOpp.get(product.ID), Type = 'Sponsor'));
    }
    
    If(oppInsert.size() > 0){
        Database.update(oppInsert, false);
    }
    
}