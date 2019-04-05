({
    // This function is used for load Data on Init
    loadDataHelp: function (cmp, evt, help) {
        let methodName = 'c.loadData',
            cols = [],
            rows = [],
            isRelLst = cmp.get('v.isRelatedList') != undefined || cmp.get('v.isRelatedList') != null || cmp.get('v.isRelatedList') != '' ? true : false,
            params = {
                'objectAPIName': cmp.get('v.objectName'),
                'lstFields': cmp.get('v.lstfields'),
                'filterCriteria': cmp.get('v.FilterCriteria'),
                'isRelatedList': isRelLst,
                'RelatedListFieldAPI': cmp.get('v.RelatedListFieldAPI'),
                'recID': cmp.get('v.recordId')
            },
            callbackRess = (response) => {
                if (response) {
                    cols = response.lstFields;
                    rows = response.lstSObject;
                    //console.log('cols-->',cols);
                    //console.log('rows--->',rows);
                    rows = this.addRowAttribute(cmp, event, help, rows, cols, response.baseURL);
                    cols = this.addColumnAttribute(cmp, event, help, cols);
                    if (cmp.get('v.isRowAction'))
                        cols.push({ type: 'action', typeAttributes: { rowActions: this.rowAction(cmp, evt, help) } });
                    cmp.set('v.columns', cols);
                    cmp.set('v.Alldata', rows);
                    // pagination 
                    this.countTotalPages(cmp, evt);
                    this.addData(cmp, evt, 0, cmp.get('v.pageSize'));
                }
            }
        this.callApexMethod(cmp, methodName, params, callbackRess);
    },
    // This method used for add additional parameter into the columns
    addColumnAttribute: function (cmp, event, help, cols) {

        cols.map(col => {
            col['fieldName'] == 'Name' ? col['type'] = 'url' : '';
            col['isRef'] ? col['type'] = 'url' : '';
            col['isRef'] ? col['fieldName'] = col['lkupRelName'] : '';
            col['type'] == 'url' ? col['typeAttributes'] = { label: { fieldName: col['fieldName'] } } : '';
            col['fieldName'] = col['type'] == 'url' ? col['fieldName'] + 'Url' : col['fieldName'];
            col['type'] = col['type'].toLowerCase();
            col['sortable'] = true;
            col['type'] == 'double' ? col['type'] = 'number' : '';
        });
        return cols;
    },
    addRowAttribute: function (cmp, event, help, rows, cols, baseUrl) {
        rows.map(row => {
            for (let i = 0; i < cols.length; i++) {

                let fldName = cols[i].fieldName;

                if (fldName == 'Name') {
                    row[fldName + 'Url'] = baseUrl + '/lightning/r/sObject/' + row['Id'] + '/view';
                }

                if (cols[i].isRef == true) {
                    fldName = cols[i].lkupRelName;
                    //console.log(' -->',fldName);
                }
                if (fldName.includes('.') && cols[i].isRef) {

                    let temp = [];
                    temp = fldName.split('.');
                    let value = row;
                    for (let k = 0; k < temp.length; k++) {
                        if (value != undefined && value != null && value != '') {
                            if (k == (temp.length - 1)) {
                                row[fldName + 'Url'] = baseUrl + '/lightning/r/sObject/' + value['Id'] + '/view';
                                value = value[this.capitalizeFirstLetter(cmp, event, temp[k])];
                                row[fldName] = value;
                            } else {
                                value = value[this.capitalizeFirstLetter(cmp, event, temp[k])];
                            }
                        }
                    }
                } else if (fldName.includes('.') && cols[i].isRef == false) {
                    let temp = [], value = row;
                    temp = fldName.split('.');
                    value = value[this.capitalizeFirstLetter(cmp, event, temp[0])];
                    //console.log('value-->',value,'field-->',this.capitalizeFirstLetter(cmp, event, temp[0]));
                    if (value != undefined && value != null && value != '') {
                        value = value[this.capitalizeFirstLetter(cmp, event, temp[1])];
                        row[fldName] = value;
                        //console.log('value-->',value,'field-->',this.capitalizeFirstLetter(cmp, event, temp[1]));
                    }

                }

            }
        });
        return rows;
    },
    capitalizeFirstLetter: function (cmp, event, str) {
        return str[0].toUpperCase() + str.slice(1);
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
                    let message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                        this.showToast('Error!!', message, 'error');
                    }
                }
            }
        });
        $A.enqueueAction(action);

    },

    // This method is used for add action into row
    rowAction: function (cmp, evt, help) {
        return [
            { label: 'Edit', name: 'Edit', 'iconName': 'utility:edit' },
            { label: 'Delete', name: 'delete', 'iconName': 'utility:delete' }
        ];
    },

    // This method is used for sort the data on click of column header name
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        if (fieldName.includes('Url')) {
            fieldName = fieldName.slice(0, -3);
        }

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
    deleteRec: function (cmp, row) {
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
    EditRowId: function (cmp, row) {
        let Id = row['Id'];
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": Id
        });
        editRecordEvent.fire();

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
    pagiHandler: function (cmp, evt, buttonPressed) {
        let pageSize = cmp.get('v.pageSize'),
            start = cmp.get('v.start'),
            end = cmp.get('v.end'),
            currentPage = cmp.get('v.currentPage'),
            totalPage = cmp.get('v.totalPages');

        switch (buttonPressed) {
            case 'First':
                this.addData(cmp, evt, 0, cmp.get('v.pageSize'));
                break;
            case 'Previous':
                this.addData(cmp, evt, ((currentPage - 1) * pageSize) - parseInt(pageSize), (currentPage - 1) * pageSize);
                break;
            case 'Next':
                this.addData(cmp, evt, currentPage * pageSize, (currentPage * pageSize) + parseInt(pageSize));
                break;
            case 'Last':
                this.addData(cmp, evt, (totalPage * pageSize) - pageSize, totalPage * pageSize);
                break;
        }
    },
    addData: function (cmp, evt, start, end) {
        let AllData = cmp.get('v.Alldata'),
            pageSize = cmp.get('v.pageSize');
        let pageData = AllData.slice(start, end);
        cmp.set('v.data', pageData);
        cmp.set('v.start', start);
        cmp.set('v.end', end);
        cmp.set('v.currentPage', parseInt(end) / parseInt(pageSize));
    },
    countTotalPages: function (cmp, evt) {
        let AllData = cmp.get('v.Alldata'),
            pageSize = cmp.get('v.pageSize');
        let totalPage = AllData.length / pageSize;
        if (parseInt(totalPage) * parseInt(pageSize) >= AllData.length) {
            cmp.set('v.totalPages', parseInt(totalPage));
        } else {
            cmp.set('v.totalPages', parseInt(totalPage) + 1);
        }

    },
})