({
    loadDataHelp: function (cmp, evt, help) {
        let methodName = 'c.getFileds',
            params = {
                'objectName': 'Contact',
                'lstFields': ['Name', 'Test_checkbox__c', 'LeadSource'],

            },
            callbackRess = (response) => {
                let fields = [];
                if (response) {
                    console.log('response::', response);
                    response.map(val => {
                        val['fieldDataType'] == 'STRING' ? this.createLightningInput(cmp, evt, help, val) : '';
                        val['fieldDataType'] == 'BOOLEAN' ? this.createLightningCheckBox(cmp, evt, help, val) : '';
                        val['fieldDataType'] == 'PICKLIST' ? this.createLightnigPicklist(cmp, evt, help, val) : '';
                    })
                }
                console.log(fields)
               // this.createListOfComponent(cmp, fields);
            }
        this.callApexMethod(cmp, methodName, params, callbackRess);
    },
    createLightningInput: function (cmp, evt, help, attributes) {
        let type = 'lightning:input', attri = {
            'name': attributes.fieldApiName,
            'label': attributes.fieldLabel,
            'value': attributes.value,
            'aura:id': attributes.auraid
        };
        this.createComponent(cmp, type, attri)
    },
    createLightningCheckBox: function (cmp, evt, help, attributes) {
        let type = 'ui:inputCheckbox', attri = {
            'name': attributes.fieldApiName,
            'label': attributes.fieldLabel,
            'value': attributes.value,
            'aura:id': attributes.auraid
        };
        this.createComponent(cmp, type, attri)
    },
    createLightnigPicklist: function (cmp, evt, help, attributes) {
        $A.createComponents(
            [
                [
                    "lightning:select", { label: "Select List", name: "list1" }
                ],
                [
                    "option", { value: "Option 1", label: "Option 1" }
                ],
                [
                    "option", { value: "Option 2", label: "Option 2" }
                ]
            ],
            function (components) {
                var body = cmp.get("v.body");
                components[0].set("v.body", [components[1], components[2]]);
                body.push(components[0]);
                cmp.set("v.body", body);
            }

        );

    },
    callApexMethod: function (cmp, methodName, params, callbackRess) {
        let state, action;
        action = cmp.get(methodName);
        if (params)
            action.setParams(params);
        action.setCallback(this, function (response) {
            state = response.getState();
            console.log('STATE', state)
            if (state === "SUCCESS") {
                callbackRess(response.getReturnValue())
            }
            else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    console.log('ERROR:', errors);

                    let type = 'ui:message',
                        attributes = {
                            "title": `${errors[0].message}`,
                            "severity": 'error',
                            "closable": true
                        };
                    this.createComponent(cmp, type, attributes);
                }
            }
        });
        $A.enqueueAction(action);
    },
    createComponent: function (cmp, type, attributes) {
        console.log(type, attributes);
        $A.createComponent(type, attributes, function (newButton, status, errorMessage) {
            //Add the new button to the body array
            if (status === "SUCCESS") {
                var body = cmp.get("v.body");
                body.push(newButton);
                cmp.set("v.body", body);
            }
            else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.")
                // Show offline error
            }
            else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
                // Show error message
            }
        });
    },
})
