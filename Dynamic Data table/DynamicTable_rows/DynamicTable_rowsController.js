({
    doInit: function(cmp, evt, hel) {
    	 let rows = cmp.get('v.rows');
    	 let fieldName = cmp.get('v.fieldName');
        //console.log('rows: ',JSON.parse(JSON.stringify(rows)));
        //console.log('fieldName: ',JSON.parse(JSON.stringify(fieldName)));
        cmp.set('v.data', JSON.parse(JSON.stringify(rows))[JSON.parse(JSON.stringify(fieldName))])
    	 //console.log(`col : ${fieldName}`)
    }
})