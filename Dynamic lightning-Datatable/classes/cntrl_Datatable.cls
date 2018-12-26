public  class cntrl_Datatable {
    
    public class ResultWrapper {
        
        @AuraEnabled
        public list<SObject> lstSObject;
        @AuraEnabled
        public list<FieldsWrapper> lstFields;
        @AuraEnabled
        public String baseURL;
        
        public ResultWrapper(list<SObject> lstSObject, list<FieldsWrapper> lstFields,String baseURL) {
            
            this.lstSObject = lstSObject;
            this.lstFields  = lstFields;
            this.baseURL = baseURL;
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
    
    @AuraEnabled
    public static ResultWrapper loadData(String objectAPIName, String lstFields, String filterCriteria) {
        
        String errMsg = '';
        Schema.DescribeSObjectResult result = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        //object level access
        if(!result.isAccessible()){
            errMsg = 'Insufficient Privileges';
            throw new AuraHandledException( errMsg );
        }
        map<String, String> customlabel = new map<String, String>();
        String[] flds = lstFields.split(',');
        String[] RelFields = new String[]{};
        for(String strfld : flds){
            if(strfld.contains('(')){
                RelFields.add(strfld.substringBefore('('));
                customlabel.put(strfld.substringBefore('('), strfld.substringBetween('(', ')'));
            }else{
                RelFields.add(strfld);
            }
        }
        FieldsWrapper[] lstWrapfields = getFldMap(RelFields, objectAPIName, customlabel);
        String strQuery = '';
        set<String> uniqueFields = new set<String>();
        for(FieldsWrapper fld : lstWrapfields){
            uniqueFields.add(fld.fieldName.toLowerCase());
        }
        list<String> queryFields = new list<String>();
        queryFields.addAll(uniqueFields);
        strQuery = String.join(queryFields, ',');
        
        String finalQuery = 'SELECT '+strQuery+' FROM '+objectAPIName;
        
        if(String.isNotBlank(filterCriteria)){
            finalQuery += ' WHERE '+filterCriteria;
        }
        finalQuery += ' LIMIT 1000';
        list<sObject> records = Database.query(finalQuery);
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        return new ResultWrapper(records, lstWrapfields, baseURL);
    }
    
    private static FieldsWrapper[] getFldMap(String[] flds, String objName, map<String, String> customlabel) {
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Schema.Describesobjectresult parentObj = gdMap.get(objName).getDescribe();
        Map<String, Schema.SObjectField> FldMap = parentObj.fields.getMap();
        String strInvalidField = '';
        FieldsWrapper[] lstFW = new FieldsWrapper[]{};
            
            for(String key : flds){
                if(FldMap.containsKey(key)) {
                    Schema.DescribeFieldResult dfr = FldMap.get(key).getDescribe();
                    // field level access permission
                    if(dfr.isAccessible()) {
                        
                        String strlabel = dfr.getLabel();
                        String strType = String.valueOf(dfr.getType());
                        if(strType == 'REFERENCE'){
                            if(key.endsWith('__c')){
                                key = key.removeEnd('__c');
                                key = key+'__r.Name';
                            }else if(key.endsWithIgnoreCase('id')){
                                key = key.removeEndIgnoreCase('id') +'.Name';
                            }
                            strType = 'url';
                        }
                        if(key.toLowerCase() == 'name'){
                            strType = 'url';
                        }
                        if(customlabel.containsKey(key)){
                            strlabel = customlabel.get(key);
                        }
                        lstFW.add(new FieldsWrapper(key, strlabel, strType, true));
                    }
                }else{
                    String[] tempArry = key.split('\\.');
                    
                    Integer lstSize = tempArry.size();
                    String finalFld = tempArry[lstSize-1].toLowerCase(); 
                    
                    Schema.Describesobjectresult finalObj;
                    Schema.DescribeFieldResult finalFldRes;
                    
                    String[] actLabelArry = new String[]{};
                        String actLabel = '';
                    
                    if(lstSize > 2) {
                        for(Integer i=0;i<=lstSize-2;i++) {
                            String tempFld = tempArry[i].toLowerCase();
                            
                            if(tempFld.endsWith('__r')) {
                                tempFld = tempFld.removeEnd('__r') + '__c';
                            }
                            else {
                                tempFld += 'Id';
                            }
                            
                            strInvalidField = tempFld;
                            if(FldMap.containsKey(tempFld) || finalObj.fields.getMap().containsKey(tempFld)) {
                                strInvalidField = '';
                                if(i == 0) {
                                    Schema.DescribeFieldResult dfr = FldMap.get(tempFld).getDescribe();
                                    Schema.sObjectType[] refs = dfr.getReferenceTo();
                                    
                                    finalObj = refs[0].getDescribe();
                                    actLabelArry.add(dfr.getLabel());
                                }
                                else {
                                    Schema.DescribeFieldResult dfr = finalObj.fields.getMap().get(tempFld).getDescribe();
                                    Schema.sObjectType[] refs = dfr.getReferenceTo();
                                    
                                    finalObj = refs[0].getDescribe();
                                    actLabelArry.add(dfr.getLabel());
                                }
                            }
                        }
                        actLabel = String.join(actLabelArry,' > ');
                    }
                    else {
                        String tempFld = tempArry[0].toLowerCase();
                        
                        if(tempFld.endsWith('__r')) {
                            tempFld = tempFld.removeEnd('__r') + '__c';
                        }
                        else {
                            tempFld += 'Id';
                        }
                        strInvalidField = tempFld;
                        if(FldMap.containsKey(tempFld)) {
                            strInvalidField = '';
                            Schema.DescribeFieldResult dfr = FldMap.get(tempFld).getDescribe();
                            Schema.sObjectType[] refs = dfr.getReferenceTo();
                            
                            finalObj = refs[0].getDescribe();
                        }
                    }
                    
                    Map<String, Schema.SObjectField> fieldMapTemp = finalObj.fields.getMap();
                    
                    strInvalidField = finalFld;
                    if(fieldMapTemp.containsKey(finalFld)) {
                        strInvalidField = '';
                        Schema.DescribeFieldResult dfrTemp = fieldMapTemp.get(finalFld).getDescribe();
                        
                        actLabel += ((actLabel != '')?('.' + dfrTemp.getLabel()):(dfrTemp.getLabel()));
                        
                        String fldType = String.valueOf(dfrTemp.getType());
                        if(customlabel.containsKey(key)){
                            actLabel = customlabel.get(key);
                        }
                        lstFW.add(new FieldsWrapper(key, actLabel, 'url', true));                  
                    }
                    else {
                        String strlabel = '';
                        if(customlabel.containsKey(key)){
                            strlabel = customlabel.get(key);
                        }
                        lstFW.add(new FieldsWrapper(key, strlabel, 'url', true));
                    }
                    
                }
            }
        return lstFW;
        
    }
    
}