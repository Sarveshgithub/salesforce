public class Test_Flow {
    public static void testPerms(){
        for (FieldPermissions fieldPerm : [
            SELECT
            Id,
            SobjectType,
            Field,
            ParentId,
            Parent.Name,
            Parent.IsOwnedByProfile,
            Parent.ProfileId,
            Parent.Profile.Name
            FROM FieldPermissions
            WHERE Field = 'Contact.field1__c' AND SobjectType = 'Contact'
        ]) {
            System.debug('data::::'+fieldPerm.Parent.IsOwnedByProfile);
        }
    }
}