({
    loadData: function(cmp, evt, help) {
        var action = cmp.get('c.fetchContact');
        action.setParams({
            strSObjectName: 'Contact',
            strFieldsetName: 'contact_field'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                console.log('ret>>>>>>', ret);
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
            obj['byDefaultSort'] = e['label'] == 'Email' ? true : false
            return obj;
        })
        console.log(orderData);
        cmp.set('v.colData', orderData);
        //console.log('dfghjk', cmp.get('v.colData'))
    },
    createRows: function(cmp, field, row) {
    	console.log(field);
    	console.log(row)

        let filedPath = field.map(e => {
            return e['fieldPath']
           
        })
        cmp.set('v.fieldPath', filedPath);
        cmp.set('v.rowData', row);
        
        
    }
})