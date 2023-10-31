SalesOrder
Gift - checkbox - rollup fomula if contains ( Gift) ? true : false
All_Gift - checkbox - rollup fomula count() if all product ==  Gift ? true : false

SalesOrderLineItem
SalesOrder - Master Detail
Product - LookUp

Product 
123Gift 
431Gift

Problem
Mark Gift = true if any SalesOrderLineItem product contains Gift
Mark  All_Gift = true if all SalesOrderLineItem product contains Gift

Example
- SalesOrder - required
- Product - required

Use Case 
- Insert 
- Update -  SalesOrder ( change ) - Product ( change )
- delete
- Best practice - handler class, service class

trigger on SalesOrderLineItem ( after Insert){

    // check trigger.new
    Set<Id> objSO = new Set<Id>();
    for(SalesOrderLineItem objSOLI : Trigger.new){
        objSO.add(objSOLI.SalesOrder);
    }
    Map<Id,Boolean> mapOfSOGift
    Map<Id,Boolean> mapOfSOAllGift
    // get all salesorderlineitem based on salesorder
    for(SalesOrder objSO : [SELECT id,(select id,product.name from saleorderlineItem) from  SalesOrder where Id IN : objSO]){
        for(SalesorderLineItem objOLi : saleorderlineItem){
            if(objOLi.product.name.contains('Gift')){
                mapOfSOGift.put(objSO.Id, true);
            }else{
                if(mapOfSOGift.containsKey(objSO.Id));
                mapOfSOGift.remove(objSO.Id);
            }
        }
        if(mapOfSOGift.containsKey(objSO.Id)){
            mapOfSOAllGift.put(objSO.Id, true);
        }
    }
    List<SalesOrder> lstUpdate = new List<SalesOrder>();
    for(Id objId: mapOfSOGift.keySet()){
        SalesOrder obj = new SalesOrder();
        obj.Id = objId;
        obj.Gift = true;
        if(mapOfSOAllGift.containsKey(objId)){
            obj.All_Gift = true;
        }
        lstUpdate.add(obj);
    }

    if(lstUpdate.size() > 0){
        Database.update(lstUpdate,true);
    }

}

- test class
- actual implement
- TDD approach - always test with test class