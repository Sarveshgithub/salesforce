({
        loadData: function(cmp, evt, help) {
            help.loadData(cmp, evt, help)
        },
        click: function(cmp) {},
        deleteRec: function(cmp, evt, help) {
            let recId = evt.currentTarget.id;
            console.log(recId);
            var modalBody;
            $A.createComponent("c:ModalCmp", {}, function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    cmp.find('overlayLib').showCustomModal({
                        header: "Application Confirmation",
                        body: 'ssfdsfsdf',
                        showCloseButton: true,
                        cssClass: "mymodal",
                        closeCallback: function() {
                            alert('You closed the alert!');
                        }
                    })
                }
            });
        }
    
})