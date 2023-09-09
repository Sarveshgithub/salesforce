public virtual class Soql implements ISqol {
  private String query;
  public virtual String q_select(String field) {
    this.query = 'SELECT ' + field;
    return this.query;
  }

  public virtual String q_select(List<String> fields) {
    return this.q_select(String.join(fields, ', '));
  }

  public virtual String q_from(String objectName) {
    return this.query += ' FROM ' + objectName;
  }

  public virtual String q_where(String whereClause) {
    return this.query += ' WHERE ' + whereClause;
  }

  public virtual String q_limit(Integer limits) {
    return this.query += ' LIMIT ' + String.valueOf(limits);
  }

  public virtual List<sObject> q_execute() {
    return Database.query(this.query);
  }
}