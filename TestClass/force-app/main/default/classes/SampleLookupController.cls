public with sharing class SampleLookupController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds,String objectName,String iconName) {
        // Prepare query paramters
        searchTerm += '*';
        String searchquery = 'FIND :searchTerm IN ALL FIELDS RETURNING ';
        if(selectedIds.size() > 0){
            searchquery += objectName+'(Id, Name  WHERE id NOT IN :selectedIds)  LIMIT '+MAX_RESULTS;
        } else {
            searchquery += objectName+'(Id, Name )  LIMIT '+MAX_RESULTS;
        }

        // Execute search query
        List<List<SObject>> searchResults = search.query(searchquery);
        
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        SObject[] lstResults = searchResults[0];
        for (SObject obj : lstResults) {
            String subtitle = objectName+' • ' + obj.get('Name');
            results.add(new LookupSearchResult((Id)obj.get('Id'), 'Account', iconName, (String)obj.get('Name'), subtitle));
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed() {
        String objectName = 'Account';
        String iconName = 'standard:account';
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type =: objectName
            ORDER BY LastViewedDate DESC
            LIMIT 5
        ];
        // Convert recent records into LookupSearchResult
        for (RecentlyViewed recentRecord : recentRecords) {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        objectName,
                        iconName,
                        recentRecord.Name,
                        objectName+' • ' + recentRecord.Name
                    )
                );
        }
        return results;
    }
}