({
    cols: function () {
        return [{
            label: 'Title',
            fieldName: 'Title',
            type: 'text'
        },
        {
            label: 'File Type',
            fieldName: 'FileType',
            type: 'text'
        },
        {
            label: 'Version Number',
            fieldName: 'VersionNumber',
            type: 'text'
        }
        ];
    },
    LoadinitialData: function (cmp, evt, help) {
        cmp.set('v.showSpiner', true);
        let methodName = 'c.loadData',
            params = {
                recordId: cmp.get('v.recordId'),
                strfields: cmp.get('v.strfields')
            },
            callbackRess = (response) => {
                if (response) {
                    this.makeoptionslist(cmp, evt, response.lstContentWrkspce);
                    this.assignValueToAttribute(cmp, response, evt);
                    cmp.set('v.showSpiner', false);
                }
                
            }
        this.callApexMethod(cmp, methodName, params, callbackRess);
    },

    getRecordsRelatedSingleFile: function (cmp, evt, help, selectedOptionValue) {
        let methodName = 'c.getRecords',
            params = {
                contentWorkspID: cmp.get('v.selectdLibrary'),
                lstWrapfield: JSON.stringify(cmp.get('v.listFields')),
                recordId: cmp.get('v.recordId')
            },
            callbackRess = (response) => {
                if (response) {
                    this.assignValueToAttribute(cmp, response, evt);
                    this.assignValueToAttribute(cmp, response, evt);
                    cmp.set('v.showSpiner', false);
                }
            }
        this.callApexMethod(cmp, methodName, params, callbackRess);
    },

    assignValueToAttribute: function (cmp, response, evt) {
        let related_Doc = [], notrelated_Doc = [];
        related_Doc = response.lstContentDocRel
        //.push({ type: 'action', typeAttributes: { rowActions:this.rowaction_RelatedDoc(cmp,evt)}})
        notrelated_Doc = response.lstContentDocNotRel
        //.push({ type: 'action', typeAttributes: { rowActions:this.rowaction_UnRelatedDoc(cmp,evt)}})
        cmp.set('v.ListLibrary', response.lstContentWrkspce);
        cmp.set('v.ListcontentRelated', related_Doc);
        cmp.set('v.ListcontentNotRelated', notrelated_Doc);
        //for search 
        cmp.set('v.temp_ListcontentRelated', related_Doc);
        cmp.set('v.temp_ListcontentNotRelated', notrelated_Doc);
        cmp.set('v.listFields', response.lstFields);
    },
    rowaction_RelatedDoc: function (cmp, evt) {
        return [
            { label: 'View', name: 'show_details', 'iconName': 'utility:zoomin' },
            { label: 'Unrelate', name: 'unrelate', 'iconName': 'utility:skip' }
        ];
    },
    rowaction_UnRelatedDoc: function (cmp, evt) {
        return [
            { label: 'View', name: 'show_details', 'iconName': 'utility:zoomin' },
            { label: 'Related', name: 'relate', 'iconName': 'utility:share_file' }
        ];
    },
    makeoptionslist: function (cmp, evt, libraryFiles) {
        let options = [];
        libraryFiles.forEach(function (key) {
            let obj = {};
            obj.value = key.Id;
            obj.label = key.Name;
            options.push(obj);
        });
        cmp.set('v.options', options);
        cmp.set('v.selectdLibrary', options[0].value);
    },

    linkFileToLibrary: function (cmp, evt, uploadedFiles) {
        let file = JSON.parse(JSON.stringify(uploadedFiles));
        let methodName = 'c.linkFiletoLib',
            params = {
                lstdocId: JSON.stringify(file),
                libID: cmp.get('v.selectdLibrary')
            },
            callbackRess = (response) => {
                if (response) {
                    this.LoadinitialData(cmp, evt, help);
                }
            }
        this.callApexMethod(cmp, methodName, params, callbackRess);
    },
    preview: function (cmp, evt, help, row) {
        let Id = JSON.parse(row).ContentDocumentId;
        $A.get('e.lightning:openFiles').fire({
            recordIds: [Id]
        });
    },
    relateFile: function (cmp, evt, help, row) {
        let documentId = JSON.parse(row).ContentDocumentId;
        let methodName = 'c.relateFile',
            params = {
                documentId: documentId,
                recordId: cmp.get('v.recordId')
            },
            callbackRess = (response) => {
                if (response) {
                    this.showToast('success','Sucess!','Please click on refresh icon');
                }
            }
        this.callApexMethod(cmp, methodName, params, callbackRess);
    },
    unrelateFile: function (cmp, evt, help, row) {
        let documentId = JSON.parse(row).ContentDocumentId;
        let methodName = 'c.unrelateFile',
            params = {
                documentId: documentId,
                recordId: cmp.get('v.recordId')
            },
            callbackRess = (response) => {
                if (response) {
                    this.showToast('success','Sucess!','Please click on refresh icon');
                }
            }
        this.callApexMethod(cmp, methodName, params, callbackRess);
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
            } else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    let message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                        this.showToast('error','error', message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function (type,title, message) {
        var toast = $A.get("e.force:showToast");

        // For lightning1 show the toast
        if (toast) {
            //fire the toast event in Salesforce1
            toast.setParams({
                "title": title,
                "type": type,
                "message": message
            });

            toast.fire();
        } else { 
        }
    }
})