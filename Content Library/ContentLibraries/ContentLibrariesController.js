({
    init: function (cmp, evt, help) {
        cmp.set('v.showSpiner', true);
        let rel_cols = help.cols(), nonrel_cols = help.cols();
        rel_cols.push({ type: 'action', typeAttributes: { rowActions: help.rowaction_RelatedDoc(cmp, evt) } })
        nonrel_cols.push({ type: 'action', typeAttributes: { rowActions: help.rowaction_UnRelatedDoc(cmp, evt) } })

        cmp.set('v.rel_columns', rel_cols);
        cmp.set('v.non_columns', nonrel_cols);
        help.LoadinitialData(cmp, evt, help);
    },
    handleUploadFinished: function (cmp, evt, help) {
        // afteer upload of file
        var uploadedFiles = evt.getParam("files");
        help.linkFileToLibrary(cmp, evt, uploadedFiles);

    },
    searchRecords: function (cmp, evt, help) {
        let element = evt.getSource(), inputValue = element.get("v.value"),
            relatedDoc = cmp.get('v.temp_ListcontentRelated'),
            notrelatedDoc = cmp.get('v.temp_ListcontentNotRelated');

        if (inputValue) {
            cmp.set('v.ListcontentRelated', relatedDoc.filter(item => item.Title.toLowerCase().indexOf(inputValue.toLowerCase()) > -1))
            cmp.set('v.ListcontentNotRelated', notrelatedDoc.filter(item => item.Title.toLowerCase().indexOf(inputValue.toLowerCase()) > -1))
        }
        else {
            cmp.set('v.ListcontentRelated', cmp.get('v.temp_ListcontentRelated'))
            cmp.set('v.ListcontentNotRelated', cmp.get('v.temp_ListcontentNotRelated'))
        }

    },
    handleChange: function (cmp, evt, help) {
        cmp.set('v.showSpiner', true);
        let selectedOptionValue = evt.getParam("value");
        cmp.set('v.selectdLibrary', selectedOptionValue);
        help.getRecordsRelatedSingleFile(cmp, evt, help, selectedOptionValue);
    },
    handleRowAction: function (cmp, event, help) {
        //alert('test')
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'show_details':
                help.preview(cmp, event, help, JSON.stringify(row));
                break;
            case 'relate':
                help.relateFile(cmp, event, help, JSON.stringify(row));
                break;
            case 'unrelate':
                help.unrelateFile(cmp, event, help, JSON.stringify(row));
                break;
        }
    }
})