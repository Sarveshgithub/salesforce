public class DisplayRecordController {
    public class AccountContactListWrapper{
        @AuraEnabled
        public Account acc;
        @AuraEnabled
        public Contact con;
        public AccountContactListWrapper(Account acc, Contact con) {
            this.acc = acc;
            this.con = con;
        }
    }
    
    @AuraEnabled
    public static List<AccountContactListWrapper> getRecords(){
        
        List<AccountContactListWrapper> lstAccCon = new List<AccountContactListWrapper>();
        
        //Doing Inside Loop for Time Being but canbe bulkify for large data
        
        for(Account acc : [Select id, Name From Account limit 10] ){
            for(Contact con : [Select id, Name From contact limit 1]){
                lstAccCon.add(new AccountContactListWrapper(acc, con));
            } 
        }
        
        return lstAccCon;
    }
}