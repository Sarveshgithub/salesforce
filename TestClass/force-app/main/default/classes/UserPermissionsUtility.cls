public with sharing class UserPermissionsUtility {
  public static String FIELD_TYPE = 'FIELD';
  public static String OBJECT_TYPE = 'OBJECT';
  public class PermissionWrapper {
    @AuraEnabled
    public String recId { get; set; }
    @AuraEnabled
    public String permType { get; set; }
    @AuraEnabled
    public String profileId { get; set; }
    @AuraEnabled
    public String permissionSetId { get; set; }
    @AuraEnabled
    public Boolean isOwnedByProfile { get; set; }
    @AuraEnabled
    public String permissionSetName { get; set; }
    @AuraEnabled
    public String profileName { get; set; }
    @AuraEnabled
    public List<FieldPermissions> lstFieldPermissions { get; set; }
    @AuraEnabled
    public List<ObjectPermissions> objectPermission { get; set; }
    public PermissionWrapper(
      String recId,
      String permType,
      String profileId,
      String permissionSetId,
      Boolean isOwnedByProfile,
      String permissionSetName,
      String profileName,
      List<FieldPermissions> lstFieldPermissions,
      List<ObjectPermissions> objectPermission
    ) {
      this.recId = recId;
      this.permType = permType;
      this.profileId = profileId;
      this.permissionSetId = permissionSetId;
      this.isOwnedByProfile = isOwnedByProfile;
      this.permissionSetName = permissionSetName;
      this.profileName = profileName;
      this.lstFieldPermissions = lstFieldPermissions;
      this.objectPermission = objectPermission;
    }
  }
  @AuraEnabled
  public static List<PermissionWrapper> getUserPermission(
    List<String> lstObjectName,
    List<String> lstFieldName,
    String userId
  ) {
    List<String> lstObjectNameQuotes = new List<String>();
    List<String> lstFieldNameQuotes = new List<String>();
    List<String> fieldCondition = new List<String>();
    List<String> objectCondition = new List<String>();
    Map<String, PermissionWrapper> mapPermission = new Map<String, PermissionWrapper>();
    String fieldSOQL = 'SELECT Id,SobjectType,Field,ParentId,PermissionsEdit,PermissionsRead,Parent.Name,Parent.IsOwnedByProfile,Parent.ProfileId,Parent.Profile.Name FROM FieldPermissions';
    if (lstObjectName.size() > 0) {
      for (String obj : lstObjectName) {
        lstObjectNameQuotes.add('\'' + obj + '\'');
      }
      fieldCondition.add(
        ' SobjectType IN  (' +
        String.join(lstObjectNameQuotes, ',') +
        ')'
      );
    }
    if (lstFieldName.size() > 0) {
      for (String obj : lstFieldName) {
        lstFieldNameQuotes.add('\'' + obj + '\'');
      }
      fieldCondition.add(
        ' Field IN  (' +
        String.join(lstFieldNameQuotes, ',') +
        ')'
      );
    }
    if (fieldCondition.size() > 0) {
      fieldSOQL += ' WHERE ' + String.join(fieldCondition, ' AND ');
    }
    System.debug('fieldSOQL:::' + fieldSOQL);
    for (
      FieldPermissions fieldPerm : (List<FieldPermissions>) Database.query(
        fieldSOQL
      )
    ) {
      if (mapPermission.containsKey(fieldPerm.ParentId)) {
        mapPermission.get(fieldPerm.ParentId)
          .lstFieldPermissions.add(fieldPerm);
      } else {
        mapPermission.put(
          fieldPerm.ParentId,
          new PermissionWrapper(
            fieldPerm.Id,
            FIELD_TYPE,
            fieldPerm.Parent.ProfileId,
            fieldPerm.ParentId,
            fieldPerm.Parent.IsOwnedByProfile,
            fieldPerm.Parent.Name,
            fieldPerm.Parent.Profile.Name,
            new List<FieldPermissions>{ fieldPerm },
            new List<ObjectPermissions>()
          )
        );
      }
    }

    for (ObjectPermissions objPerm : [
      SELECT
        Parent.Name,
        ParentId,
        Parent.IsOwnedByProfile,
        Parent.ProfileId,
        Parent.Profile.Name,
        SobjectType,
        PermissionsRead,
        PermissionsCreate,
        PermissionsDelete,
        PermissionsEdit,
        PermissionsViewAllRecords,
        PermissionsModifyAllRecords
      FROM ObjectPermissions
      WHERE SobjectType IN :lstObjectName
    ]) {
      if (mapPermission.containsKey(objPerm.ParentId)) {
        System.debug('data::::' + objPerm);
        mapPermission.get(objPerm.ParentId).objectPermission.add(objPerm);
      } else {
        mapPermission.put(
          objPerm.ParentId,
          new PermissionWrapper(
            objPerm.Id,
            OBJECT_TYPE,
            objPerm.Parent.ProfileId,
            objPerm.ParentId,
            objPerm.Parent.IsOwnedByProfile,
            objPerm.Parent.Name,
            objPerm.Parent.Profile.Name,
            new List<FieldPermissions>(),
            new List<ObjectPermissions>{ objPerm }
          )
        );
      }
    }
    return mapPermission.values();
  }
}