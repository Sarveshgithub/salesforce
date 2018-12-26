({
    init: function (cmp, evt, help) {
        help.loadDataHelp(cmp, evt, help);
    },
    updateColumnSorting: function (cmp, event, helper) {
        cmp.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout(function () {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            cmp.set("v.sortedBy", fieldName);
            cmp.set("v.sortedDirection", sortDirection);
            helper.sortData(cmp, fieldName, sortDirection);
            cmp.set('v.isLoading', false);
        }, 0);
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'Edit':
                helper.EditRowId(cmp, row);
                break;
            case 'delete':
                helper.removeBook(cmp, row)
                break;
        }
    },
    
    newRecord : function (cmp, evt, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
    	createRecordEvent.setParams({
        	"entityApiName": cmp.get('v.objectName')
        });
        createRecordEvent.fire();
    },
    pagination : function (cmp, evt, helper) {
         var whichBtn = evt.getSource().getLocalId();
        helper.pagiHandler(cmp, evt,  whichBtn);
    },
})