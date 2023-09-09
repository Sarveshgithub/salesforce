public class NewClass {
    
    public static void method(String name, String email){
        System.debug('Return:::' + getListContact(new list<String> {'Ajay', 'Ram'}));
    }
    
    public static List<Contact> getListContact(list<string> names){
        
        return null;
    }
    
    public static List<sObject> getData(List<Account> lstAccount){
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static void createContact(){
        Insert new Contact(lastName = 'Test');
    }
}