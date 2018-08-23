({
    click : function(component, event, helper) {
        var childCmp = component.find('childCmp');
        component.set('v.no_times',component.get('v.no_times')+1);
        childCmp.sampleMethod(component.get('v.no_times')); 
    },
    parentAction : function(component, event, helper) {
        component.set('v.aura_action',component.get('v.aura_action')+1);
        component.set('v.aura_action',component.get('v.aura_action'));
    }
})