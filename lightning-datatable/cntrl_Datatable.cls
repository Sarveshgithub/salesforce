public  class cntrl_Datatable {
    
    public class ResultWrapper {
        
        @AuraEnabled
        public list<SObject> lstSObject;
        @AuraEnabled
        public list<FieldsWrapper> lstFields;
        
        public ResultWrapper(list<SObject> lstSObject, list<FieldsWrapper> lstFields) {
            
            this.lstSObject = lstSObject;
            this.lstFields  = lstFields;
        }
    }
    
    public class FieldsWrapper {
        
        @AuraEnabled
        public String fieldName { get;set; }
        @AuraEnabled
        public String label     { get;set; }
        @AuraEnabled
        public String type      { get; set; }
        @AuraEnabled
        public Boolean sortable {get;set;}
        
        
        public FieldsWrapper(String fieldName, String strLabel, String strType,Boolean sortable) {
            this.fieldName = fieldName;
            this.label = strLabel;
            this.type = strType;
            this.sortable = sortable;
        }
    }
    
    
    @AuraEnabled
    public static ResultWrapper  fetchContact( String strSObjectName, String strFieldsetName)
    {
        
        Set<String> setFieldsToQuery = new set<String>();
        List<FieldsWrapper> lstFieldsetWrapper = new List<FieldsWrapper>();
       // Map<String, String> mapfiledpathlael = new Map<String, String>();
        Schema.DescribeSObjectResult describeSobj = Schema.SObjectType.Contact;
		Map<String, Schema.SObjectField> fieldMap = describeSobj.fields.getMap();
        for(Schema.FieldSetMember fieldSetMemberObj : readFieldSet(strFieldsetName, strSObjectName)) {    
            String strFieldName = fieldSetMemberObj.getFieldPath().toLowerCase(); 
	            if(String.valueOf(fieldSetMemberObj.getType()).trim() == 'REFERENCE') {
                    System.debug('strFieldName1:'+strFieldName);
	                    strFieldName = strFieldName.replace('__c','__r.Name');
	                    strFieldName = strFieldName.replace('id','.Name');
	                }
                    System.debug('strFieldName2:'+strFieldName);
                    setFieldsToQuery.add(strFieldName);
        
           // mapfiledpathlael.put(String.valueOf(fieldSetMemberObj.getType()), fieldSetMemberObj.getFieldPath());
            lstFieldsetWrapper.add(new FieldsWrapper(fieldSetMemberObj.getFieldPath(), fieldSetMemberObj.getLabel(),String.valueOf(fieldSetMemberObj.getType()).toLowerCase(), true));
        }
        System.debug('setFieldsToQuery+'+setFieldsToQuery);
        String queryString = 'Select  id, ';
        setFieldsToQuery.remove('id');
        queryString += String.join( new List<String>(setFieldsToQuery), ',');
        queryString.removeEnd(',');
        queryString += ' FROM ' + strSObjectName +' Limit 5';
        System.debug('queryString::'+queryString);
        list<SObject> lstSObject = Database.query(queryString);
        System.debug('lstSObject::'+lstSObject);
        return new ResultWrapper(lstSObject,lstFieldsetWrapper);
    }
    
    private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
    
    @AuraEnabled
    public static boolean deleteRecord(ID recId) {
        Database.delete(recId);
        return true;
    }

    @AuraEnabled
	public static Boolean updateRecords(String updateRecs) {
        List<Contact> contact = (List<Contact>)JSON.deserialize(updateRecs, List<Contact>.Class);
        
		try {
            update contact;
            return true;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
	}
    
}