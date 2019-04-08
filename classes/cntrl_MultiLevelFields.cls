public with sharing class cntrl_MultiLevelFields {
    public class Options{
       @AuraEnabled
       public String label;
       @AuraEnabled
       public String value;
       public Options(String label,String value){
           this.label = label;
           this.value = value;
       }
    }
   public class FieldWrapper{
       @AuraEnabled
       public String fieldApiName;
       @AuraEnabled
       public String fieldLabel;
       @AuraEnabled
       public String fieldDataType;
       @AuraEnabled
       public List<Options> lstOption; // case for picklist
       public FieldWrapper(String fieldApiName, String fieldLabel, String fieldDataType, List<Options> lstOption){
           this.fieldApiName = fieldApiName;
           this.fieldLabel = fieldLabel;
           this.fieldDataType = fieldDataType;
           this.lstOption = lstOption;
       }
   }
    public static void getFileds(){
        List<String> lstFields = new List<String>{'Name','Type','xyz'};
        String objectName = 'Account';
        String fieldName = 'Name';
        SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        for(String field : lstFields){
            //check if filed contains 
            System.debug('data'+d.fields.getMap().containsKey(field));
        }

       /* System.debug('filed'+d.fields
                .getMap()
                .get(field)
                .getDescribe()
                .getType());*/
    }
}
