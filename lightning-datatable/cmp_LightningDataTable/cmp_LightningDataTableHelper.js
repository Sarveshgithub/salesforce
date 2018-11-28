({
    // This function is used for load Data on Init
    loadData: function (cmp, evt, help) {
        let methodName = 'c.fetchContact', cols = [],
            params = { 'strSObjectName': 'Contact', 'strFieldsetName': 'contact_field' },
            callbackRess = (response) => {

                if (response) {
                    cols = response.lstFields;
                    cols = this.addColumnAttribute(cmp, event, help, cols);
                    console.log('cols', cols);
                    cols.push({ type: 'action', typeAttributes: { rowActions: this.rowAction(cmp, evt, help) } });
                    cmp.set('v.columns', cols)
                    cmp.set('v.data', response.lstSObject)
                    console.log('response', response)
                }
            }

        this.callApexMethod(cmp, methodName, params, callbackRess);

    },

    // This method used for add additional parameter into the columns
    addColumnAttribute: function (cmp, event, help, cols) {
        cols.map(col => {
            col['editable'] = true;
            col['typeAttributes'] = { required: true }
            col['fieldName'] == 'Name' ? col['iconName'] = 'standard:contact' : ''
            col['type'] == 'string' ? col['type'] = 'text' : col['type'] == 'datetime' ? col['type'] = 'date' : ''
        })
        return cols;
    },

    // This function is for calling Apex method and return results
    callApexMethod: function (cmp, methodName, params, callbackRess) {

        let state, action;
        action = cmp.get(methodName);
        action.setParams(params);
        action.setCallback(this, function (response) {
            state = response.getState();
            if (state === "SUCCESS") {
                callbackRess(response.getReturnValue())
            }
            else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    
                    cmp.set('v.errors', {
                        table: {
                            title: 'Your entry cannot be saved. Fix the errors and try again.',
                            messages: [
                                errors[0].message
                            ]
                        }
                    });
                }
            }
        });
        $A.enqueueAction(action);

    },

    // This method is used for add action into row
    rowAction: function (cmp, evt, help) {
        return [
            { label: 'Show details', name: 'show_details', 'iconName': 'utility:zoomin' },
            { label: 'Delete', name: 'delete', 'iconName': 'utility:delete' }
        ];
    },

    // This method is used for sort the data on click of column header name
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        cmp.set("v.data", data);
    },

    // This method is using sort JS function
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function (x) { return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa') }
            : function (x) { return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa' };
        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },

    // This method is used for delete the record from row action
    removeBook: function (cmp, row) {
        let rows = cmp.get('v.data'),
            rowIndex = rows.indexOf(row),
            methodName = 'c.deleteRecord',
            params = { 'recId': row['Id'] },
            callbackRess = (response) => {
                if (response) {
                    rows.splice(rowIndex, 1)
                    cmp.set('v.data', rows);
                    this.showToast('Success Message', 'Record Delete Successfully', 'success');
                }
            };

        this.callApexMethod(cmp, methodName, params, callbackRess);
    },

    // This method is used for update the recorsd on click of save button.
    saveEdition: function (cmp, evt, draftValues) {
        let methodName = 'c.updateRecords',
            params = { 'updateRecs': JSON.stringify(draftValues) },
            callbackRess = (response) => {

                if (response) {
                    cmp.set("v.draftValues", null);
                }
            }
        this.callApexMethod(cmp, methodName, params, callbackRess)
    },

    // This method is used for showing the toast method.
    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
        });
        toastEvent.fire();
    },

})
