public class My_pagination {
    
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
        public String fieldPath { get;set; }
        @AuraEnabled
        public String label     { get;set; }
        @AuraEnabled
        public String type      { get; set; }
        
        public FieldsWrapper(String fieldPath, String strLabel, String strType) {
            this.fieldPath = fieldPath;
            this.label = strLabel;
            this.type = strType;
        }
    }
    
    
    @AuraEnabled
    public static ResultWrapper  fetchContact( String strSObjectName, String strFieldsetName, String filter)
    {
        
        Set<String> setFieldsToQuery = new set<String>();
        List<FieldsWrapper> lstFieldsetWrapper = new List<FieldsWrapper>();
        Map<String, String> mapfiledpathlael = new Map<String, String>();
        
        for(Schema.FieldSetMember fieldSetMemberObj : readFieldSet(strFieldsetName, strSObjectName)) {            
            setFieldsToQuery.add(fieldSetMemberObj.getFieldPath().toLowerCase());
            mapfiledpathlael.put(String.valueOf(fieldSetMemberObj.getType()), fieldSetMemberObj.getFieldPath());
            lstFieldsetWrapper.add(new FieldsWrapper(fieldSetMemberObj.getFieldPath(), fieldSetMemberObj.getLabel(),String.valueOf(fieldSetMemberObj.getType())));
        }
        String queryString = 'Select  id, ';
        setFieldsToQuery.remove('id');
        queryString += String.join( new List<String>(setFieldsToQuery), ',');
        queryString.removeEnd(',');
        queryString += ' FROM ' + strSObjectName+' WHERE '+filter;
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
    
}