({
    loadData: function(cmp, evt, help) {
        // Contact contact_field
        let state, action, ret;
        action = cmp.get('c.fetchContact');
        action.setParams({
            strSObjectName: cmp.get('v.object'),
            strFieldsetName: cmp.get('v.fieldSetName')
        });
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") {
                ret = response.getReturnValue();
                this.createHeader(cmp, ret['lstFields'])
                this.createRows(cmp, ret['lstFields'], ret['lstSObject'])
            }
        });
        $A.enqueueAction(action);
    },
    createHeader: function(cmp, field) {
        let orderData = field.map(e => {
            var obj = {};
            obj['label'] = e['label']
            obj['fieldPath'] = e['fieldPath']
            obj['isSortUp'] = true
            obj['isSortDown'] = false
            obj['byDefaultSort'] = e['label'] == 'Name' ? true : false
            return obj;
        })
        cmp.set('v.colData', orderData);
    },
    createRows: function(cmp, field, row) {
        let filedPath = field.map(e => {
            return e['fieldPath']
        })
        cmp.set('v.fieldPath', filedPath);
        cmp.set('v.allRowData', row);
        cmp.set('v.rowData', row.splice(0, cmp.get('v.prev')));
    },
    toast: function(title, message, type) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
        });
        toastEvent.fire();
    }
})