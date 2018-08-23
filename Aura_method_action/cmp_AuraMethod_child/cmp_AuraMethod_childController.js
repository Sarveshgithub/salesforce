({
    doAction : function(component, event, helper) {
        var params = event.getParam("arguments");
        if (params) {
            var param = params.param;
            component.set('v.no_times',param);
        }
    }
})