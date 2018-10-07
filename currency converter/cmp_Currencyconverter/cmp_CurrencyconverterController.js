({
    loadCurrencyOption: function(cmp, evt, help) {
        let a = window.SpeechRecognition;
        console.log('a',a);
        let state, action, ret, opts = [],
            unformatobj;
        action = cmp.get('c.calloutCurrency');
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") {
                ret = response.getReturnValue();
                ret = JSON.parse(ret);
                unformatobj = ret['quotes'];
                Object.keys(unformatobj).map(val => {
                    opts.push({
                        'label': val.slice(3),
                        'value': unformatobj[val].toFixed(2)
                    });
                    console.log(val, unformatobj[val]);
                    if(val == 'USDINR') {
                    	cmp.set('v.to', unformatobj[val].toFixed(2));
                    	cmp.set('v.from', 1)
                    }
                })
                 cmp.find('tono').set('v.value', 1)
                 cmp.find('fromno').set('v.value', 1)
            }
            console.log('opts', opts);
            opts.push({
                'label': 'USD',
                'value': 1,
                'selected' : true
            });
            cmp.set('v.options', opts);
        });
        $A.enqueueAction(action);
    },
    onchange: function(cmp, evt, help) {
        let from, fromSelect, toSelect, to;
        if (from != '') {
        	console.log('value111', cmp.find('from').get('v.text'), evt.currentTarget.text)
            from = cmp.find('fromno').get('v.value');
            fromSelect = cmp.find('from').get('v.value');
            toSelect = cmp.find('to').get('v.value');
            to = ((Number(from) * (Number(toSelect)) / Number(fromSelect)));
            cmp.find('tono').set('v.value', to.toFixed(2))
            cmp.set('v.to', to.toFixed(2));
            cmp.set('v.from', from);
        }
    },
    changefrom: function(cmp, evt, help) {
        let from, fromSelect, toSelect, to;
        if (from != '') {
            from = cmp.find('fromno').get('v.value');
            fromSelect = cmp.find('from').get('v.value');
            toSelect = cmp.find('to').get('v.value');
            to = ((Number(from) * (Number(toSelect)) / Number(fromSelect)));
            cmp.find('tono').set('v.value', to.toFixed(2))
        }
    },
    changeto: function(cmp, evt, help) {
        let from, fromSelect, toSelect, to;
        if (from != '') {
            to = cmp.find('tono').get('v.value');
            fromSelect = cmp.find('from').get('v.value');
            toSelect = cmp.find('to').get('v.value');
            from = ((Number(to) * (Number(fromSelect)) / Number(toSelect)));
            cmp.find('fromno').set('v.value', from.toFixed(2))
        }
    }
})