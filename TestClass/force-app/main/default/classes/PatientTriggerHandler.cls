public class PatientTriggerHandler {
    public static void BeforeInsert(List<sObject> newList){
        
    }
    public static void AfterInsert(Map<Id,sObject> newMap, Map<Id,sObject> oldMap){
        
    }
    public static void BeforeUpdate(Map<Id,sObject> newMap, Map<Id,sObject> oldMap){
        Map<Id,Patient__c> newPatientMap = (Map<Id,Patient__c>)newMap;
        Map<Id,Patient__c> oldPatientMap = (Map<Id,Patient__c> )oldMap;
        updateStatusDateTime(oldPatientMap,newPatientMap);
    }
    
    public static void AfterUpdate(Map<Id,sObject> newMap, Map<Id,sObject> oldMap){
        Map<Id,Patient__c> newPatientMap = (Map<Id,Patient__c>)newMap;
        Map<Id,Patient__c> oldPatientMap = (Map<Id,Patient__c> )oldMap;
        calculateAverage(oldPatientMap,newPatientMap);
        
    }
    public static void BeforeDelete(Map<Id,sObject> oldMap){
        
    }
    public static void AfterDelete(Map<Id,sObject> oldMap){
        
    }
    public static void AfterUndelete(Map<Id,sObject> oldMap){
        
    }
    public static void calculateAverage(Map<Id,Patient__c> oldPatientMap,Map<Id,Patient__c> newPatientMap){
        Set<Id> areaId = new Set<Id>();
        for(Patient__c newObj : newPatientMap.values()){
            if(oldPatientMap.get(newObj.Id).Status__c != newObj.Status__c && (newObj.Status__c == 'Cured' || newObj.Status__c == 'Fatal')){
                areaId.add(newObj.Area__c);
            }
        }
        Map<Id,Integer> mapTotalDays = new Map<Id,Integer>();
        Map<Id,Integer> mapTotalPatients = new Map<Id,Integer>();
        for(Patient__c objPatient : [SELECT Id,Area__c,CreatedDate, StatusUpdateDate__c FROM Patient__c Where area__c IN : areaId]){
            Integer days = (objPatient.CreatedDate.date().daysBetween(objPatient.StatusUpdateDate__c.date()));
            if(mapTotalDays.containsKey(objPatient.Area__c)){
                mapTotalPatients.put(objPatient.Area__c, mapTotalPatients.get(objPatient.Area__c)+1);
                mapTotalDays.put(objPatient.Area__c, mapTotalDays.get(objPatient.Area__c) + days);
            }
            else{
                mapTotalPatients.put(objPatient.Area__c, 1);
                mapTotalDays.put(objPatient.Area__c,  days);
            }
        }
        List<Area__c> lstArea = new List<Area__c>();
        for(Id aId : mapTotalDays.keySet()){
            lstArea.add(new Area__c(Id =aId,RecoveryAverage__c = mapTotalDays.get(aId) / mapTotalPatients.get(aId)));
        }
        update lstArea;
    }
    public static void updateStatusDateTime(Map<Id,Patient__c> oldPatientMap,Map<Id,Patient__c> newPatientMap){
        for(Patient__c newObj : newPatientMap.values()){
            if(oldPatientMap.get(newObj.Id).Status__c != newObj.Status__c && (newObj.Status__c == 'Cured' || newObj.Status__c == 'Fatal')){
                newObj.StatusUpdateDate__c = System.Datetime.now();
            }
        }
    }
}