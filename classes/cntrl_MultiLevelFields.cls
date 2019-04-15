public with sharing class cntrl_MultiLevelFields
{
    public class ErrorException extends Exception
    {
    }
    public class Options
    {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
        public Options(string label, string value)
        {
            this.label = label;
            this.value = value;
        }
    }
    public class FieldWrapper
    {
        @AuraEnabled
        public string fieldApiName;
        @AuraEnabled
        public string fieldLabel;
        @AuraEnabled
        public string fieldDataType;
        @AuraEnabled
        public List<Options> lstOption;// case for picklist
        public FieldWrapper(string fieldApiName, string fieldLabel, string fieldDataType, List<Options> lstOption)
        {
            this.fieldApiName = fieldApiName;
            this.fieldLabel = fieldLabel;
            this.fieldDataType = fieldDataType;
            this.lstOption = lstOption;
        }
    }
	@AuraEnabled
    public static List<FieldWrapper> getFileds(String objectName, List<String> lstFields)
    {
        List<FieldWrapper> lstFieldWrapper = new List<FieldWrapper>();
        //List<string> lstFields = new List<string>{'Name', 'Test_checkbox__c', 'LeadSource'};
        List<Options> lstOptions;
        //string objectName = 'Contact';
        //string fieldName = 'Name';
        SObjectType r = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        String fieldType,fieldLabel,fieldAPI;
        for(string field: lstFields)
        {
            //check if field contains 
            try{
                if(d.fields.getMap().containsKey(field))
                {	lstOptions = new List<Options>();
                    fieldType = String.valueOf(d.fields.getMap().get(field).getDescribe().getType());
                    fieldLabel = String.valueOf(d.fields.getMap().get(field).getDescribe().getLabel());
                    fieldAPI = String.valueOf(d.fields.getMap().get(field));
                    System.debug('type::'+fieldType);
                    System.debug('label::'+fieldLabel);
                    System.debug('fieldAPI::'+fieldAPI);
                    if(fieldType == 'PICKLIST'){
                        lstOptions = picklist_values(objectName,fieldAPI);
                    }
                    lstFieldWrapper.add(new FieldWrapper(fieldAPI,fieldLabel,fieldType,lstOptions));
                }
                else{
                    throw new  ErrorException('Please check field API Names of '+field);
                }
            }
            catch(Exception e){
                System.debug('e:'+e.getMessage());
            }
        }
        System.debug('lstFieldWrapper'+lstFieldWrapper);
        return lstFieldWrapper;
    }
    public static List<Options> picklist_values(String object_name, String field_name) {
        List<Options> lstPicklistValues = new List<Options>();
        String[] types = new String[]{object_name};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for (Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    lstPicklistValues.add( new Options(entry.getLabel(), entry.getValue() ) );
                }
            }
        }
        return lstPicklistValues;
    }
}