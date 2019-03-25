public with sharing class ContentLibraryController {
    
    public class wrapperReturn{
        @AuraEnabled
        public list<ContentWorkspace> lstContentWrkspce;
        @AuraEnabled
        public List<ContentVersion> lstContentDocRel;
        @AuraEnabled
        public List<ContentVersion> lstContentDocNotRel;
        @AuraEnabled
        public List<wrapperField> lstFields;
        
        public wrapperReturn(list<ContentWorkspace> lstContentWrkspce, List<ContentVersion> lstContentDocRel, 
                             List<ContentVersion> lstContentDocNotRel, list<wrapperField> lstFields){
                                 this.lstContentWrkspce = lstContentWrkspce;
                                 this.lstContentDocRel = lstContentDocRel;
                                 this.lstContentDocNotRel = lstContentDocNotRel;
                                 this.lstFields = lstFields;
                             }
    }
    public class wrapperField{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldApi;
        @AuraEnabled
        public String fieldType;
        
        public wrapperField(String label, String fieldApi, String fieldType){
            this.label = label;
            this.fieldApi = fieldApi;
            this.fieldType = fieldType;
        }
    }
    
    public class wrappQuery{
        @AuraEnabled
        public String FinalQueryNotRelated;
        @AuraEnabled
        public String FinalQueryRelated;
        
        public wrappQuery(String FinalQueryNotRelated, String FinalQueryRelated){
            this.FinalQueryNotRelated = FinalQueryNotRelated;
            this.FinalQueryRelated = FinalQueryRelated;
        }
    }    
    /**
@Method Name   : loadData
@Param         : ID
@ReturnType    : wrapperReturn 
@Discription   : it will return contentDocument records and content library records
**/
    @AuraEnabled
    public static wrapperReturn loadData(Id recordId, String strfields){
        if(!isUserhasPermission()){ // check user has object level permission
            return null;
        }
        list<ContentWorkspace> lstContWorkSp = [SELECT Id, Name FROM ContentWorkspace];
        
        list<wrapperField> lstWrapField = validateAllfields(strfields);
        
        // code to query related content records       
        set<Id> conDocId = new set<ID>();
        for(ContentDocumentLink obj :[SELECT ContentDocumentId 
                                      FROM ContentDocumentLink
                                      WHERE LinkedEntityId =: recordId])
        {
            conDocId.add(obj.ContentDocumentId);
        }
        
        wrappQuery objQury = formQueryString(lstWrapField, lstContWorkSp[0].Id, conDocId );
        // it will return the content files which are not related to current record
        list<ContentVersion> lstContentDocNotRel = getContentDocument(lstContWorkSp[0].Id, conDocId, objQury.FinalQueryNotRelated);
        // end
        // it will return  the content files which are associated with current record
        list<ContentVersion> lstContentDocRel;
        if(!conDocId.isEmpty()){
            lstContentDocRel = getContentDocument(lstContWorkSp[0].Id, conDocId, objQury.FinalQueryRelated);
        }
        // end
        return new wrapperReturn(lstContWorkSp, lstContentDocRel, lstContentDocNotRel, lstWrapField);
        
        // return formQueryNdGetRecs(lstContWorkSp[0].id, lstWrapfield, recordId);
    }
    
    /**
@Method Name   : getContentDocument
@Param         : ID, ID, STRING
@ReturnType    : list<ContentDocument> 
@Discription   : it will return content record 
**/
    private static list<ContentVersion> getContentDocument(ID strcontentWrspID, set<ID> conDocId, String strQuery){
        list<ContentVersion> lstContentDoc = Database.query(strQuery);
        return lstContentDoc;
    }
    
    /**
@Method Name   : validateAllfields
@Param         : string 
@ReturnType    : 
@Discription   : 
**/
    public static list<wrapperField> validateAllfields(String strFieldName){
        
        List<String> lstFields = strFieldName.split(',');
        String[] types = new String[]{'ContentVersion'};
            list<wrapperField> lstwrappField = new list<wrapperField>();
        Schema.DescribeSobjectResult[] dsr = Schema.describeSObjects(types);
        Map<String, Schema.SObjectField> rootFldMap = dsr[0].fields.getMap();
        for(String key : lstFields){
            if(rootFldMap.containsKey(key)){
                Schema.DescribeFieldResult dfr = rootFldMap.get(key).getDescribe();
                if(dfr.isAccessible()){
                    if(dfr.getType() == Schema.DisplayType.REFERENCE){
                        // handle reference 
                        if(key.endsWith('__c')){
                            key = dfr.getName().replace('__c','__r.Name');
                            lstwrappField.add( new wrapperField(dfr.getLabel(), key, String.valueOf(dfr.getType())) );
                        }else if(key.endsWithIgnoreCase('Id')){
                            key = dfr.getName().removeEndIgnoreCase('Id')+ '.Name';
                            lstwrappField.add( new wrapperField(dfr.getLabel(), key, String.valueOf(dfr.getType())) );
                        }
                    }else{
                        lstwrappField.add( new wrapperField(dfr.getLabel(), dfr.getName(), String.valueOf(dfr.getType())) );
                    }
                }
            }else{
                list<String> tempFld = key.split('\\.');
                
                tempFld[0] = tempFld[0].toLowerCase();
                if(tempFld[0].endsWith('__r')){
                    tempFld[0] = tempFld[0].removeEnd('__r') + '__c';
                }else{
                    tempFld[0] = tempFld[0] + 'Id';
                }
                if(rootFldMap.containsKey(tempFld[0])){
                    Schema.DescribeFieldResult dfr = rootFldMap.get(tempFld[0]).getDescribe();
                    Schema.sObjectType[] refs = dfr.getReferenceTo();
                    Schema.Describesobjectresult finalObj = refs[0].getDescribe();
                    Map<String, Schema.SObjectField> parentrootFld = finalObj.fields.getMap();
                    if(parentrootFld.containsKey(tempFld[1].toLowerCase())){
                        Schema.DescribeFieldResult dfrParent = parentrootFld.get(tempFld[1].toLowerCase()).getDescribe();
                        if(dfrParent.isAccessible()){
                            if(dfrParent.getType() == Schema.DisplayType.REFERENCE){
                                if(tempFld[1].endsWith('__c')){
                                    lstwrappField.add( new wrapperField(dfrParent.getLabel(), key.removeEndIgnoreCase('__c')+'__r.Name', String.valueOf(dfrParent.getType())) );
                                }else if(tempFld[1].endsWithIgnoreCase('Id')){
                                    lstwrappField.add( new wrapperField(dfrParent.getLabel(), key.removeEndIgnoreCase('Id')+'.Name', String.valueOf(dfrParent.getType())) );                                   
                                }
                            }else{
                                lstwrappField.add( new wrapperField(dfrParent.getLabel(), key, String.valueOf(dfrParent.getType())) );
                            }
                        }
                    }
                }
            }   
        }
        return lstwrappField;
    }
    
    private static wrappQuery formQueryString(list<wrapperField> lstWrapField, ID strcontentWrspID, set<ID> conDocId ){
        String strQuery = '';
        for(wrapperField wrpO : lstWrapField){
            if(string.isNotBlank(strQuery)){
                strQuery = strQuery + ', '+ wrpO.fieldApi;
            }else{
                strQuery = 'ContentDocumentId,'+wrpO.fieldApi;
            }         
        }  
        // this query for getContentDocumentNotRelated method
        String whereQueryNotRelated = '';
        if(String.isNotBlank(strcontentWrspID)){
            whereQueryNotRelated +='WHERE ContentDocumentId IN (SELECT ContentDocumentId FROM ContentWorkspaceDoc WHERE ContentWorkspaceId =: strcontentWrspID) ';
        }
        if(!conDocId.isEmpty()){
            if(String.isNotBlank(strcontentWrspID)){
                whereQueryNotRelated += 'AND ContentDocumentId <>: conDocId ';
            }else{
                whereQueryNotRelated += 'WHERE ContentDocumentId <>: conDocId ';
            }
        }
        // end 
        
        //this query for getContentDocumentRelated 
        String whereQueryRelated = '';
        if(String.isNotBlank(strcontentWrspID)){
            whereQueryRelated +='WHERE ContentDocumentId IN (SELECT ContentDocumentId FROM ContentWorkspaceDoc WHERE ContentWorkspaceId =: strcontentWrspID) ';
        }
        if(!conDocId.isEmpty()){
            if(String.isNotBlank(strcontentWrspID)){
                whereQueryRelated += 'AND ContentDocumentId =: conDocId ';
            }else{
                whereQueryRelated += 'WHERE ContentDocumentId =: conDocId ';
            }
        }
        //end 
        String FinalQueryNotRelated = 'SELECT '+ strQuery + ' FROM ContentVersion ' + whereQueryNotRelated ; 
        String FinalQueryRelated = 'SELECT '+ strQuery + ' FROM ContentVersion ' + whereQueryRelated ; 
        return new wrappQuery(FinalQueryNotRelated, FinalQueryRelated);
    }
    
    
    private static Boolean isUserhasPermission(){
        String[] types = new String[]{'ContentDocument'};
            Schema.DescribeSobjectResult[] result = Schema.describeSObjects(types);
        if(!result[0].isAccessible() && !result[0].isQueryable()){
            return false;
        }
        return true;
    }
    public class wrapperParse{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public string documentId;
    }
    
    @AuraEnabled
    public static string linkFiletoLib(String lstdocId, String libID){
        List<wrapperParse> lst = (List<wrapperParse>)JSON.deserialize(lstdocId, List<wrapperParse>.class);
        if(!String.isEmpty(libID) && lst.size() > 0){
            list<ContentWorkspaceDoc> lstcwd = new list<ContentWorkspaceDoc>();
            for(wrapperParse o : lst){
                ContentWorkspaceDoc obj = new ContentWorkspaceDoc(ContentDocumentID = o.documentId, ContentWorkspaceId = libID);
                lstcwd.add(obj);
            }
            INSERT lstcwd;
        }
        return null;
    }
    @AuraEnabled
    public static wrapperReturn getRecords(String contentWorkspID,String  lstWrapfield, String recordId){
        
        List<wrapperField> lstWrpperField = (List<wrapperField>)JSON.deserialize(lstWrapfield, List<wrapperField>.class);
        return formQueryNdGetRecs(contentWorkspID, lstWrpperField, recordId);
    }
    
    private static wrapperReturn formQueryNdGetRecs(String contentWorkspID, List<wrapperField> lstWrapfield, String recordId){
        list<ContentWorkspace> lstContWorkSp = [SELECT Id, Name FROM ContentWorkspace];
        // code to query related content records   
        set<Id> conDocId = new set<ID>();
        for(ContentDocumentLink obj :[SELECT ContentDocumentId 
                                      FROM ContentDocumentLink
                                      WHERE LinkedEntityId =: recordId])
        {
            conDocId.add(obj.ContentDocumentId);
        }
        wrappQuery objQury = formQueryString(lstWrapField, contentWorkspID, conDocId );
        // it will return the content files which are not related to current record
        list<ContentVersion> lstContentDocNotRel = getContentDocument(contentWorkspID, conDocId, objQury.FinalQueryNotRelated);
        
        // end
        // it will return  the content files which are associated with current record
        list<ContentVersion> lstContentDocRel = new  list<ContentVersion>();
        if(!conDocId.isEmpty()){
            lstContentDocRel = getContentDocument(contentWorkspID, conDocId, objQury.FinalQueryRelated);
        }
        // end
        return new wrapperReturn(lstContWorkSp, lstContentDocRel, lstContentDocNotRel, lstWrapField);
    }
    
    @AuraEnabled
    public static string relateFile(String documentId,String recordId){
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = documentId;
        cDe.LinkedEntityId = recordId; 
        cDe.ShareType = 'V';
        insert cDe;
        return 'sucess';        
    }
    
    @AuraEnabled
    public static string unrelateFile(String documentId, String recordId){
        delete [Select Id FROM ContentDocumentLink Where ContentDocumentId =: documentId AND LinkedEntityId = : recordId];
        return 'sucess';
    }
}