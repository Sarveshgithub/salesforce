({
    init: function (cmp, evt, help) {
        help.loadData(cmp, evt, help);
    },
    selectedRow: function (cmp, event, help) {
        var selectedRows = event.getParam('selectedRows');
        console.log('selected', selectedRows);
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
            case 'show_details':
                alert('Showing Details: ' + JSON.stringify(row));
                break;
            case 'delete':
                helper.removeBook(cmp, row)
                break;
        }
    },
    // This method for save the data
    handleSaveEdition: function (cmp, evt, helper) {
        var draftValues = evt.getParam('draftValues');
        console.log('draftValues', draftValues);
        helper.saveEdition(cmp,evt, draftValues);
    }
})
