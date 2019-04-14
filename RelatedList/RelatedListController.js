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
                helper.deleteRec(cmp, row)
                break;
        }
    },

    newRecord: function (cmp, evt, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": cmp.get('v.objectName')
        });
        createRecordEvent.fire();
    },
    pagination: function (cmp, evt, helper) {
        var whichBtn = evt.getSource().getLocalId();
        helper.pagiHandler(cmp, evt, whichBtn);
    },
    handleReferesh: function (cmp, evt, helper) {
        let typeEvt = evt.getParam("type");
        if (typeEvt != '' && typeEvt != undefined && typeEvt.tolowercase() != 'error') {
            help.loadDataHelp(cmp, evt, helper);
        }

    },
    openModalClose: function (cmp, evt, helper) {
        cmp.set('v.showModal', !cmp.get('v.showModal'));
        cmp.set('v.searchKeywork', '');
        cmp.set('v.selectedIds', []);
        cmp.set('v.NonRelateddata', null);
    },
    getText: function (cmp, evt, event, help) {
        let element = evt.getSource(), inputValue = element.get("v.value");
        if (inputValue.length > 1) {
            cmp.set('v.searchKeywork', inputValue);
        }
        else {
            cmp.set('v.searchKeywork', '');
        }
        // help.searchRecords(cmp, evt, help, inputValue);
    },
    searchRecords: function (cmp, evt, help) {
        help.showspinner(cmp, evt, 'spinner', true);
        let searchKeyword = cmp.get('v.searchKeywork');
        help.searchRecords(cmp, evt, help, searchKeyword);
    },
    getSelectedName: function (cmp, evt) {
        let selectedRows = evt.getParam('selectedRows'), selectedId = [];
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++) {
            selectedId.push(selectedRows[i].Id)
        }
        cmp.set('v.selectedIds', selectedId);
    },
    addRelatedRecord: function (cmp, evt, help) {
        help.showspinner(cmp, evt, 'spinner', true);
        let arrofRecs = [], Ids = cmp.get('v.selectedIds'), objName = cmp.get('v.objectName'),
            relatedApiName = cmp.get('v.RelatedListFieldAPI'), recID = cmp.get('v.recordId');
        Ids.map(val => {
            let obj = {};
            obj['attributes'] = { 'type': objName };
            obj[relatedApiName] = recID;
            obj['Id'] = val;
            arrofRecs.push(obj);
        })
        let methodName = 'c.updateRecord',
            params = {
                'records': arrofRecs
            },
            callbackRess = (response) => {
                if (response == 'Done') {
                    help.showToast('Successfully Added!', `${arrofRecs.length} has been added`, 'success');
                    cmp.set('v.searchKeywork', '');
                    cmp.set('v.selectedIds', []);
                    cmp.set('v.showModal', false);
                    cmp.set('v.NonRelateddata', null);
                    $A.get('e.force:refreshView').fire();
                    help.showspinner(cmp, evt, 'spinner', false);
                }
            }
        help.callApexMethod(cmp, methodName, params, callbackRess);
    }
})