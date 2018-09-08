({
    loadData: function(cmp, evt, help) {
        help.loadData(cmp, evt, help)
    },
    next: function(cmp, evt, help) {
        let data, next, prev, orderData, tempdata = [];
        data = cmp.get('v.allRowData');
        data.forEach(val => {
            tempdata.push(val)
        })
        next = cmp.get('v.next');
        prev = cmp.get('v.prev');
        orderData = tempdata.splice(next + prev, prev);
        cmp.set('v.next', next + prev)
        cmp.set('v.rowData', orderData);
        cmp.set('v.allRowData', data)
    },
    prev: function(cmp, evt, help) {
        let data, next, prev, orderData, tempdata = [];
        data = cmp.get('v.allRowData');
        data.forEach(val => {
            tempdata.push(val)
        })
        next = cmp.get('v.next');
        prev = cmp.get('v.prev');
        orderData = tempdata.splice(next - prev, prev);
        cmp.set('v.next', next - prev)
        cmp.set('v.rowData', orderData);
        cmp.set('v.allRowData', data)
    },
    editRec: function(cmp, evt, help) {
        let recId;
        recId = evt.currentTarget.id;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recId
        });
        editRecordEvent.fire();
    },
    refresh: function(cmp, evt, help) {
        $A.get('e.force:refreshView').fire();
    },
    deleteRec: function(cmp, evt, help) {
        let state, recId, action, ret;
        recId = evt.currentTarget.id;
        console.log(recId);
        action = cmp.get('c.deleteRecord');
        action.setParams({
            recId: recId
        });
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") {
                ret = response.getReturnValue();
                console.log(ret);
                if (ret) {
                    help.toast('Success!', 'Delete Successfully', 'success')
                }
            }
        });
        $A.enqueueAction(action);
    },
    newRecord: function(cmp, evt, help) {
        let createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": cmp.get('v.object')
        });
        createRecordEvent.fire();
    }
})