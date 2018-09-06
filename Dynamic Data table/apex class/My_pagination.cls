public class My_pagination {
    
    public class ResultWrapper {
        
        @AuraEnabled
        public list<SObject> lstSObject;
        @AuraEnabled
        public Map<String, List<String>> mappicklistval { get;set; }
        @AuraEnabled
        public list<FieldsWrapper> lstFields;
        @AuraEnabled
        public Integer intoffset     { get;set; }
        @AuraEnabled
        public Object objCountId     { get;set; }
        @AuraEnabled
        public String strColName     { get;set; }
        @AuraEnabled
        public String strOrderBy     { get;set; } 
        
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
    public static ResultWrapper  fetchContact( String strSObjectName, String strFieldsetName)
    {
        
        Set<String> setFieldsToQuery = new set<String>();
        List<FieldsWrapper> lstFieldsetWrapper = new List<FieldsWrapper>();
        Map<String, String> mapfiledpathlael = new Map<String, String>();
        
        for(Schema.FieldSetMember fieldSetMemberObj : readFieldSet(strFieldsetName, strSObjectName)) {            
            if(String.valueOf(fieldSetMemberObj.getType()).trim() == 'REFERENCE') {
                if(fieldSetMemberObj.getFieldPath().toLowerCase().endsWith('__c')){
                    if(fieldSetMemberObj.getFieldPath().containsIgnoreCase('claim'))
                        setFieldsToQuery.add(fieldSetMemberObj.getFieldPath().toLowerCase().replace('__c','__r.CaseNumber'));
                    else
                         setFieldsToQuery.add(fieldSetMemberObj.getFieldPath().toLowerCase().replace('__c','__r.Name'));
                }
                else if(fieldSetMemberObj.getFieldPath().toLowerCase().endsWith('id')){
                    setFieldsToQuery.add(fieldSetMemberObj.getFieldPath().toLowerCase().replace('id','.Name'));
                }
            }
            setFieldsToQuery.add(fieldSetMemberObj.getFieldPath().toLowerCase());
            mapfiledpathlael.put(String.valueOf(fieldSetMemberObj.getType()), fieldSetMemberObj.getFieldPath());
            

            lstFieldsetWrapper.add(new FieldsWrapper(fieldSetMemberObj.getFieldPath(), fieldSetMemberObj.getLabel(),String.valueOf(fieldSetMemberObj.getType())));
        }
        System.debug('mapfiledpathlael++++++++'+mapfiledpathlael);
        //String strPicklistLabel;
        List<String> options = new List<String>();
        Map<string, List<String>> mapfieldnamevalues = new Map<string, List<String>>();
        for(String mapofpicklist : mapfiledpathlael.keySet()) {

        	if(mapofpicklist == 'PICKLIST') {
				String strPicklistLabel = mapfiledpathlael.get(mapofpicklist);
				System.debug('strPicklistLabel'+mapfiledpathlael.get(mapofpicklist));
				Schema.SObjectField sobjField = Schema.getGlobalDescribe().get(strSObjectName).getDescribe().Fields.getMap().get(strPicklistLabel) ;
                Schema.DescribeFieldResult fieldResult = sobjField.getDescribe() ;
				//Schema.DescribeFieldResult fieldResult = strSObjectName.strPicklistLabel.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

				for( Schema.PicklistEntry f : ple) {
				options.add(f.getLabel());
				}
				mapfieldnamevalues.put(strPicklistLabel, options);	
        	}	
        }

        String queryString = 'Select  id, ';
        setFieldsToQuery.remove('id');
        queryString += String.join( new List<String>(setFieldsToQuery), ',');
        queryString.removeEnd(',');
        queryString += ' FROM ' + strSObjectName +' limit 10';

        System.debug('=======Query Value===='+Database.query(queryString));

        list<SObject> lstSObject = Database.query(queryString);
   
        return new ResultWrapper(lstSObject,lstFieldsetWrapper);
    }
     
    private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
    
}