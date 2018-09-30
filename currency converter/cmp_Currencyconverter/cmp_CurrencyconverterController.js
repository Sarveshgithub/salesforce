({
    loadCurrencyOption: function(cmp, evt, help) {
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
                })
            }
            console.log('opts', opts);
            opts.push({
                'label': 'USD',
                'value': 1
            });
            cmp.set('v.options', opts);
        });
        $A.enqueueAction(action);
    },
    onchangeFrom: function(cmp, evt, help) {
        let from, fromSelect, toSelect, to;
        if (from != '') {
            from = cmp.find('fromno').get('v.value');
            fromSelect = cmp.find('from').get('v.value');
            toSelect = cmp.find('to').get('v.value');
            to = ((Number(from) * (Number(toSelect)) / Number(fromSelect)));
            cmp.find('tono').set('v.value', to.toFixed(2))
        }
    },
    onchangeTo: function(cmp, evt, help) {
        let from, fromSelect, toSelect, to;
        if (from != '') {
            to = cmp.find('tono').get('v.value');
            fromSelect = cmp.find('from').get('v.value');
            toSelect = cmp.find('to').get('v.value');
            from = ((Number(to) * (Number(fromSelect)) / Number(toSelect)));
            cmp.find('fromno').set('v.value', from.toFixed(2))
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