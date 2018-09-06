({
    sort: function(cmp, evt, help) {
        //All declared variables
        let notempty;
        let emptydata;
        let colname = evt.currentTarget.id;
        let data = JSON.parse(JSON.stringify(cmp.get('v.rowData')));
        let headerData = JSON.parse(JSON.stringify(cmp.get('v.colData')));
        // Perform Actions
        notempty = data.filter(val => {
            return (val.hasOwnProperty(colname))
        })
        emptydata = data.filter(val => {
            return !(val.hasOwnProperty(colname))
        })
        headerData.forEach(obj => {
            if (obj['fieldPath'] == colname) {
                if (obj['isSortUp'] == true) {
                    notempty.sort(help.sortDown(colname));
                    cmp.set('v.rowData', emptydata.length > 0 ? notempty.concat(emptydata) : notempty)
                    obj['isSortUp'] = false
                    obj['isSortDown'] = true
                } else {
                    notempty.sort(help.sortUp(colname));
                    cmp.set('v.rowData', emptydata.length > 0 ? emptydata.concat(notempty) : notempty)
                    obj['isSortUp'] = true
                    obj['isSortDown'] = false
                }
                obj['byDefaultSort'] = true
            } else obj['byDefaultSort'] = false
        });
        cmp.set('v.colData', headerData);
    }
})