public interface ISqol {
  String q_select(String field);
  String q_select(List<String> fields);
  String q_from(String objectName);
  String q_where(String whereClause);
  String q_limit(Integer limits);
  List<sObject> q_execute();
}