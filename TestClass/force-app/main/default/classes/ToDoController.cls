public with sharing class ToDoController{
	@AuraEnabled
	public static List<Task> fetchTask(){
		return [SELECT Id, Description, Status
		        FROM Task
		        limit 100];
	}

	@AuraEnabled
	public static Boolean createTask(String description, String status){
		insert new Task(Description = description, Status = status, Subject = 'Other', Priority = 'Normal', OwnerId = UserInfo.getUserId());
		return true;
	}

	@AuraEnabled
	public static Boolean updateTask(Id taskId, String description, String status){
		update new Task(Id = taskId, Description = description, Status = status);
		return true;
	}

	@AuraEnabled
	public static Boolean deleteTask(Id taskId){
		delete new Task(id = taskId);
		return true;
	}
}